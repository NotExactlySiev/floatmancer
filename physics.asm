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

	;;; MOVEMENT FLAGS
	; velocity is the movement direction. velocity zero? acceleration is movement direction
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

.no

	;;; COLLISION

	lda vy0
        bmi .up
.down

	;; DOWNWARDS AND GROUND COLLISION
	lda py1		; check for bottom left and bottom right, collision if any are in solid block
        clc
        adc #$ff
        lda py0
        adc #7
        sta func0
        
        lda px0
        clc
        adc #2
        sta func1

        jsr CheckCollision	; BOTTOM RIGHT
	lda func2
        bne .nair

        lda px0
        sec
        sbc #2
        sta func1
        
        jsr CheckCollision	; BOTTOM LEFT
	lda func2
        bne .nair
        jmp .colvdone
        
.nair        
        lda #$bf
        and flags
        sta flags
        jmp .resetvpos

.up
	;; UPWARDS COLLISION
	lda py1		; check for top left and top right, collision only if both are in solid block
        sec
        sbc #$ff
        lda py0
        sbc #4
        sta func0
        
        lda px0
        clc
        adc #3
        sta func1

        jsr CheckCollision	; TOP RIGHT
	lda func2
        beq .colvdone

        lda px0
        sec
        sbc #3

        sta func1
        
        jsr CheckCollision	; TOP LEFT
	lda func2
        beq .colvdone
                
.resetvpos		; if hit block from above or on ground, push character out into grid
	lda #0
        sta ay0
        sta ay1
        sta ay2
        sta vy0
        sta vy1
        sta vy2
        sta py1
	
        lda scroll
        and #$7
        sta tmp0
        
        lda py0
        clc
        adc tmp0
        and #$f8
        sbc tmp0
        adc #4
        
        sta py0

.colvdone


	;; HORIZONTAL COLLISION

        lda #$2		; no collision detection needed if hero is not moving horizontally
        bit flags
        beq .colhdone

	lda #$10
        bit flags
	bne .cleft
.cright
	lda px1		; set for the left or right corners based on movement direction
        clc
        adc #MARGIN
        lda px0
        adc #3
        sta func1
        jmp .colhxset
.cleft

	lda px1
        sec
        sbc #MARGIN
	lda px0
        sbc #3
        sta func1
        
.colhxset		; horizontal collision if both corners are solid block
	lda py0		
        sec
        sbc #3
        sta func0
        
        jsr CheckCollision	; TOP left/right
        lda func2
        beq .colhdone
        
        lda py0
        clc
        adc #4
        sta func0

	jsr CheckCollision	; BOTTOM left/right
        lda func2
        beq .colhdone
        
	lda #$10		; push out into the grid
        bit flags
	bne .pushright
.pushleft
	lda px0
        and #$f8
        clc
        adc #5
        sta px0
	jmp .pushdone

.pushright
	lda px0
        and #$f8
        clc
        adc #3
        sta px0
.pushdone       
				; stop hero, reset all vars
	lda #0
        sta ax0
        sta ax1
        sta ax2
        sta vx0
        sta vx1
        sta vx2
        sta px1
  
.colhdone


	;; MOVEMENT
        lda #$40
        bit flags	; hero has different physics for air and ground
        bne .air

        ; Ground Rules
        
        lda #$8
        bit flags
        bne .nochange
        lda jtimer
        beq .nochange
        cmp #3
        bcs .nochange
        lda #$8
        ora flags
        sta flags	; set to jumping if on frame 1 or 2 of pressing jump
        
        
.nochange

        ; Ground Deceleration
        
        
        bne .air
	lda #$1         ; do passive deceleration if not actively controlled
        bit flags
        bne .end
        lda #$2
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
	
	; Air Rules

	; jumping
	lda #$8
        bit flags
        beq .nochange2
	lda jtimer
        beq .jdone
        cmp #MAX_JUMP
        bcs .jdone
	jmp .nochange2
.jdone
	lda #$f7	; end jumping if B released or max jump time reached
        and flags
        sta flags

.nochange2


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


	; Values have been adjusted. Finalizing physics calc

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


CheckCollision:		; check for collision, 0-1 yx pixels, 6-7 yx tiles, 2 is solid or not
        lda func0	; set pixel positions to grid positions. adjust for scrolling
        clc
        adc scroll
        ror		; nine bit addition result. throw away 0-2, keep carry
        lsr
        lsr
        sta func6
        
        lda func1
        lsr
        lsr
        lsr
        sta func7
        
        ldx #0
        
.checkrect        
        lda collist,x
        bne .ndone
        lda #0
        sta func2
        rts
.ndone

	lda func6	; check the tile with ALL of the collision blocks
        clc
        cmp collist,x
        bcc .not1
	inx 
        lda func7
        clc
        cmp collist,x
        bcc .not2
        inx
        
        lda collist,x
        clc
        cmp func6
        bcc .not3
        inx
        lda collist,x
        clc
        cmp func7
        bcc .not4
        
        lda #1
        sta func2
        rts
        
.not1	inx
.not2	inx
.not3	inx
.not4	inx

	jmp .checkrect