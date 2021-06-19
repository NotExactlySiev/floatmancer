	lda #0
        sta ax2
        sta ax1
        sta ax0
        
	lda #$FA
        and flags
        sta flags

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
        
	eor pad+BACKUP_OFFSET
        sta padedge


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


        lda pad
        and padedge
        bpl .njumpstart
        bit flags
        bvs .njumpstart
	lda #$20
        bit flags
        bne .njumpstart
        
        lda #0
        sta jtimer
        lda #$8
        ora flags
        sta flags
.njumpstart

	



