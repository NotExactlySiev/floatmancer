CheckCollision:		; check for collision, loads $2 and $3 for x and y
        lda $3
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        ora #$20
        sta PPU_ADDR

        lsr $2
        lsr $2
        lsr $2
        
        lda $3
        asl
        asl
        and #$e0
        ora $2
        sta PPU_ADDR
        
        lda PPU_DATA
        
        beq .nsolid
        cmp #$10
        bcs .nsolid
	lda #1
	jmp .cend
.nsolid lda #0
        
        
        
.cend   sta $2
	lda #0
        sta PPU_ADDR
        sta PPU_ADDR
	rts