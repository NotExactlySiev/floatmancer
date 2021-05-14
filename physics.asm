        ldx #17
.copyold
        lda $20,x
        sta $32,x
        dex
        bpl .copyold

        lda #<(GRAVITY)
        sta ay2
        lda #>(GRAVITY)
        sta ay1  
	lda #>(GRAVITY>>8)
        sta ay0
        lda #$40
        ora Flags
        sta Flags
	
        
	lda px0
        sta $2
        lda py0
        clc
        adc #8
        sta $3
        jsr CheckCollision
        lda $2
        beq .air        
        ; if is on ground
        lda #0
        sta vy0
        sta vy1
        sta vy2
        sta ay0
        sta ay1
        sta ay2
        lda #$bf
        and Flags
        sta Flags
.air
	
        
	

	lda #$1         ; do passive deceleration if not actively controlled
        bit Flags
        bne .end
        lda #$2
        bit Flags
        beq .end
        
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
        
	lda vy0
        cmp #>(MAX_FALL>>8)
        bcc .ok
        bne .fix
        lda vy1
        cmp #>MAX_FALL
	bcc .ok
        bne .fix
        lda vy2
        cmp #<MAX_FALL
        bcc .ok
.fix	lda #>(MAX_FALL>>8)
	sta vy0
        lda #>MAX_FALL
        sta vy1
        lda #<MAX_FALL
        sta vy2
.ok

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