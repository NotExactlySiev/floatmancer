	; clamps a 24 bit signed number to [-MAX, MAX] for given 24 bit MAX immediate value
	MAC LIMITMAG
        lda {1}
        bpl .pos
.neg
	cmp #>((-{4})>>8)
	bcs .end
        bne .limleft
        lda {2}
        cmp #>(-{4})
        bcs .end
        bne .limleft
        lda {3}
        cmp #<(-{4})
        bcs .end
.limleft
	lda #>((-{4})>>8)
        sta {1}
        lda #>(-{4})
        sta {2}
        lda #<(-{4})
        sta {3}
	jmp .end

.pos	cmp #>({4}>>8)
	bcc .end
     	bne .mhfixright
        lda {2}
        cmp #>({4})
        bcc .end
        bne .mhfixright
        lda {3}
        cmp #<({4})
        bcc .end
.mhfixright
	lda #>({4}>>8)
        sta {1}
        lda #>({4})
        sta {2}
        lda #<({4})
        sta {3}
.end
        ENDM
 

CalcAbs16: subroutine	; number in ax, returns in ax
	ora #0
        bpl .done
        sta tmp0
        lda #0
        sec
        sbc $700,x
        tax
        lda #0
        sbc tmp0
.done
	rts

CalcAbs24: subroutine	; number in axy, returns in axy
	ora #0
        bpl .done
	sta tmp0
        lda #0
        sec
        sbc $700,y
        tay
        lda #0
        sbc $700,x
        tax
        lda #0
        sbc tmp0
.done
	rts



CalcSinAndMultiply: subroutine ; 0-1 angle, 2 multiplier / 3 mirror flag -> 5-7 result = multiplier*sin(angle)
        ldy #0

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
        
        iny
        
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
        ; return 10000
        ldx #1
        stx func5
        dex
        stx func6
        stx func7
        rts
        
.nright ; else
	tya
        pha
        
        ; look up the sine value
        lda func0
        rol func1
        rol
        rol func1
        rol
        tay
        
        lda SineHigh,y
        sta tmp1
        lda SineLow,y
	sta tmp2
.lookupover

	lda #0
        sta tmp0
        sta func5
        sta func6
        sta func7
        
        ldy func2
	
        ; it's multiplication time! 16 bit value is in tmp0-tmp2. shift and add
.loop
	lsr func2
        bcc .shift
        
        clc
        lda tmp2
        adc func7
        sta func7
        lda tmp1
        adc func6
        sta func6
        lda tmp0
        adc func5
        sta func5
        
	lda func2
.shift
	beq .done
	asl tmp2
        rol tmp1
        rol tmp0
        jmp .loop
.done        
	
        sty func2
	
	; negate it if angle was mirrored
	pla
        beq .positive
        
        ldx #0
        txa
        sec
	sbc func7
        sta func7
        txa
        sbc func6
        sta func6
        txa
        sbc func5
        sta func5
        
.positive

	rts

; for x and y returns r=sqrt(x*x + y*y), since we have the angle of the vector
; we can just calculate it with r = |x|*(1/cos(t)) or r = |y|*(1/cos(90 - t)), whichever
; one's more accurate
; input x,y in f0-f1 and f1-f2, 16 bit positive
; output r in f4-f5, rounded from 18 sigfigs by callee
CalcRadius: subroutine
	txa
        pha
        
        ldx #0
        stx func6
        
        ; back the inputs up and round them for atan
	lda func1
        pha
        asl
        
        lda func0
        pha
        adc #0
        sta func0

        lda func3
        pha
        asl
        
        lda func2
        pha
        adc #0
        sta func1

        
        ; if y=0 then r=x and vice versa
        beq .yzero
	lda func0
	beq .xzero

        jmp .nzero
.yzero
	pla
        pla
        
        pla
        sta func4
        pla
        sta func5
        
        jmp .zerodone
.xzero
	pla
        sta func4
        pla
        sta func5
        
        pla
        pla
        
        
.zerodone
	pla
        tax
        rts

.nzero

        jsr CalcAtan
        
        pla
        sta func2
        pla
        sta func3
        pla
        sta func0
        pla
        sta func1

        ldx #0
        ; if t is above 45 degrees, use 90-t and multiply the result by y
        lda func6
        cmp #$20
        bcc .below
	
        sec
        lda #$0
        sbc func7
        sta func7
        lda #$40
        sbc func6
        sta func6
	inx ; remember that we flipped the angle
        inx ; this is inefficient. x and y should be h h l l
.below
        
        rol func7
        rol
        rol func7
        rol
        rol func7
        rol
        
        ; get ready for lookup and multiplication
        ldy #0
        sty func4
        sty func5
        sty func6
        sty func7
        sty tmp0
        iny
        sty tmp1
        
        tay
        dey
        
        ; collect the 24 bit results
        lda InvCosHigh,y
        sta tmp2
        lda InvCosLow,y
        sta tmp3
        
        ; and multiply it by x (or y)
        ; note: x,y are < 64 so this will not overflow
        lda func0,x
        sta func0
        lda func1,x ; we should store them h h l l not h l h l
        sta func1
.loop
	lsr func0
        ror func1
        bcc .shift
        
        clc
        lda tmp3
        adc func7
        sta func7
        lda tmp2
        adc func6
        sta func6
        lda tmp1
        adc func5
        sta func5
        lda tmp0
        adc func4
        sta func4
        
	lda func1
.shift
	beq .done
	asl tmp3
        rol tmp2
        rol tmp1
        rol tmp0
        jmp .loop
.done
	; round the result to 16 sigfigs
	asl func6
        lda func5
        adc #0
        sta func5
        lda func4
        adc #0
        sta func4

	pla
        tax
        rts

CalcAtan: subroutine	; 0-1 xy legs, 2-3 ptr, 6-7 result, all local vars are used.
	txa
        pha
        
        lda #0
        sta tmp0
        sta tmp1
        sta tmp3
        sta func7
        sta func2	; set offset at the start of the table
        sta func3
        
        lda func0
        bpl .horok
        eor #$ff
        clc
        adc #1
        sta func0
        lda #$40
        sta tmp3     
.horok

	lda func1
        bpl .verok
	eor #$ff
        clc
        adc #1
        sta func1
        lda #$20
        ora tmp3
        sta tmp3
.verok

	; check for special cases before swapping
	lda func1
	cmp func0
        bne .n45
        lda #$20
        sta func6
	jmp .lookupdone	
.n45     
        lda func0
        bne .nright
	lda #$40
        sta func6
        lda #$10
        ora tmp3
        sta tmp3
	jmp .lookupdone	
.nright
        lda func1
	bne .nzero
        lda #$0
        sta func6
        lda #$10
        ora tmp3
        sta tmp3
	jmp .lookupdone	
.nzero

.divide
	lda func0
        lsr
        bcs .lookup
        lda func1
        lsr
        bcs .swap
        lsr func0
        sta func1
	jmp .divide
        
.swap   

        rol ; undo the shift and swap
        ldx func0
        stx func1
        tax
        lda #$10 ; reminder that we swapped
        ora tmp3
        sta tmp3
        txa
        lsr
.lookup     
        ldy #0
	; now that we have them in correct format and order, we need to
        ; calculate the offset for x, using this formula:
        ; r = (x - 1) >> 1  (but we've already decremented one)
        ; offset = N/2 * r + T(r-1)
        ; where T(n) is the nth triangular number
        ; where N is the size of the LUT
	; x is already divided by two
        sta func0
        tax
        ; and right off the bat if r = 0 then offset = 0
        beq .offdone
	
        ; we multiply it by size of the table divided by two
        ; in this case a multiplication by 50/2 = 25
        sta func4
        lda #0
        sta func5
        
        clc
        lda func4
        adc func2
        sta func2
        lda func5
        adc func3
        sta func3
        
        asl func4
        rol func5
        asl func4
        rol func5
        asl func4
        rol func5
        
        clc
        lda func4
        adc func2
        sta func2
        lda func5
        adc func3
        sta func3
        
        asl func4
        rol func5
        
        clc
        lda func4
        adc func2
        sta func2
        lda func5
        adc func3
        sta func3
        
        ; now to calculate T(r-1) = (r*(r-1))/2
        
        sec
        lda func0
        sta func7
        lda #0
        sta func6
        sta func5
        sta tmp0
        sta tmp1
       
       	lda func0
        sbc #1
        sta func4
        sta tmp2 ; save r-1 for later
        

.loop
	lsr func4
        bcc .shift
        
        clc
        lda func7
        adc tmp1
        sta tmp1
        lda func6
        adc tmp0
        sta tmp0
        
	lda func4
.shift
	beq .offdone
        asl func7
        rol func6
        jmp .loop      
.offdone

	lsr tmp0
        ror tmp1

	clc
	lda tmp1
        adc func2
        sta func2
        lda tmp0
        adc func3
        sta func3

	; x offset is now added to 2-3

	; now add y offset (row index) to it and read the result off the table
        lda tmp2
        asl
        cmp func1
        bcc .after
      	ldx func1 ; i = y - 1
        dex
        txa
        jmp .indexdone
.after
        lda func1 ; i = y/2 + r - 1
        lsr
        clc
        adc tmp2
        
.indexdone

        clc
        adc func2
        sta func2
        lda #0
	adc func3
        sta func3

	; now multiply the whole thing by 2 because values are 16 bit
	asl func2
        rol func3
        
        clc
	lda #>AtanTable
	adc func3
	sta func3

	lda (func2),y
        sta func6
        iny
        lda (func2),y
        sta func7
        
.lookupdone

        asl tmp3
        bpl .nmirrorh
        lda func7
	eor #$ff
        clc
        adc #1
        sta func7
        lda func6
        eor #$7f
	adc #0
        sta func6

.nmirrorh

	asl tmp3
        bpl .nmirrorv
        lda func7
       	eor #$ff
        clc
        adc #1
        sta func7
        lda func6
        eor #$ff
	adc #0
        sta func6
.nmirrorv

	asl tmp3
        bmi .nmirrorxy
        lda func7
        eor #$ff
        clc
        adc #1
        sta func7
        lda func6
        eor #$3f
	adc #0
        sta func6
.nmirrorxy
        
        pla
        tax
        rts