CheckCollision:		; check for collision, 0-1 yx pixels, 6-7 yx tiles
	; wouldn't it make more sense to just wait for vblank and look at the tiles surrounding
        ; the player every frame? then we'd have all the collision data we'll ever need
        ; also there'll be no limit on the number of collision rects in a level
        ; am i missing something or was i just stupid back when i wrote this?
        lda func1
        lsr
        lsr
        lsr
        cmp #$3		; first check collision with the two walls
        sec ; disabling walls for now. TEMP
        bcc .wall
       	cmp #29
        clc ; disabling walls for now. TEMP
        bcc .nwall
.wall
	lda #1
        rts
.nwall

        sta func7

        lda func0	; set pixel positions to grid positions. adjust for scrolling
        clc
        adc scroll
        ror		; nine bit addition result. throw away bits 0-2, keep carry
        lsr
        lsr
        sta func6
        
        
        ldx #0
        
.checkrect
	lda func6	; check the tile with ALL of the collision blocks
        cmp collist,x
        bcc .not1
	inx 
        lda func7
        cmp collist,x
        bcc .not2
        inx
        
        lda collist,x
        cmp func6
        bcc .not3
        inx
        lda collist,x
        and #$1f
        cmp func7
        bcc .not4
        
        lda collist,x
        and #$e0
        ora #1
        rts
        
.not1	inx
.not2	inx
.not3	inx
.not4	inx

	bpl .checkrect
        lda #0
        rts
        

NormalCollision: subroutine
	ldy #4
        sty tmp1

	lda vy0
        bmi .air
        lda flags
        and #FLG_JUMPING
        bne .air
	;; DOWNWARDS AND GROUND COLLISION
        lda #4
	jsr DownCollision
        beq .air
        bmi .air
.nair
        ldy #0
        sty coyote
        beq .downdone
.air        
        lda #FLG_AIR
        ora flags
        sta flags
.downdone

	;; SELF COLLISION
        
        lda py0
        sta func0
        lda px0
        sta func1
        jsr CheckCollision
        beq .nstuck
        bmi .dead
        asl
        bmi .dead
        bpl .ndead
.dead        
        jsr PlayerDeath
.ndead
        lda py0
        sec
        sbc #8
        sta py0
.nstuck

	;; UPWARDS COLLISION

	lda flags
        and #$40
        beq .checkup
        lda vy0
        beq .nceiling

	lda #8
        sta tmp1	; we need to remember if we're checking this for collision because we're moving
        		; up, or because we're on the ground and want to prevent jumping. if we're on the
                        ; ground and there is a ceiling 1 block above the player, the game wouldn't know
                        ; the difference and push the player down into the ground. but that should only
                        ; happen when there is collisin with the ground. so we set this variable to 8 if
                        ; ended up here by having vertical velocity, and will later be added to the y position
                        ; value which will end up pushing the player down.
.checkup
	lda #5		; i changed this from 3 to 5 and it seems to work better now
        		; why was it so low to begin with?
	jsr UpCollision
        beq .nceiling
        bmi .nceiling
        bpl .ceiling
.nceiling
        lda #~FLG_CEIL
        and flags
        sta flags       
.ceiling


        lda flags
        eor #FLG_AIR
        and #FLG_AIR | FLG_CEIL
        beq .colvdone
.updone

	; if hit block from above or on ground, push character out into grid
        lda #0
        
        sta vy0
        sta vy1
        sta vy2
        sta py1
        sta omega0
	
        lda scroll	; grid pixel offset
        and #$7
        sta tmp0
        
        lda py0
        clc
        adc tmp0
        and #$f8
        sbc tmp0
        sec		; set carry because sprite line is delayed roflmfao
        adc tmp1
        sta py0

.colvdone


	;; HORIZONTAL COLLISION

        lda #FLG_HMOVE		; no collision detection needed if hero is not moving horizontally
        bit flags
        beq .colhdone

	lda #4
	jsr FrontCollision
	beq .colhdone
        asl
        bmi .colhdone

.pushout
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
        sta omega0
.colhdone
	rts


; collision subroutines. load the hitbox margin before calling

DownCollision: subroutine
        clc
        jmp VerticalCheck

UpCollision: subroutine
        sec
        eor #$ff

VerticalCheck: subroutine
        adc py0
        sta func0
        
        lda px0
        clc
        adc #2
        sta func1

        jsr CheckCollision
        bne .yes

        lda px0
        sec
        sbc #2
        sta func1
        
        jsr CheckCollision
        bne .yes
        lda #0
.yes    rts


	; collision in the direction of horizontal movement
FrontCollision: subroutine
	sta func3
	lda flags
        and #FLG_HMOVE_DIR
	beq .cright
	lda #0
        sec
        sbc func3
        sta func3
.cright
        lda px0
        clc
        adc func3
        sta func1
	
        ; horizontal collision if both corners are solid block
	lda py0		
        sec
        sbc #3
        sta func0
        
        jsr CheckCollision	; TOP left/right
        bne .yes
        
        lda py0
        clc
        adc #3
        sta func0

	jsr CheckCollision	; BOTTOM left/right
.yes	rts