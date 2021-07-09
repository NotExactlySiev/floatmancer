;;; Code for handling scripted events

SequenceFrame: subroutine
	ldx sqtimer
        dex
        bmi .advance
        stx sqtimer
        rts
.advance
        
.checkseq
        ldx sqidx
        lda sequence,x
        bne .nend	; are we in a sequence?
     	rts   
.nend
        bmi .getmem	; is it just a simple set/offset?
        cmp #$20
        bcs .nwait	; is it a control command?
        
.nwait	cmp #$40
	bcs .ncall	; is it a call command?
        
.ncall	cmp #$60
        bcs .nplay	; is it a play command?
.nplay	
	; if we reach here it's a set memory address command
	; set the memory address and continue like a simple set/offset

        and #$1f
        sta tmp0
        inx
        lda sequence,x
        sta tmp1
        rol
        rol
        and #$1
        tay
        lda tmp1
        and #$3f
        sta sqvar0,y
        jmp .setval

.getmem
	sta tmp1
	and #$1f
        sta tmp0
        lda sequence,x
	rol
        rol
        rol
        rol
        and #$1
        tay
        

.setval
	lda tmp0
	bit tmp1
        bvs .offset
        
        sta (sqvar0,y)
        jmp .opdone
.offset
	clc
        adc (sqvar0,y)
        sta (sqvar0,y)
        jmp .opdone
	

.reset

.opdone
	inx
        bne .checkseq
