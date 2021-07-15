LoadMenu: subroutine
	
        PPU_SETADDR $23C0
        jsr ClearState
        
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
        cpx #$c8
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
        
        lda #10
        sta func0
        sta func1
        lda #$73
        jsr DrawText
        
        lda #25
        sta func0
        lda #16
        sta func1
        lda #$64
        jsr DrawText
        
        
        
        lda #1
        sta state
        lda #MENU_ITEMS-1
        sta select
        
	lda #0
        sta PPU_ADDR
        sta PPU_ADDR
	
        
        rts

UpdateMenu: subroutine
	lda #$21
        sta func6
        lda #$44
        sta func7
        
	ldx #MENU_ITEMS
.loop
        lda func6
        sta PPU_ADDR
        lda func7
        sta PPU_ADDR
        
        ldy #0
        cpx select
        bne .nthis
        ldy #$5f
.nthis
	sty PPU_DATA
	
        
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