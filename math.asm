CalcSin: subroutine	; 0-2 angle0, angle1, multiplier -> 6-7 sin value
        lda #0
        sta func3
        
        lda func0
        bpl .check1
        
        lda func1
        eor #$ff
        clc
        adc #1
        sta func1
        lda func0
        eor #$ff
        adc #0
        sta func0
        
        lda #1
        sta func3
        
.check1	lda func0
	asl
	bpl .check2
        
        lda func1
        eor #$ff
        clc
        adc #1
        sta func1
        lda func0
        eor #$7f
        adc #0
        sta func0
.check2

	lda func0
        cmp #$40
        bne .nright
        lda func1
        and #$c0
        bne .nright
        
        ; if it's 90 degrees
        lda func2
        sta func6
        lda #0
        sta func7
        rts
        
.nright ; else
        lda func2
        clc
        adc #$b0
        sta func5

	lda func0
        
        clc
        asl
        asl
        asl
        bcc .nbig
	inc func5
.nbig
	sta func4
        
	lda func1
        rol
        rol
        rol
        rol
        and #$06
        ora func4
        sta func4

        ldy #0
        lda (func4),y
        sta func6
        iny
        lda (func4),y
        sta func7

.lookupover
	       
        lda func3
        beq .positive
	clc
        lda func7
        eor #$ff
        adc #1
        sta func7
        lda func6
        eor #$ff
        adc #0
        sta func6                
.positive        
	rts

; for pytanlookups, 0-1 legs, 2-3 rowcol, 4-5 ptrs, 6 result

CalcRadius: subroutine
	lda func0
        bpl .pos0
        eor #$ff
        clc
        adc #1
.pos0	sta func0

	cmp #$
        

	lda func1
        bpl .pos1
	eor #$ff
        clc
        adc #1
.pos1	sta func1

        
        ldx func0
        ldy func1
        clc
        cpx func1
        bcc .reverse
        stx func2
        sty func3
        jmp PyTanLookup
.reverse
	dex
        dey
	stx func3
        sty func2
        
PyTanLookup:
	lda func3
	clc
        cmp #$64
        bcc .colok
	lda #$ff
        sta func6
        rts
.colok	
	lda func2
        clc
        cmp #$62
        bcc .rowok       
        lda #$ff
        sta func6
        rts      
.rowok  

	lsr
        lsr
        ora #$f0
        sta func5
        lda func2
        and #$3
        ror
        ror
        ror
        ora func3
        sta func4
        
        ldy #0
        lda (func4),y
        sta func6

        rts
	