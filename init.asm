	; wait for PPU warmup, clear CPU RAM
	NES_INIT
        jsr WaitSync
        jsr ClearRAM
        jsr WaitSync
	
        jsr ClearLevel
        
        ldx #0
        stx OAM_ADDR
.self
	txa
	sta $700,x
	inx
        bne .self

        ; ppu setup
        lda #0
        sta darkness
        jsr LoadPalette
        jsr SetDarkness

	jsr LoadMenu
        
        ; enable rendering, nmi
        lda #$88
        sta PPU_CTRL
        lda #$1E
        sta PPU_MASK