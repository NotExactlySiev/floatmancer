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
.decel
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


 IF ENABLE_AIR_RES
        ; the old ground decel system should work fine here
        ; the new ground decel system is way too fast for air decel
        ; also we should really face the problems we had with the old one
        ; here, it should work just fine i think since it's only applied mid air
	
        ; we only have passive decel if movement controls aren't pressed
        lda pad
        and #$3
        bne .resdone
        
	bit vx0
        bpl .right
        
        clc
        lda vx2
        adc #<(AIR_RES)
        sta vx2
        lda vx1
        adc #>(AIR_RES)
        sta vx1
        lda vx0
        adc #>(AIR_RES>>8)
        sta vx0
        jmp .resdone
          
.right
	clc
        lda vx2
        adc #<(-AIR_RES)
        sta vx2
        lda vx1
        adc #>(-AIR_RES)
        sta vx1
        lda vx0
        adc #>((-AIR_RES)>>8)
        sta vx0

.resdone

 ENDIF
 
.airdone


	;;; acceleration values have been adjusted. updating velocity

	ldx #3
SetVel:
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
        
        cpx #0
        beq .vdone
        ldx #0
        jmp SetVel
        
.vdone

	; adjusting velocity values

        ; limiting walk speed to maximum
        bit flags
        bvs .nl
        
      
 	; using absolute value so we there's less code
 	lda vx0
        ldx vx1
        ldy vx2
        jsr CalcAbs24
        
        cmp #>(MAX_WALK>>8)
        bcc .nl
	bne .fix
        cpx #>(MAX_WALK)
        bcc .nl
        bne .fix
        cpy #<(MAX_WALK)
	bcc .nl
.fix
	bit vx0
	bpl .pos
.neg
        ldy #<(-MAX_WALK)
        ldx #>(-MAX_WALK)
	lda #>((-MAX_WALK)>>8)
	bmi .write
.pos
        ldy #<(MAX_WALK)
        ldx #>(MAX_WALK)
	lda #>(MAX_WALK>>8)
.write
	sty vx2
        stx vx1
        sta vx0
.nl



	;; not limiting the absolute maximum speed can cause collision to break

	lda vx0
        bmi .hchneg
.hchpos        
	cmp #MAX_SPEED
        bcc .hchdone
	lda #MAX_SPEED
        sta vx0
        bne .hchdone
.hchneg
	cmp #256-MAX_SPEED+1
        bcs .hchdone
        lda #256-MAX_SPEED
        sta vx0
.hchdone

 IF 1
	lda vy0
        bmi .hcvneg
.hcvpos        
	cmp #MAX_SPEED+3
        bcc .hcvdone
	lda #MAX_SPEED+3
        sta vy0
        bne .hcvdone
.hcvneg
	cmp #256-(MAX_SPEED+3)+1
        bcs .hcvdone
        lda #256-(MAX_SPEED+3)
        sta vy0
.hcvdone
 ENDIF

	;;; velocity values have been adjusted. updating position

	ldx #3
SetPos:

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
        jmp SetPos
        
.pdone

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