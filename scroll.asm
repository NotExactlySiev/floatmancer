	
        
        lda py0
        clc
        adc scroll
        sta realpy0

	lda scroll
        cmp scroll+$20
        beq .nscroll
        jsr UpdateSprites
.nscroll
        

	
        
        
        
.spritesdone
        