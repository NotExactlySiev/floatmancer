	; 0-1 xy, 2-3 txt addr, 6-7 ppu addr
DrawText: subroutine
	jsr PPUFormat
        lda func6
        sta PPU_ADDR
        lda func7
        sta PPU_ADDR
        
        ldy #0
.print
        lda (func2),y
        beq .out
        sta PPU_DATA
        iny
        bne .print
.out        
	rts