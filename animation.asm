       
        lda flags	; RUNNING ANIMATION
        eor #%11000000
        and #%11000001
        cmp #%11000001
        bne .nrunning
	
	dec ftimer
        bne .sameframe
        lda #4
        sta ftimer
        lda $201
        clc
        adc #1		; next frame
        cmp #$6
        bne .nwrap
        lda #$2 	; wrap around
.nwrap  
	sta $201
.sameframe
        lda #1
        bit $201
        beq .nobobbing
        dec $200
.nobobbing      
        jmp .spritedone
.nrunning


        bit flags	; FALLING ANIMATION
        bvc .nrising
        lda #$3
        ldx jtimer
        cpx #3
        bcs .jwindup
        lda #$10
.jwindup
        sta $201
        bne .spritedone
.nrising


	lda #$0		; IDLE ANIMATION
        sta $201
	lda #1
        sta ftimer
