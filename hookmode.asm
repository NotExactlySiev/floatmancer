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


	ldx #1	; if should be negative changes to 0
	lda #0
	sta relpx0
        sta relpy0
        
        lda angle0
        bpl .check1
        dex
        eor #$ff
        clc
        adc #1
.check1	
	asl
	bpl .check2
        eor #$ff
        clc
        adc #2
.check2	lsr
	
	sta relpy0	; look up angle is saved here temporarily

	cmp #$40
	bne .nright
	lda radius
        sta relpy0
        lda #0
        sta relpy1
	jmp .done
        
.nright lda radius
	lsr
        clc
        adc #$b0
        sta sinptr+1
        
        lda relpy0
        clc
        asl
        sta sinptr
        
        lda radius
        and #$1
        ror
        ror
        clc
        adc sinptr
        sta sinptr
        
        ldy #0
        lda (sinptr),y
        sta relpy0
        iny
        lda (sinptr),y
        sta relpy1
        
.done	dex
	beq .positive
        clc
        lda relpy1
        eor #$ff
        adc #1
        sta relpy1
        lda relpy0
        eor #$ff
        adc #0
        sta relpy0
        
.positive
        lda relpy0
        clc
        adc hookpy
        sta py0
