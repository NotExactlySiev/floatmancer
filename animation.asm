	lda px0
        sec
        sbc #4
        sta $203
        lda flags	; RUNNING ANIMATION
        eor #%11000000
        and #%11000001
        cmp #%11000001
        bne .nrunning
        lda $201
        cmp #$10	; if just started running, start at frame $12
        bne .already
        lda #$11
        sta $201
.already
	dec ftimer
        bne .sameframe
        lda #5
        sta ftimer
        lda $201	; wrap around
        clc
        adc #1
        cmp #$15
        bne .nwrap
        lda #$11
.nwrap        
.sameframe
	sta $201
        lda #1
        bit $201
        bne .nobobbing
        dec $200
.nobobbing      
        jmp .spritedone
.nrunning
	
        bit flags	; FALLING ANIMATION
        bvc .nfalling
        lda #$14
        sta $201
        bne .spritedone
.nfalling
	lda #$10	; IDLE ANIMATION
        sta $201
	lda #6
        sta ftimer
