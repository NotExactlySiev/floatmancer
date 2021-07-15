

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
        beq .ngameinput
        jsr GameInput
.ngameinput

        
        
        


ControlInput:
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