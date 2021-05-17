
	lda #10
        sta func2
        
        lda angle0
        sta func0
        lda angle1
        clc
        adc #$40
	sta func1
        jsr CalcSin
        
        ldx #0
        lda func6
        bpl .pos
    	ldx #$ff    
.pos
        stx func5
        
        clc
        lda func7
	adc omega2
        sta omega2
        lda func6
        adc omega1
        sta omega1
        lda func5
        adc omega0
        sta omega0

	; adjusting rotation speed

        clc
        lda angle2
        adc omega2
        sta angle2
        lda angle1
        adc omega1
        sta angle1
        lda angle0
        adc omega0
        sta angle0



	; positioning
        
        lda radius
        sta func2
        
        lda angle0
        sta func0
        lda angle1
        sta func1
        
        jsr CalcSin
        
        lda func6
        sta relpy0
        
        lda angle0
        clc
        adc #$40
        sta func0
        lda angle1
        sta func1
        
	jsr CalcSin
        
        lda func6
        sta relpx0



        lda relpy0
        clc
        adc hookpy
        sta py0
	lda relpx0
        clc
        adc hookpx
        sta px0		; rel x and y are inverted!!