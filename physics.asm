NormalMode: subroutine

	; reset vertical velocity and air flag, ready to update
	lda #<(GRAVITY)
        sta ay2
        lda #>(GRAVITY)
        sta ay1  
	lda #>(GRAVITY>>8)
        sta ay0
        lda #$40
        ora flags
        sta flags
        inc coyote

	;;; MOVEMENT FLAGS
	; velocity is the movement direction. velocity zero? acceleration is movement direction
	jsr CheckMovement

	;;; COLLISION
	jsr NormalCollision


	;;; MOVEMENT
        bit flags	; hero has different physics for air and ground
        bvs .air
        lda #$8
        bit flags
        bne .air

        ;; Ground Rules
                
      	lda #$1         ; do passive deceleration if not actively controlled
        bit flags
        bne .end
        asl
        bit flags
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


	jmp .airdone

.air
	
	;; Air Rules

	lda #$8			; finally set variables if jumping
        bit flags
        beq .nojump
	lda #<(-JUMP_FORCE)
        sta vy2
        lda #>(-JUMP_FORCE)
        sta vy1
        lda #>((-JUMP_FORCE)>>8)
        sta vy0
.nojump


.airdone


	;;; Values have been adjusted. Finalizing physics calc

	ldx #3
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
	; TODO: this part could be better
        
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
	rts




; sets the horizontal movement flags correctly
CheckMovement: subroutine
	lda #$fd
        and flags
        sta flags

        lda vx0
        bne .yesv
        lda vx1
        bne .yesv
        lda vx2
        bne .yesv
        
        lda ax0
        bne .yesa
        lda ax1
        bne .yesa
        lda ax2
        bne .yesa
        jmp .no

.yesv	lda vx0
	jmp .side

.yesa	lda ax0
        
.side	
	bmi .sideleft
	lda #$ef
        and flags
        sta flags
        jmp .sidedone
.sideleft
	lda #$10
        ora flags
        sta flags
.sidedone
	lda #$02
	ora flags
        sta flags

.no	rts