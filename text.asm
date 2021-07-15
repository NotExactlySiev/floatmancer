	; 0-1 xy, 6-7 ppu addr, text addr low byte in A
DrawText: subroutine
	sta func2
        lda #$ff
        sta func3
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