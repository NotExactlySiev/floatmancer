;;; Code for handling scripted events

SequenceFrame: subroutine
	ldx sqtimer
        dex
        beq .advance
        stx sqtimer
        rts
.advance
        
	
.checkseq
	ldy sqidx
        lda sequence,y
        bne .nend	; are we in a sequence?
     	rts
.nend
        bmi .getmem	; is it just a simple set/offset?
        cmp #$20
        bcs .nwait	; is it a control command?
        sta sqtimer
        iny
        sty sqidx
        rts
        
.nwait	cmp #$40
	bcs .ncall	; is it a call command?
        iny
        sty sqidx
        and #$1f
        tax
        jsr CallFromTable
        jmp .checkseq
        
.ncall	cmp #$60
        bcs .nplay	; is it a play command?
        ;; play code goes here
.nplay	
	; if we reach here it's a set memory address command
	; set the memory address and continue like a simple set/offset

        and #$1f
        sta tmp0
        iny
        lda sequence,y
        sta tmp1
        rol
        rol
        and #$1
        tax
        lda tmp1
        and #$3f
        sta sqvar0,x
        jmp .setval

.getmem
	sta tmp1
	and #$1f
        sta tmp0
        lda sequence,y
	rol
        rol
        rol
        rol
        and #$1
        tax
.setval

	
        lda sqvar0,x
	tax

	lda tmp0
	bit tmp1
        bvs .offset
        
        sta $0,x
        jmp .opdone
.offset
	clc
        adc $0,x
        sta $0,x
        jmp .opdone
	

.reset

.opdone
	iny
        sty sqidx
        bne .checkseq

PlaySequence: subroutine
	ldy SequencesTable,x
	ldx #$ff
        txa
        pha
        dey
.copy
	iny
        inx
	lda Sequences,y
        sta tmp3
        and #$e0
        cmp #$40
        bne .nnest
	; put the return index into stack and continue from new index
        tya
        pha
        lda tmp3
        and #$1f
        tay
        lda SequencesTable,y
        tay
        dex
        dey
	bne .copy
.nnest
	lda tmp3
        sta sequence,x
        bne .copy
	; if here, either a nest is closed or we're done
	pla
        cmp #$ff
        beq .done
        dex
        tay
        bne .copy
.done        


	ldy #0
        sty sqidx
        iny
        sty sqtimer
        rts