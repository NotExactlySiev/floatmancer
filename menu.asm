LoadMenu: subroutine
        jsr ClearState
        
        ldx #$3f
	PPU_SETADDR $23C0
.attr
	lda #$55
        sta PPU_DATA
        dex
        bne .attr
        
        lda #$24
        sta func0
        sta PPU_ADDR
        lda #$a7
        sta func1
        lda #$8a
        sta PPU_ADDR
        
        ldx #$b6
.title
        stx PPU_DATA
        inx
        cpx #$c2
        bcc .title


	ldx #$80
.logo
	lda func0
        sta PPU_ADDR
        lda func1
        sta PPU_ADDR
        
	ldy #18
.row        
        stx PPU_DATA
        inx
        dey
        bne .row
        lda func1
        clc
        adc #$20
        sta func1
        bcc .logo
        
        lda #$21
        sta PPU_ADDR
        lda #$15
        sta PPU_ADDR
        ldx #$c2
        stx PPU_DATA
        inx
        stx PPU_DATA
        
        
        lda #25
        sta func0
        lda #16
        sta func1
        lda #<TXT_Credits
        jsr DrawText
        
        ldx #29
.loop
	lda MenuOptions,x
        sta options,x
        dex
        bpl .loop
        
        lda #STATE_MENU
        sta state
        lda #MENU_ITEMS-1
        sta select
        
	lda #0
        sta PPU_ADDR
        sta PPU_ADDR
	
        
        rts

MiliLow:
	.byte 0, 2, 3, 5, 7, 8

UpdateMenu: subroutine
	; experimenting with a timer
	ldx foff
        inx
        cpx #6
        bne .nover
        ldy mil0
        iny
        cpy #10
        bcc .milnover
        ldy sec1
        iny
        cpy #10
        bne .lsecnover
        inc sec0
	ldy #0
.lsecnover
        sty sec1
        ldy #0
.milnover
	sty mil0
        ldx #0
.nover
        stx foff

	lda #$20
        sta PPU_ADDR
        lda #$44
        sta PPU_ADDR
        lda sec0
	ora #$70
        sta PPU_DATA
        lda sec1
	ora #$70
        sta PPU_DATA
        lda #$61
        sta PPU_DATA
        lda mil0
        ora #$70
        sta PPU_DATA
        ldx foff
        lda MiliLow,x
        ora #$70
        sta PPU_DATA

	clc
        lda world
        asl
        asl
        tax
        
        ldy #4
.world
	lda Worlds,x
        sta options,y
        inx
        dey
        bne .world
        
        lda #$21
        sta func6
        lda #$63
        sta func7
        
        
        
        ldy #$ff
	ldx #MENU_ITEMS-1
.loop
        lda func6
        sta PPU_ADDR
        lda func7
        sta PPU_ADDR
        
        lda #0
        cpx select
        bne .nthis
        lda #$5f
.nthis
	sta PPU_DATA
        bit PPU_DATA

.caption
	iny
        lda options,y
        beq .out
        sta PPU_DATA
        bne .caption
.out

        lda func7
        clc
        adc #$40
        sta func7
        lda func6
        adc #0
        sta func6
        dex
        bpl .loop
        
        
        lda #0
        sta PPU_ADDR
        sta PPU_ADDR
        rts