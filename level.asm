LoadLevel: subroutine
	
        ldy #0
.copy   lda (lvlptr),y
        sta lvldat,y
        beq .out
        iny
        jmp .copy
.out	tya
	sec
        adc lvlptr
        sta lvlptr
        lda lvlptr+1
        adc #0
        sta lvlptr+1
	rts



RenderLevel: subroutine
      	ldy #0
NextItem:
        lda lvldat,y
        bne .nend
        ldx #$0f
.clean  sta $10,x	; do i HAVE to clean?
        dex
        bpl .clean
        rts        
.nend   and #$c0
        bne .ndirt
        jsr DrawDirt
        jmp NextItem
.ndirt  cmp #$c0
        bne .nfill
        jsr DrawInner
        iny
        jmp NextItem
.nfill  cmp #$80
        bne .nblock
        jsr DrawBlock
        jmp NextItem
.nblock
        iny
        jmp NextItem


DrawBlock: subroutine
        lda lvldat,y
        sta $4
        iny
        lda lvldat,y
        sta $5
        iny
        tya
        pha


        ldx #0
.find   lda objlist,x
        beq .empty
        inx
        inx
        jmp .find

.empty  
	lda $4
        sta objlist,x
        inx
	lda $5
        sta objlist,x
        
        pla
        tay
        rts


DrawInner:
        lda lvldat,y
        sta $19
        
        ; set sides right away
        and #$0f
        sta $8
        
        sty $3
        
	; load the two overlapping rects
        lda $30
        sta $a
        lda $31
        sta $b
        lda $32
        sta $c
        
        ldx #0
        lda #$20
        bit $19
        beq .nthree
	ldx #3
.nthree
	lda $33,x
        sta $d
        lda $34,x
        sta $e
        lda $35,x
        sta $f
         
	; y is always y2
        lda $a
        sta $4
        lda $b
        and #$e0
        sta $5
 
        ; calculate first bit
        lda $b
        and #$1f
        sta $10
        lda $e
        and #$1f
        sta $11
        cmp $10		; x1 - x2
        bcc .sbit0
.cbit0	ldy #$80
	lda $e
	jmp .b0done
.sbit0	ldy #$00
	lda $b
.b0done	sty $9
	and #$1f
        clc
        adc $5
        sta $5
        
	; calculate second bit
        lda $c
        and #$0f
        sta $14
        clc
        adc $10
        sta $12
        lda $f
        and #$0f
        sta $15
        adc $11
        sta $13
        cmp $12		; x>1 - x>2
        bcc .sbit1
.cbit1	lda $14
	tay
        lda #0
	jmp .b1done
.sbit1	lda $13
	sec
        sbc $10
        tay
        lda #$04
.b1done	sty $6
	ora $9
        sta $9
        
        ; third bit is given
        lda #$10
        bit $19
        bne .sbit2
.cbit2	lda $c
	and #$f0
	lsr
        lsr
        lsr
        lsr
        sta $7
        lda $9
        lsr
        lsr
        ora $9
        eor #$03
        sta $9
	jmp .b2done
.sbit2	ldx #3
.calcy	lda $a,x
        clc
        asl
        asl
        asl
        sta $10,x
        lda $b,x
        clc
        rol
        rol
        rol
        and #$07
        ora $10,x
        sta $10,x
        dex
        dex
        dex
        bpl .calcy
        
        lda $13
        sec
        sbc $10
        sta $7
        lda $f
        and #$f0
        lsr
        lsr
        lsr
        lsr
        sec
        adc $7
        adc #0
        sta $7
        
        lda $9
        lsr
        lsr
        eor #$3
        ora $9
        sta $9
.b2done
        
        
        
	jmp DrawRect


DrawDirt:
        ldx #0
.search lda collist,x
        beq .foundempty
        inx
        inx
        inx
        inx
        jmp .search
.foundempty

        lda lvldat,y
        sta func0
        sta collist,x

	iny
        inx
        lda lvldat,y
        sta func1
	sta collist,x

	iny		; repeat here. loop it
	lda lvldat,y
        lsr
        lsr
        lsr
        lsr
        sta func2
	dex
        clc
	adc collist,x
        inx
        inx
        sta collist,x

        lda lvldat,y
	and #$0f
        sta func3
        dex
        clc
        adc collist,x
        inx
        inx
        sta collist,x

        iny
        tya
        pha
        
        lda #$0f
        sta func4
        
        lda #$00
        sta func5

        
DrawRect:	; 0-1 yx, 2 height, 3 width, 4 sides, 5 corners, 6-7 ppu addr, t0 onflags, t1 block

	lda func0
        cmp #30
        bcc .screen
        sec
        adc #$22	; ready for shifting to become ppu 2000 or 2800
.screen
	clc
        ror		; this should be a subroutie 0-1 -> 6-7
        ror
        ror
        ror
        sta func6
	and #$e0
        ora func1
        sta func7
        lda func6
        rol
        and #$0f
        ora #$20
        sta func6

	ldy func2


.cube      
        lda func6
        sta PPU_ADDR
        lda func7
        sta PPU_ADDR
        lda #0

	cpy #0		; setting two high bits of on flags
        bne .yntop
        lda #$4
        jmp .ydone
.yntop	cpy func2
	bne .ydone
        lda #$8
.ydone	sta tmp0
        
        ldx func3
        
.row    lda tmp0		; setting two low bits of on flags
	and #$fc
        cpx #0
	bne .xnleft
	ora #$1
        jmp .xdone
.xnleft	cpx func3
	bne .xdone
        ora #$02
.xdone	sta tmp0

	and func4
        bne .nzero
        lda #$3
        bit tmp0
        beq .nincor
        lda #$c
        bit tmp0
        beq .nincor
        jmp .midway
        
        
        ; midway point
.mback	bpl .cube        
        
        
        ; if corner and sides not set, convert to inner
.midway lda #$08
        bit tmp0
        beq .fzero
.fone   lda #$0f
	eor tmp0
        asl
        asl
        eor #$13
	jmp .fdone
.fzero	lda #$08
	clc
	adc tmp0
.fdone	sta tmp1
	ora func5
        cmp #$0f
        bne .nincor
        lda tmp1
        bne .nzero	; jump if defined!
		
.nincor	lda #0
.nzero
	clc
        adc #1
	sta PPU_DATA
	dex
        bpl .row
        
        lda func7
        clc
        adc #$20
        sta func7
        lda func6
        adc #0
        
        cmp #$24
        bcc .nscreen1
        cmp #$28
        bcs .nscreen1
        lda #$28
.nscreen1
        sta func6      
        
        dey
        bpl .mback      
        
        pla
        tay
	rts
        
UpdateSprites: subroutine

	; code to clear oam before drawing



	ldx #0 ; object list
        ldy #0 ; oam
.next
	lda objlist,x
        bne .draw
	rts
.draw	and #$3f
        sec
        asl
        asl
        asl
        sbc scroll
        bpl .notthisone
        lda #$ff
.notthisone   
        sta $210,y
        inx
        iny
        lda objlist,x
        rol
        rol
        rol
        rol
        and #$7
        clc
        adc #$20
        sta $210,y
        iny
        iny
        lda objlist,x
        and #$1f
        clc
        asl
        asl
        asl
        sta $210,y
        inx
        iny
        jmp .next
        