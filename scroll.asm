
        lda #SCREEN_HEIGHT-SCROLL_THOLD
	cmp py0
        bcc .scrolldown
        lda py0
        cmp #SCROLL_THOLD
        bcc .scrollup
        jmp .scrolldone
        
.scrolldown

        lda py0
        sec
        sbc #SCREEN_HEIGHT-SCROLL_THOLD
        sta tmp0

        clc
        adc scroll
        cmp #$f0
        bcc .nbottom
        lda #$f0
        sec
        sbc scroll
        sta tmp0
.nbottom
        
        lda tmp0
        beq .scrolldone		; don't do calculation if disposition is 0
        clc
        adc scroll
	sta scroll
        lda py0+$20
        sec
        sbc tmp0
        sta py0
        lda hookpy+$20
        sec
        sbc tmp0
        sta hookpy
        lda #SCREEN_HEIGHT-SCROLL_THOLD
        sta py0
	
.scrollup
	

.scrolldone
	jsr UpdateSprites