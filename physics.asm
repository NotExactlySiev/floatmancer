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

	;;; MOVEMENT FLAGS

	lda #$fd
        and Flags
        sta Flags

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
        and Flags
        sta Flags
        jmp .sidedone
.sideleft
	lda #$10
        ora Flags
        sta Flags
.sidedone
	lda #$02
	ora Flags
        sta Flags

.no

	;;; COLLISION
	

	lda vy0
        bmi .up
.down

	lda py1
        clc
        adc #MARGIN
        lda py0
        adc #$8
        lsr
        lsr
        lsr
        sta func0
        
        lda px0
        clc
        adc #2
        lsr
        lsr
        lsr
        sta func1

        jsr CheckCollision
	lda func2
        bne .nair
        
        lda px0
        clc
        adc #WIDTH-1
        lsr
        lsr
        lsr
        sta func1
        
        jsr CheckCollision
	lda func2
        bne .nair
        jmp .colgrounddone
        
.nair        
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

	jmp .colvdone

.up




.colvdone
.colgrounddone




        lda #$2
        bit Flags
        beq .colhdone        

	lda #$10
        bit Flags
	bne .cleft
.cright
	lda px1
        clc
        adc #MARGIN
        lda px0
        adc #4
        lsr
        lsr
        lsr
        sta func1
        jmp .colhxset
.cleft
/*
        lda px1
        clc
        adc #<($0100-MARGIN)
        lda px0
        adc #>($0100-MARGIN)
        lsr
        lsr
        lsr
	sta func1
*/

	lda px0
        lsr
        lsr
        lsr
        sta func1
        
.colhxset
	lda py0
        lsr
        lsr
        lsr
        sta func0
        
        jsr CheckCollision
        lda func2
        sta func3
        
        lda py0
        clc
        adc #8
        lsr
        lsr
        lsr
        sta func0

	jsr CheckCollision
        
        lda func2	; bottom - top
        bne .hbottomblock
        jmp .colhdone
.hbottomblock
        lda func3
        bne .hbothblock
  	jmp .colhdone
.hbothblock
	lda vx0
        bpl .pushleft
        lda px0
        clc
        adc #$8
        sta px0
.pushleft
	lda px0
        and #$f8
        sta px0
        

	lda #0
        sta ax0
        sta ax1
        sta ax2
        sta vx0
        sta vx1
        sta vx2
        sta px1
        sta px2
        
        ; push player out of the wall
        
        
  
.colhdone











	;; MOVEMENT

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
        
CheckCollision:		; check for collision, 0-1 -> y,x
        ldx #0
        
.checkrect        
        lda $c0,x
        bne .ndone
        lda #0
        sta func2
        rts
.ndone

	lda func0
        clc
        cmp $c0,x
        bcc .not1
	inx 
        lda func1
        clc
        cmp $c0,x
        bcc .not2
        inx
        
        lda $c0,x
        clc
        cmp func0
        bcc .not3
        inx
        lda $c0,x
        clc
        cmp func1
        bcc .not4
        
        lda #1
        sta func2
        rts
        

.not1	inx
.not2	inx
.not3	inx
.not4	inx

	jmp .checkrect