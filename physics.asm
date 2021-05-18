NormalMode: subroutine

	lda #<(GRAVITY)
        sta ay2
        lda #>(GRAVITY)
        sta ay1  
	lda #>(GRAVITY>>8)
        sta ay0
        lda #$40
        ora Flags
        sta Flags


	lda py0
        lsr
        lsr
        lsr
        clc
        adc #1
        sta func0
        lda px0
        lsr
        lsr
        lsr
        sta func1
        
        jsr CheckCollision

	lda func2
        beq .air
        lda #$bf
        and Flags
        sta Flags
        lda #0
        sta ay0
        sta ay1
        sta ay2
        sta vy0
        sta vy1
        sta vy2
        sta py1
        sta py2
        lda py0
        and #$f8
        sta py0

.air	lda px0
	lsr
        lsr
        lsr
	sta func1
	
	lda py0
	clc
        adc vy0
        lsr
        lsr
        lsr
        sta func0
        
        jsr CheckCollision
	lda func2
        beq .vfree
	lda #0
        sta ay0
        sta ay1
        sta ay2
        sta vy0
        sta vy1
        sta vy2
.vfree

        lda py0
        lsr
        lsr
        lsr
        sta func0
        
	lda px0
	clc
        adc vx0
        lsr
        lsr
        lsr
        sta func1
        jsr CheckCollision
	lda func2
        beq .hfree
      	lda #0
        sta vx0
        sta vx1
        sta vx2
        sta ax0
        sta ax1
        sta ax2
        lda px0
        and #$f8
        sta px0
.hfree






	lda #$1         ; do passive deceleration if not actively controlled
        bit Flags
        bne .end
        lda #$2
        bit Flags
        beq .end
        lda #$40
        bit Flags
        bne .end
        
        lda vx0
        bpl .decelok
.left   cmp #>((-PASSIVE_DECEL)>>8)
        bcc .decelok
        bne .decelzero
        lda vx1
        cmp #>(-PASSIVE_DECEL)
        bcc .decelok
        bne .decelzero
        lda vx2
        cmp #<(-PASSIVE_DECEL)
        bcc .decelok
.decelzero
        lda #0
        sta vx0
        sta vx1
        sta vx2
        sta ax0
        sta ax1
        sta ax2
        lda #$fd
        and Flags
        sta Flags
        
        jmp .end

.decelok
	lda #>(PASSIVE_DECEL>>8)
        sta ax0
        lda #>PASSIVE_DECEL
        sta ax1
        lda #<PASSIVE_DECEL
        sta ax2
        lda vx0
        bmi .right
        jsr NegativeAclX      	  
.right 

.end

        

	ldx #9
SetVelPos:
	clc
	lda vx2,x
        adc ax2,x
        sta vx2,x
        lda vx1,x
        adc ax1,x
        sta vx1,x
        lda vx0,x
        adc ax0,x
        sta vx0,x

        clc
        lda px2,x
        adc vx2,x
        sta px2,x
        lda px1,x
        adc vx1,x
        sta px1,x
        lda px0,x
        adc vx0,x
        sta px0,x
        
        cpx #0
        beq .pdone
        ldx #0
        jmp SetVelPos
        
.pdone
	; this part could be better
        
	lda phase
        bne .nolimit

	lda vx0
        bpl .mright
.mleft	cmp #>((-MAX_WALK)>>8)
	bcs .mhend
        bne .mhfixleft
        lda vx1
        cmp #>(-MAX_WALK)
        bcs .mhend
        bne .mhfixleft
        lda vx2
        cmp #<(-MAX_WALK)
        bcs .mhend
.mhfixleft
	lda #>((-MAX_WALK)>>8)
        sta vx0
        lda #>(-MAX_WALK)
        sta vx1
        lda #<(-MAX_WALK)
        sta vx2
	jmp .mhend

.mright	cmp #>(MAX_WALK>>8)
	bcc .mhend
     	bne .mhfixright
        lda vx1
        cmp #>(MAX_WALK)
        bcc .mhend
        bne .mhfixright
        lda vx2
        cmp #<(MAX_WALK)
        bcc .mhend
.mhfixright
	lda #>(MAX_WALK>>8)
        sta vx0
        lda #>(MAX_WALK)
        sta vx1
        lda #<(MAX_WALK)
        sta vx2

.mhend
.nolimit

	rts