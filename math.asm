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



CalcSinAndMultiply: subroutine ; 0-1 angle, 2-3 multiplier -> 4-7 result = multiplier*sin(angle)
        ldy #0

        lda func0
        bpl .check1

	sec
	tya
        sbc func1
        sta func1
        tya
        sbc func0
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
        stx func4
        dex
        stx func5
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
        sta tmp2
        lda SineLow,y
	sta tmp3
.lookupover

	lda #0
        sta tmp0
        sta tmp1
        sta func4
        sta func5
        sta func6
        sta func7
        
        ldy func2
        ldx func3
	; TODO: this code is repeated. 8x16 multiply can be a subroutine or macro
        ; it's multiplication time! 16 bit value is in tmp0-tmp2. shift and add
.loop
	lsr func2
        ror func3
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
        
	lda func3
.shift
	bne .ndone
	lda func2
        beq .done
.ndone
        asl tmp3
	rol tmp2
        rol tmp1
        rol tmp0
        jmp .loop
.done        
	
        sty func2
        stx func3
	
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
        txa
        sbc func4
        sta func4
        
.positive

	rts

; for x and y returns r=sqrt(x*x + y*y), since we have the angle of the vector
; we can just calculate it with r = |x|*(1/cos(t)) or r = |y|*(1/cos(90 - t)), whichever
; one's more accurate
; input x,y in f0-f1 and f2-f3, 16 bit positive
; output r in f4-f5, rounded from 18 sigfigs by callee
CalcRadius: subroutine
	txa
        pha
        
        ldx #0
        stx func6
        
        ; TODO: we don't need to do this for the new atan
        ; back the inputs up and round them for atan
	lda func1
        pha        
        lda func0
        pha

        lda func3
        pha        
        lda func2
        pha

        
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
        
        rol func7	; we already had this in atan. return it?
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
	bne .ndone
        lda func0
        beq .done
.ndone
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


; x and y are 16 bit values in f0-f1 and f1-f2
;
CalcAtan: subroutine
	txa
        pha
        
        lda #0
        stx tmp0
        stx tmp1
        stx tmp3
        ;sta func2	; set offset at the start of the table
        ;sta func3
        
        lda func0
        bpl .horok
	txa
        sec
        sbc func1
        sta func1
        txa
        sbc func0
        sta func0
        
        lda #$40
        sta tmp3    
.horok


	lda func2
        bpl .verok
	txa
        sec
        sbc func3
        sta func3
        txa
        sbc func2
        sta func2
        
        lda #$20
        ora tmp3
        sta tmp3
.verok


	; put the smaller leg in f0-f1
	lda func0
        cmp func2
        bcc .swapdone
	bne .swap
	lda func1
        cmp func3
        bcc .swapdone
        bne .swap
        ; TODO: they're equal
.swap
	lda func0
        ldx func2
        sta func2
        stx func0
        
        lda func1
        ldx func3
        sta func3
        stx func1
        
        lda #$10	; set the flag to remember that we swapped
        ora tmp3
        sta tmp3
.swapdone

	; now double both values until the bigger one is is [0x20, 0x40)
.scale
        lda #$20
        and func2
        bne .scaledone
	asl func3
        rol func2
        asl func1
        rol func0
	bcc .scale
.scaledone

	; and round the results to 8 bits. the bigger one will be in [0x20, 0x40]
        ; then put them in f0 and f1 in the same order
        asl func1
        lda #0
        adc func0
        sta func0
        
        asl func3
        lda #0
	adc func2
        sta func1
        
        ; in the special case that it rounds up to 0x40, halve them one time
        ; (optimization: can integrate this and rounding in one)
        cmp #$40
        bne .rounddone
        lsr func0
	lsr func1
.rounddone

	; check for special cases
        
        lda func1
        bne .not0
        sta func6
        sta func7
        beq .lookupdone
.not0
	lda func0
        bne .not90
	sta func7
        lda #$40
        sta func6
        bne .lookupdone
.not90
	cmp func1
        bne .not45
	lda #$20
        sta func6
        lda #0
        sta func7
        beq .lookupdone
.not45

        ; TODO: what if they're equal here? :/ checked too soon?
        
        lda func0
        cmp #$2f
        bcc .nmirror
        
        lda #$5e
        sec
        sbc func0
        sta func0
        lda #$1f
        eor func1

.nmirror
        ; and finally look up. 
	
        lda func0	; convert to row number
        sec
        sbc #1
        tay
        lsr
        lsr
        lsr
        clc
        adc #>AtanTable
        sta func3
        
        tya
        ror
        ror
        ror
        ror
        and #$e0
        sta func0
        
        lda func1
        sec
        sbc #$20
        ora func0
        sta func2
        
        
	ldy #0
        lda (func2),y
        
        sty func7
        lsr
        ror func7
        lsr
        ror func7
        lsr
        ror func7
        sta func6
.lookupdone
        
	ldx #$80

        asl tmp3
        bpl .nmirrorh
        
        tya
        sec
        sbc func7
        sta func7
        txa
        sbc func6
        sta func6

.nmirrorh

	asl tmp3
        bpl .nmirrorv
        
        tya
        sec
        sbc func7
        sta func7
        tya
        sbc func6
        sta func6
.nmirrorv

	asl tmp3
        bmi .nmirrorxy

	tya
        sec
        sbc func7
        sta func7
        lda #$40
        sbc func6
        sta func6
.nmirrorxy
.done

	pla
        tax
        rts