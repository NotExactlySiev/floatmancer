
        lda #SCREEN_HEIGHT-SCROLL_THOLD
	cmp py0
        bcc .scrolldown
        lda py0
        cmp #SCROLL_THOLD
        bcc .scrollup
        jmp .scrollover
        
.scrolldown

        lda scroll
        cmp #240
        beq .scrollover
        
        lda py0
        sec
        sbc #SCREEN_HEIGHT-SCROLL_THOLD
        sta func0
        
        clc
        adc scroll
        cmp #241
        bcc .noverflow
        lda #240
        sec
        sbc scroll
        sta func0
.noverflow        
        jmp Scroll
        
        
.scrollup
	lda scroll
        beq .scrollover
        
        lda py0
        sec
        sbc #SCROLL_THOLD
        sta func0
        
        clc
        adc scroll
        bpl .nunderflow
        lda #0
        sec
        sbc scroll
        sta func0        
.nunderflow
        

Scroll:
        lda func0
        beq .scrolldone		; don't do calculation if disposition is 0
        clc
        adc scroll
	sta scroll
        lda py0+$20
        sec
        sbc func0
        sta py0+$20        
        lda hookpy
        sec
        sbc func0
        sta hookpy
        lda py0
        sec
        sbc func0
        sta py0
	

.scrolldone
	jsr UpdateSprites
        
.scrollover