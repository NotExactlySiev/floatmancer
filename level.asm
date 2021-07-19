FindLevel: subroutine ; find lvlptr for lvl at func0
        ldy #0
        ldx func0
        txa
        sec
        sbc lvl
        bpl .seekforward
        ; if we're past the level, reset to level 0 and start the search
        lda #0
        sta lvlptr
        lda #LEVEL_HEAD
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
        ldx #$ff
        stx hookidx
        inx
        stx PPU_ADDR
        sta PPU_ADDR
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



RenderLevel: subroutine	; draw the background parts of the level, load the collision
			; and object (sprite) data into appropriate tables
        ; first we draw the elements common among all levels
        ldx #59
        stx func2
        ldx #2
        stx func3
        dex
        stx func4
        dex
        stx func0
        stx func1
        stx func5
        jsr DrawWall
        ldx #29
        stx func1        
        asl func4
        jsr DrawWall
        
	ldy #0
NextItem:
        cpy lvlsize
        bcc .nend
        rts
.nend   
	lda lvldat,y	; special cases that set the variables on their own
        and #$e0
        tax
        bne .nFIL
        jsr DrawFill
        jmp NextItem
.nFIL
        
        cmp #$20
        bne .nBLK
     	jsr DrawBlock
        jmp NextItem
.nBLK
        lda lvldat,y	; if it's not a block or fill, set the position for now
        sta func3
        and #$1f
        sta func1
              
        iny
        lda lvldat,y
        sta func2
        and #$3f
        sta func0
        
        ; at this point, 0 = y, 1 = x, x = upper nybble not shifted
        
        txa
        bpl .nsprite
        jsr DrawObject
	jmp NextItem
.nsprite
        jsr PPUFormat	; if it's 01000-01111, we need ppu address
        txa
        cmp #$40
        bne .nspike
        jsr DrawSpike
        jmp NextItem
.nspike	
	
        ; upper nybble fully checked. cheking lower nybble now to narrow it down
        lda func2
        and #$c0
        
	

        jmp NextItem


DrawSpike: subroutine
	lda func6
        sta PPU_ADDR
        lda func7
        sta PPU_ADDR
        
	ldx #collist
        jsr FindEmptyZp
        stx func5	; keep for later, when x is uncertain

	lda func0
        sta $0,x
        sta $2,x
        lda func1
        sta $1,x
        sta $3,x
        inx
        
        lda func2
        bpl .horiz
        lda #4
        sta PPU_CTRL
        dex
.horiz
	iny
        lda lvldat,y
        pha		; save it to use for drawing later
        sec
        adc $0,x
        inx
        inx
        sta $0,x
       
        ldx func5
        lda func2	; set the horizontal or vertical direction of deadly ocol
        and #$80
        lsr        
        ora #$80
        ora $3,x
        sta $3,x

	pla
        tax

	lda func2	; setting up for drawing
        rol
        rol
        rol
        and #$3
        clc
        adc #$20
	sta PPU_DATA
        
        adc #4

.draw        
        dex
        bmi .drawdone
        sta PPU_DATA
        bpl .draw     
.drawdone

	adc #4
        sta PPU_DATA

        lda #0
        sta PPU_CTRL
        
        iny
        rts

DrawObject: subroutine ; puts sprite objects into the table, doesn't change 
        ldx #objlist
        jsr FindEmptyZp
        
	lda func0	; set y pos
        sta $0,x
        inx
        
        lda func3	; set object type
        and #$e0
        lsr
        lsr
        lsr
        sta $0,x
        lda func2
        rol
        rol
        rol
        and #$3
        ora $0,x
        sta $0,x
        inx

        lda func1	; set x pos
        and #$1f
        sta $0,x

	iny
        rts

	;just to put something in the stack so when drawrect pulls out it doesn't crash
DrawWall: subroutine
	pha
        jmp DrawRect

DrawFill: subroutine
        lda #0
        sta func5
        
        lda lvldat,y
        sta filbyte
                
        ; set sides right away
	and #$7
        tax
        
        and #$2
        ; this is some voodoo that maps the 8 possible values into the 4 bit ones we need one to one
	bne .oneside
        txa
        asl
        ora $700,x
        and #$f
        bcc .sidesdone
.oneside
	txa
        lsr
        eor filbyte
        and #$3
        tax
        sec
        lda #0
.shift	rol
	dex
        bpl .shift       
.sidesdone
	sta func4
        
        iny
        tya
        pha
        
	; load the two overlapping rects
        
        lda blknum	; put 1 in x, 2 in y
        tax
        tay
        dex
        lda #$8
        bit filbyte
        beq .oneback
        dex
.oneback
	tya
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
        lda #%00001000
        sta func5
        lda collist,x
.x1first
        sta func1
        
        
        inx
        iny
	
        lda collist,y
        cmp collist,x
	bcc .ye2first
        lda #%00000010	; later will be xor'd with a shifted one, setting the last two bits
        ora func5
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
        lda #%00000100
        ora func5
        sta func5
	lda collist,x
.xe2first
	sec
        sbc func1
        sta func3
 
	lda func5	; lol this actually worked
        lsr
        tax
        lsr
        lsr
        eor $700,x
        and #$3
        eor func5
        sta func5
              
	jmp DrawRect


DrawBlock:
        inc blknum
        ldx #collist
	jsr FindEmptyZp ; find empty in collision list

	inx

        lda lvldat,y	; put block data in collist
        and #$1f
        sta func1
        sta $0,x

	iny
        dex
        lda lvldat,y
        and #$3f
        sta func0
	sta $0,x
        
        inx
        inx
	iny
	lda lvldat,y
        and #$0f
        sta func2
        clc
        adc func0
        sta $0,x
        
        inx
        lda lvldat,y
        lsr
        lsr
        lsr
        lsr
        sta func3
        clc
        adc func1
        sta $0,x
        

        
        lda #$0f	; constant arguments for dirt block
        sta func4
        
        lda #$00
        sta func5
        
	iny
        tya
        pha

        
DrawRect: subroutine	; 0-1 yx, 2 height, 3 width, 4 sides, 5 corners, 6-7 ppu addr
			; t0 onflags, t1 block, t2 rowparity, t3 cellparity
	jsr PPUFormat
	
        ldy func2

	lda func0
        and #1
        sta tmp2

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
        
        lda func1
        and #1
        sta tmp3
        
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
        ; if corner and sides not set, convert to inner
	lda #$08
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
        
        
        sta tmp1    ; check parity and add $10 for odd cells
        lda tmp2
        clc
        adc tmp3
	asl
        asl
        asl
        asl
        and #$10
        clc
        adc tmp1
        
        
        
.drawblock
	sta PPU_DATA
        inc tmp3
	dex
        bpl .row
        
        lda func7		; go to the next row
        clc
        adc #$20
        sta func7
        lda func6
        adc #0
        sta func6

	cmp #$23		; if entered nametable 2, jump straight to 3
        bne .nchangescreen
        lda func7
        cmp #$c0
        bcc .nchangescreen
        lda #$28
        sta func6
        lda func7
        and #$1f
        sta func7
.nchangescreen

	inc tmp2
        dey
        bmi .out
        jmp .cube

.out
        pla
        tay
	rts
        
