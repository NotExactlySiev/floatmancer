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


              
        lda angle0
        sta $23
        clc
        adc #$40
        sta $25		; v and a can be used as temporary var here
	
        ldx #2

SinCos:			; look up angles for sin and cos with sign bit after
        ldy #0
        lda $23,x
        bpl .check1
        eor #$ff
        clc
        adc #1
        ldy #1
.check1	
	asl
	bpl .check2
        eor #$ff
        clc
        adc #2
.check2	lsr
	sta $23,x
        sty $24,x

        lda $23,x
        cmp #$40
        bne .nright
	lda radius
        sta relpx0,x
        lda #0
        sta relpx1,x
	jmp .lookupover
.nright
	clc
        asl
        sta sinptr
        
	lda radius
	lsr
        clc
        adc #$b0
        sta sinptr+1
        lda $23,x
        and #$1
        clc
        ror
        ror
        clc
        adc sinptr
	sta sinptr
	
        ldy #0
        lda (sinptr),y
        sta relpx0,x
        iny
        lda (sinptr),y
        sta relpx1,x

.lookupover
	       
        lda $24,x
        beq .positive
	clc
        lda relpx1,x
        eor #$ff
        adc #1
        sta relpx1,x
        lda relpx0,x
        eor #$ff
        adc #0
        sta relpx0,x
         
        
.positive        
        dex
        dex
        bpl SinCos



        lda relpy0
        clc
        adc hookpy
        sta py0
	lda relpx0
        clc
        adc hookpx
        sta px0