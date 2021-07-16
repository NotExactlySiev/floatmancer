ControlInput: subroutine
	lda pad
        and padedge
        and #$20
        beq .lvlend
	lda #1
        sta func0
        jsr FindLevel

        ldx #2
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
        
	lda #$FA
        and flags
        sta flags

	;; Walking
	lda #2
        bit pad
        beq .nLeft
        
	lda #<(-WALK_ACCEL)
        sta ax2
        lda #>(-WALK_ACCEL)
        sta ax1  
	lda #>((-WALK_ACCEL)>>8)
        sta ax0
        lda #$40
        ora $202
        sta $202
        
	jmp .flag
.nLeft
	lda #1
        bit pad
        beq .nRight

	lda #<(WALK_ACCEL)
        sta ax2
        lda #>(WALK_ACCEL)
        sta ax1  
	lda #>(WALK_ACCEL>>8)
        sta ax0
	lda #$bf
        and $202
        sta $202

.flag	lda #$3
	ora flags
        sta flags
.nRight
        
	
        ;; Jumping
        lda pad
        eor #$ff
        and padedge
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


	; how long is it been since pressed jump?
       	lda pad			; if A is pressed, start jump buffer timer
        and padedge
        bpl .nedge
        lda #0
        sta jbuffer
.nedge
        ldx jbuffer
        inx
        beq .nchange
	cpx #BUFFER_WINDOW	; if we reached the end of the window, reset and stop timer
        bcc .inwindow
        ldx #$ff
.inwindow
	stx jbuffer
.nchange        
        
        ; now both buffer and coyote timers are set, check if can jump
        lda flags
        and #$20
        bne .njumpstart
        lda flags
        and #$08
        bne .njumpstart
        lda coyote
        cmp #COYOTE_TIME
        bcs .njumpstart
        lda jbuffer
        cmp #BUFFER_WINDOW
        bcs .njumpstart
                
        lda #0
        sta jtimer
        lda #$8
        ora flags
        sta flags
.njumpstart

	;; Hooking
        bit flags
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