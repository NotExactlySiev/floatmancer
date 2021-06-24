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
        

NormalCollision: subroutine
	ldy #0

	lda vy0
        bmi .air
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
.air        
        lda #$40
        ora flags
        sta flags
        jmp .downdone
.nair        
        sty coyote
.downdone

	;; UPWARDS COLLISION

	
	lda flags
        and #$40
        beq .checkup
        lda vy0
        bne .checkup
        beq .nceiling

.checkup

	lda py0
        sec
        sbc #5
        sta func0
        
        lda px0
        clc
        adc #2
        sta func1

        jsr CheckCollision	; TOP RIGHT
	lda func2
        bne .ceiling

        lda px0
        sec
        sbc #2

        sta func1
        
        jsr CheckCollision	; TOP LEFT
	lda func2
        bne .ceiling

.nceiling
        lda #$df
        and flags
        sta flags       
.ceiling        

	
        lda flags
        eor #$40
        and #$60
        beq .colvdone
.updone

	; if hit block from above or on ground, push character out into grid
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
        bne .pushout
        
        lda py0
        clc
        adc #3
        sta func0

	jsr CheckCollision	; BOTTOM left/right
        lda func2
        bne .pushout
	beq .colhdone

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
.colhdone

	rts