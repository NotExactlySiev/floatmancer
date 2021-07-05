	; x = palette address, darkens and writes to a+$12
        
LoadPalette: subroutine
	ldx #$19
.loop	; first load the base palette
	lda CastlePalette,x
        sta basepalette,x
        dex
        bpl .loop
        
	ldx #0
.loop2	; then darken it step by step
	lda basepalette,x
        tay
        and #$30
        bne .ndark
        tya
        and #$f
        tay
        lda HueShift,y
        bpl .found
.ndark
	tya
        sec
        sbc #$10
.found
        sta basepalette+25,x
        inx
        cpx #100
        bne .loop2
        
        rts

	; set darkness equal to $180, 0-5, 5 is black
SetDarkness: subroutine
	PPU_SETADDR $3f00
        ldy darkness
        ldx DarkTable,y
        ldy #0
.loop
        lda $100,x	; some voodoo magic shit that skips mirrors in pallete addresses
        sta PPU_DATA
        inx       
        iny
        tya
        and #$3		; if is divisible by 4, it's a mirror so skip to the next address
        bne .loop
        lda PPU_DATA
        iny
        cpy #$21
        bne .loop
        
        rts
