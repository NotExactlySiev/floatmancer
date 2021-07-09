

	lda #1
	sta JOYPAD1
        lda #0
        sta JOYPAD1
        
        
        ; read pad data, xor with last frame's pad data to get edges
        clc
	ldx #8
.readpad
	asl pad
        lda JOYPAD1
        and #$1
        ora pad
        sta pad
        dex
        bne .readpad
        
	eor padold
        sta padedge

	lda pad
        sta padold

	lda loop
        bne GameInput
        jmp ControlInput

GameInput:
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

ControlInput:
	lda pad
        and padedge
        and #$20
        beq .lvlend
        
        lda #$00
        sta PPU_MASK
        sta PPU_CTRL
        jsr WaitSync
        
        
        
        ldx lvl
        inx
        
        bit pad
        bvc .nback
        dex
        dex
.nback
        
        stx func0

        
        jsr HardReset
        jsr WaitSync
        
        jsr WaitSync
        
        lda #$1e
        sta PPU_MASK
        lda #$80
        ldy PPU_STATUS
        sta PPU_CTRL

	jmp NMIEnd

        
.lvlend



	lda pad
        and padedge
        and #$10
        beq .pauseend
        jsr PlaySequence        
        lda loop
        eor #$1
        sta loop
.pauseend