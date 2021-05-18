CheckCollision:		; check for collision, 0-1 -> y,x
        ldx #0
        
.checkrect        
        lda $c0,x
        bne .ndone
        lda #0
        sta func2
        rts
.ndone

	lda func0
        clc
        cmp $c0,x
        bcc .not1
	inx 
        lda func1
        clc
        cmp $c0,x
        bcc .not2
        inx
        
        lda $c0,x
        clc
        cmp func0
        bcc .not3
        inx
        lda $c0,x
        clc
        cmp func1
        bcc .not4
        
        lda #1
        sta func2
        rts
        

.not1	inx
.not2	inx
.not3	inx
.not4	inx

	jmp .checkrect