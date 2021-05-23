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
	lda JOYPAD1	; B
	and #$1
        beq .nB
        		
.B	lda #$20
	bit Flags
        beq .nattach
	lda #$80
        bit Flags
        bne .nattach
        
        jsr Attach


.nattach
	lda #$20
        ora Flags
        sta Flags        
        jmp .Bend

.nB	
	lda #$20
        bit Flags
        beq .nrelease
	lda #$80
        bit Flags
        beq .nrelease
        
        jsr Release

.nrelease
	lda #$7f
        and Flags
        sta Flags

.Bend
	lda JOYPAD1	; Select
	and #$1
        beq .nSel
        
.nSel
	lda JOYPAD1	; Start
	and #$1
        beq .nStart
        
.nStart
	lda JOYPAD1	; Up
	and #$1
        beq .nUp
        
.nUp
	lda JOYPAD1	; Down
	and #$1
        beq .nDown
        
.nDown
	lda JOYPAD1	; Left
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
	lda JOYPAD1	; Right
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
        
