FindLevel: subroutine ; find lvlptr for lvl at func0
        ldy #0
        ldx func0
        txa
        sec
        sbc lvl
        bpl .seekforward
        ; if we're past the level, reset to level 0 and start the search
        lda #<LEVEL_HEAD
        sta lvlptr
        lda #>LEVEL_HEAD
        sta lvlptr+1
        txa
.seekforward
	; otherwise only go forward by (target level - current level)
        tax
        
.nextlevel
	beq .out
        lda (lvlptr),y
        and #$3f
        clc
        adc #3
        clc
        adc lvlptr
        sta lvlptr
        lda lvlptr+1
        adc #0
        sta lvlptr+1
        dex
        jmp .nextlevel        
.out    
	lda func0
        sta lvl
	rts
	

ClearLevel: subroutine
	lda #$20
        sta PPU_ADDR
        lda #0
        sta PPU_ADDR
        
        ldx #$ff
.loop   
	ldy #12
.innerloop
        sta PPU_DATA
        dey
        bne .innerloop        
        dex
        bne .loop
        
        ldx #$20
.clearzp
        sta $0,x
        inx
        bne .clearzp
        rts
        


LoadLevel: subroutine	; load level data and metadata from level pointer
        ldy #0
        lda (lvlptr),y
        lsr
        lsr
        ora (lvlptr),y
        and #$f0
        sta scroll
        
        lda (lvlptr),y
        and #$3f
        tax
        inx
        stx lvlsize
        
        iny
        lda (lvlptr),y
        and #$1f
        asl
        asl
        asl
        sta px0
        lda (lvlptr),y
        and #$e0
        sta py0
        
        ldy lvlsize
        iny
        ldx lvlsize
        dex   
        
.copy   lda (lvlptr),y
        sta lvldat,x
        dey
        dex
        bpl .copy
	
        lda #-1
        sta blknum

	rts


RenderLevel: subroutine
      	ldy #0
NextItem:
        lda lvldat,y
        cpy lvlsize
        bne .nend
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


DrawInner: subroutine
        lda #%00110000
        sta func5
        
        lda lvldat,y
        sta filbyte
                
        ; set sides right away
        and #$0f
        sta func4
        
        tya
        pha
        
	; load the two overlapping rects
        lda filbyte
        asl
        asl
        sta filbyte
        
        lda blknum	; put 1 in x, 2 in y
        tax
        dex
        bit filbyte
        bvc .oneback
        dex
.oneback
        asl
        asl
        tay
        txa
        asl
        asl
        tax
        
        ; y coordinate for the fill is always y2
        lda collist,y
        sta func0      
        
        inx
        iny
        
        lda collist,y	; compare x2 and x1
        cmp collist,x
        bcs .x1first
        lda #%10000000
        ora func5
        sta func5
        lda collist,x
.x1first
        sta func1
        
        
        inx
        iny
	
        lda collist,y
        cmp collist,x
	bcc .ye2first
        lda #%00110000	; later will be xor'd with a shifted one, setting the last two bits
        eor func5
        sta func5
        lda collist,x
.ye2first
	sec
        sbc func0
        sta func2
        
        inx
        iny
        
        lda collist,y
        cmp collist,x
        bcc .xe2first
        lda #%01000000
        ora func5
        sta func5
	lda collist,x
.xe2first
	sec
        sbc func1
        sta func3
 
	lda func5
        lsr
        lsr
        eor func5
        lsr
        lsr
        lsr
        lsr
        sta func5
              
	jmp DrawRect


DrawDirt:
        inc blknum
        ldx #0
.search lda collist,x
        beq .foundempty
        inx
        inx
        inx
        inx
        jmp .search
.foundempty

        lda lvldat,y	; put block data in collist
        sta func0
        sta collist,x

	iny
        inx
        lda lvldat,y
        sta func1
	sta collist,x

	iny
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

        lda lvldat,y	; pass level data for DrawRect function
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
        
        lda #$0f	; constant arguments for dirt block
        sta func4
        
        lda #$00
        sta func5

        
DrawRect: subroutine	; 0-1 yx, 2 height, 3 width, 4 sides, 5 corners, 6-7 ppu addr, t0 onflags, t1 block
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
        
.row    lda tmp0	; setting two low bits of on flags
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
        
        lda func7		; go to the next row
        clc
        adc #$20
        sta func7
        lda func6
        adc #0

	cmp #$24		; if entered nametable 2, jump straight to 3
        bne .nchangescreen
        lda #$28
.nchangescreen
        sta func6      


        dey
        bpl .mback      
        
        pla
        tay
	rts
        
	; handles scrolling the sprites on the screen. hero sprite handled seperately
UpdateSprites: subroutine

	; clear oam objects before drawing
	lda #0
        ldx #$10
.clearoam
        sta $0200,x
        inx
        bne .clearoam
	
	lda scroll
        lsr
        sta tmp0

	ldx #0 ; object list
        ldy #0 ; oam
.next
	lda objlist,x
        bne .draw
	rts
.draw	
	clc
        asl
        asl
	sec
        sbc tmp0
        cmp #120
        bcc .onscreen
        lda #$ff       
.onscreen
	clc
	asl
	sta $210,y	; set y pos
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
        sta $210,y	; set sprite index
        iny
        bit flags
        bpl .normalcolor
        cpy hookidx
        bne .normalcolor
        lda #2
        sta $210,y
.normalcolor
        
        iny
        lda objlist,x
        and #$1f
        clc
        asl
        asl
        asl
        sta $210,y	; set x pos
        inx
        iny
        jmp .next
        