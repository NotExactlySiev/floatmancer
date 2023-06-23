

ControlInput: subroutine
	lda pad
        and padedge
        and #$20
        beq .lvlend
	ldx lvl
        inx
        stx func0
        jsr FindLevel

        ldx #SEQ_JUMPLVL
        jsr PlaySequence
        
.lvlend


	lda pad
        and padedge
        and #$10
        beq .pauseend
        
        lda loop
        eor #$1
        sta loop
	tax
	jsr PlaySequence

.pauseend
	rts



MenuInput: subroutine
	ldx select
        lda pad
        and padedge
        sta tmp0
        
        and #$4
        beq .nUp
        dex
        bpl .nmin
     	inx   
.nmin
        
.nUp	lda tmp0
	and #$8
        beq .nDown
      	inx
        cpx #MENU_ITEMS
        bcc .nmax
        dex
.nmax
.nDown
	stx select

.navigatedone

	lda select
        cmp #$2
        bne .worlddone
	lda tmp0
        and #$3
        beq .nchange
        lda world
        eor #1
        sta world
.nchange
.worlddone

	bit tmp0
        bpl .nenter
        lda select
        bne .nspeed
        ; speedrun selected
        rts
.nspeed
	cmp #$1
        bne .ncode
        ; code selected
        
        rts
.ncode
	; new game selected
	lda #LEVEL_HEAD
        sta lvlptr+1
	ldx #0
        stx lvlptr
        stx lvl
        stx state
        inx
	inx
        jsr PlaySequence
        rts
.nenter
	rts


PlayInput: subroutine
	lda #0
        sta ax2
        sta ax1
        sta ax0
        
	lda #~(FLG_WALK | FLG_JUST_JUMPED)
        and flags
        sta flags

	;; Walking
	lda #2
        bit pad
        beq NotLeft
        
PressedLeft: subroutine
        bit flags
        bvs .air
.ground        
	lda #<(-WALK_ACCEL)
        sta ax2
        lda #>(-WALK_ACCEL)
        sta ax1  
	lda #>((-WALK_ACCEL)>>8)
        sta ax0
        bvc .done
        
.air
	; if leftward speed is above limit, further acceleration is not allowed
	lda vx0
        bpl .accel
        cmp #>(-AIR_ACCEL_LIMIT>>8)
        bcs .accel
        bne .done
        lda vx1
        cmp #>(-AIR_ACCEL_LIMIT)
        bcs .accel
        bne .done
        lda vx2
        cmp #<(-AIR_ACCEL_LIMIT)
        bcc .done
        
.accel
	lda #<(-AIR_ACCEL)
        sta ax2
        lda #>(-AIR_ACCEL)
        sta ax1  
	lda #>(-AIR_ACCEL>>8)
        sta ax0

.done

	jmp SetWalkFlag
        
NotLeft
	lda #1
        bit pad
        beq NotRight

PressedRight: subroutine
	bit flags
        bvs .air
.ground
	lda #<(WALK_ACCEL)
        sta ax2
        lda #>(WALK_ACCEL)
        sta ax1  
	lda #>(WALK_ACCEL>>8)
        sta ax0
        bvc .done
        
.air
	; if rightward speed is above limit, further acceleration is not allowed
	lda vx0
        bmi .accel
        cmp #>(AIR_ACCEL_LIMIT>>8)
        bcc .accel
        bne .done
        lda vx1
        cmp #>(AIR_ACCEL_LIMIT)
        bcc .accel
        bne .done
        lda vx2
        cmp #<(AIR_ACCEL_LIMIT)
        bcs .done
        
.accel

	lda #<(AIR_ACCEL)
        sta ax2
        lda #>(AIR_ACCEL)
        sta ax1  
	lda #>(AIR_ACCEL>>8)
        sta ax0
        
.done

SetWalkFlag: subroutine
	lda #FLG_HMOVE | FLG_WALK
	ora flags
        sta flags

NotRight  
	lda pad
        and padedge
        and #%00000001
        beq .nright
        lda flags+BACKUP_OFFSET
        and #FLG_HMOVE_DIR
        beq .nright
        bne .rotate
.nright       
        lda pad
        and padedge
        and #%00000010
        beq .nrotate
        lda flags+BACKUP_OFFSET
        and #FLG_HMOVE_DIR
        bne .nrotate
.rotate
        lda #$8
        sta frame
        lda #6
        sta ftimer
.nrotate

 	
        ; 1- Are we trying to jump?
	; how long is it been since pressed jump? (0-window and then inf)
       	lda pad
        and padedge
        bpl .nedge
        ldx #0
        beq .change
.nedge
        ldx jbuffer
        inx
        beq .nchange
	cpx #BUFFER_WINDOW
        bcc .change
        ldx #$ff
.change
	stx jbuffer
.nchange

	
        ldx jbuffer
        inx
        beq .jstartdone
	lda #FLG_CEIL
        bit flags
        bne .jstartdone
	ldx coyote
        cpx #COYOTE_TIME
        lda #$81
        bcc .jstart
.nground
	lda coyote
        and #$1
        beq .jstartdone
	lda #$80
.jstart
        sta coyote
        ldx #0
        stx jtimer
        dex
        stx jbuffer
        lda #FLG_JUMPING
        ora flags
        sta flags
        
.jstartdone
	
        
        
        
 	; 0- are we already in a jump? update the timer
 	lda pad
        eor #$ff
        and padedge	; negative edge?
        bmi .jumpend
        lda jtimer
        cmp #MAX_JUMP
	beq .jumpend
	jmp .njumpend
.jumpend
	lda #$f7
        and flags
        sta flags
.njumpend

	lda #$8
        bit flags
        beq .njumping
        inc jtimer
.njumping

	;; Hooking
        bit flags
        bvc .hookend
        bpl .nrelease
        lda pad
        eor #$ff
        and #$40
        beq .nrelease
        ; release
        jsr Release
        
        jmp .hookend
.nrelease

	; attach
	lda pad
        and padedge
        and #$40
        beq .hookend
        lda hookidx
        bmi .hookend
        
        jsr Attach
.hookend

	rts