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



	lda #0
	sta relpx0
        sta relpy0
        
        lda angle0
        bpl .check1
        eor #$ff
        clc
        adc #1
.check1	asl
	bpl .check2
        eor #$ff
        clc
        adc #10
.check2	lsr
	
        sta relpy0
        
        lda radius
        sec
        sbc #9
        asl
        asl
        clc
        adc relpy0
        asl
        tax
        lda $B000,x
        sta relpy0
        inx
        lda $B000,x
        sta relpy1
        
        
        lda relpy0
        clc
        adc hookpy
        sta py0
