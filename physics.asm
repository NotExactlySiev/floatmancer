NormalMode: subroutine

	; reset vertical velocity and air flag, ready to update
	lda flags
        and #$bf
        ora #$20
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
       
; EXPERIMENTAL - testing a different decel method

	lda ax0
        bne .npassive
	lda ax1
        bne .npassive
        lda ax2
        bne .npassive
	
        lda vx0		; shift right and sign extend to get 1/2
        cmp #$80
        ror vx0
	ror vx1
        ror vx2
        
        ldx vx0
        ldy vx1
        lda vx2
        
        cpx #$80	; shift right and sign extend again to get 1/4
        ror vx0
	ror vx1
        ror vx2
        
        clc		; add together to get 75% of the original velocity
        adc vx2
        sta vx2
        tya
        adc vx1
        sta vx1
        txa
        adc vx0
        sta vx0 
.npassive

.end
	jmp .airdone

.air
	
	;; Air Rules
        lda vy0
        bmi .upwards
        lda #<DOWN_GRAVITY
        sta ay2
        lda #>DOWN_GRAVITY
        sta ay1
        lda #>(DOWN_GRAVITY>>8)
        sta ay0
        beq .gravitydone
.upwards
        lda #<UP_GRAVITY
        sta ay2
        lda #>UP_GRAVITY
        sta ay1
        lda #>(UP_GRAVITY>>8)
        sta ay0
        

.gravitydone

	lda #$8			; finally set variables if jumping
        bit flags
        beq .nojump
        ldx jtimer
        cpx #WINDUP_TIME
        bcc .nojump
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
        
        lda px1,x
        adc #0		; evil hack! if velocity is -1 it doesn't change anything
        sta px1,x
        
        cpx #0
        beq .pdone
        ldx #0
        jmp SetVelPos
        
.pdone
	; TODO: this part could be better
        
        bit flags
        bvs .mhend
        
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