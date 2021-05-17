	
        
        
        
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
        sta $26	
        lda angle1
        sta $24
        sta $27
        lda #0
        sta $25
        sta $28
	; v and a can be used as temporary var here
	
        ldx #3

SinCos:			; look up angles for sin and cos with sign bit after
        ldy #0
        lda $23,x
        bpl .check1
        
        lda $24,x
        eor #$ff
        clc
        adc #1
        sta $24,x
        lda $23,x
        eor #$ff
        adc #0
        sta $23,x
        
        lda #1
        sta $25,x
        
.check1	lda $23,x
	asl
	bpl .check2
        
        lda $24,x
        eor #$ff
        clc
        adc #1
        sta $24,x
        lda $23,x
        eor #$7f
        adc #0
        sta $23,x
.check2

	lda $23,x
        cmp #$40
        bne .nright
        lda radius
        sta relpx0,x
        jmp .lookupover
        
.nright
        lda radius
        clc
        adc #$b0
        sta sinptr+1

	lda $23,x
        
        clc
        asl
        asl
        asl
        bcc .nbig
	inc sinptr+1
.nbig
	sta sinptr
        
	lda $24,x
        rol
        rol
        rol
        rol
        and #$06
        ora sinptr
        sta sinptr
        jmp .midwayover

.midway	bpl SinCos        
.midwayover

        ldy #0
        lda (sinptr),y
        sta relpx0,x
        iny
        lda (sinptr),y
        sta relpx1,x

.lookupover
	       
        lda $25,x
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
        dex
        bpl .midway


        




        lda relpy0
        clc
        adc hookpy
        sta px0
	lda relpx0
        clc
        adc hookpx
        sta py0		; rel x and y are inverted!!