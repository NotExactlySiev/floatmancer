	lda #0
        sta ax2
        sta ax1
        sta ax0

	lda #$FA
        and Flags
        sta Flags

	lda #1
	sta JOYPAD1
        lda #0
        sta JOYPAD1
        
 

        lda JOYPAD1
        and #$1
        beq .nA

	lda #$4
        ora Flags
        sta Flags
        
        inc jtimer
        
        jmp .Aend
        
.nA	lda #0
	sta jtimer
        lda #$f7
        and Flags
        sta Flags
.Aend
	lda JOYPAD1
	and #$1
        beq .nB
        
        lda phase
        cmp #0
        bne .Bend
        jsr Attach
        
        
        jmp .Bend
.nB	
	lda phase
        cmp #5
        bne .Bend
        jsr Release
	
.Bend
	lda JOYPAD1
	and #$1
        beq .nSel
        
.nSel
	lda JOYPAD1
	and #$1
        beq .nStart
        
.nStart
	lda JOYPAD1
	and #$1
        beq .nUp
        
.nUp
	lda JOYPAD1
	and #$1
        beq .nDown
        
.nDown
	lda JOYPAD1
	and #$1
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
	lda JOYPAD1
	and #$1
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
	ora Flags
        sta Flags


.nRight
        
