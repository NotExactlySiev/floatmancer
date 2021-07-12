LoadMenu: subroutine
	
        lda #8
        sta func0
        lda #4
        sta func1
        lda #00
        sta func2
        lda #$ff
        sta func3
        jsr DrawText

	rts
