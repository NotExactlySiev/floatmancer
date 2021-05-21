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
        sty $3
NextItem:
        lda $80,y
        bne .nend
        ldx #$0f
.clean  sta $10,x
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
        ldy $3
        jmp NextItem
.nblock
        iny
        jmp NextItem
        lda #0

        rts

DrawBlock: subroutine
        lda $80,y
        sta $4
        iny
        lda $80,y
        sta $5
        iny
        sty $3

	ldy #0
.findoam
	lda $0280,y
        beq .oamempty
        iny
        iny
        iny
        iny
        jmp .findoam
        
.oamempty       
        ldx #0
.find   lda $f0,x
        beq .empty
        inx
        inx
        jmp .find

.empty  
	lda $4
        clc
        asl
        asl
        asl
        sta $0280,y
        clc
        adc #4
        sta $f0,x
        
        iny
        lda $5
        rol
        rol
        rol
        rol
        and #$7
        ora #$80
        sta $0280,y
        iny	; temporary. do stuff here later
        iny
        inx
        
        lda $5
        clc
        asl
        asl
        asl
        sta $0280,y
        clc
        adc #4
        sta $f0,x
        rts


DrawInner:
        lda $80,y
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
        lda $33
        sta $36
        lda $34
        sta $37
        lda $35
        sta $38
        
        lda $30
        sta $33
        lda $31
        sta $34
        lda $32
        sta $35
        
        lda $80,y
        sta $4
        sta $30
        iny
        lda $80,y
        sta $5
        sta $31
        iny
        lda $80,y
        sta $32
        and #$0f
        sta $6
        lda $80,y
        lsr
        lsr
        lsr
        lsr
        sta $7
        iny
        sty $3
        
        lda #$00
        sta $9
        
        lda #$0f
        sta $8
        sta $9
                
        ; convert and put it in the collision table
        ldx #0
.search lda $c0,x
        beq .foundempty
        inx
        inx
        inx
        inx
        jmp .search
.foundempty
        
        lda $4
        clc
        asl
        asl
        asl
        sta $20
        lda $5
        lsr
        lsr
        lsr
        lsr
        lsr
        ora $20
        sta $20
        
        lda $5
        and #$1f
        sta $21
        
        lda $6
        clc
        adc $21
        sta $23
        
        lda $7
        clc
        adc $20
        sta $22
        
        lda $20
        sta $c0,x
        inx
        lda $21
        sta $c0,x
        inx
        lda $22
        sta $c0,x
        inx
        lda $23
        sta $c0,x
        
        
        
DrawRect:

	ldy $7
.cube	lda $4
        sta PPU_ADDR
        lda $5
        sta PPU_ADDR
        lda #0
        cpy #0		; setting two high bits of a
        bne .yntop
        lda #$4
        jmp .ydone
.yntop	cpy $7
	bne .ydone
        lda #$8
.ydone	sta $a
        
        ldx $6
        
.row    lda $a		; setting two low bits of a
	and #$fc
        cpx #0
	bne .xnleft
	ora #$1
        jmp .xdone
.xnleft	cpx $6
	bne .xdone
        ora #$02
.xdone	sta $a

	and $8
        bne .nzero
        lda #$3
        bit $a
        beq .nincor
        lda #$c
        bit $a
        beq .nincor
        jmp .midway
        
        
        ; midway point
.mback	bpl .cube        
        
        
        ; if corner and sides not set, convert to inner
.midway lda #$08
        bit $a
        beq .fzero
.fone   lda #$0f
	eor $a
        asl
        asl
        eor #$13
	jmp .fdone
.fzero	lda #$08
	clc
	adc $a
.fdone	sta $b
	ora $9
        cmp #$0f
        bne .nincor
        lda $b
        bne .nzero	; jump if defined!
		
        bne .nzero
.nincor	lda #0
.nzero
	clc
        adc #1
	sta PPU_DATA
	dex
        bpl .row
        
        clc
        lda #$20
        adc $5
        sta $5
        lda $4
        adc #0
        sta $4
        dey
        bpl .mback      
        
        ldy $3
	rts