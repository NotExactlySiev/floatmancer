
	lda #%01001000
        bit flags
        bne .air
        bpl .ground	

.hooking
	;;; HOOK ANIMATION
	lda #3
        bne .spritedone

.air
        ;;; AIR ANIMATION
        ldx jtimer
        cpx #WINDUP_TIME
        bcs .jwindup
        lda #$10
        bne .spritedone
.jwindup
	lda #$0
        ldx vy0
        bmi .upwards
	lda #$3
.upwards
	bne .spritedone

.ground
	;;; GROUND ANIMATION
        lda flags	; RUNNING ANIMATION
        and #1
        beq .nrunning
	
	dec ftimer
        bne .sameframe
        lda #5
        sta ftimer
        lda $201
        clc
        adc #1		; next frame
        cmp #$6
        bne .nwrap
        lda #2	 	; wrap around
.nwrap  
	sta $201
.sameframe
        lda #1
        bit $201
        beq .nobobbing
        dec $200
.nobobbing      
        jmp .animationover
.nrunning

	;; IDLE ANIMATION
	lda #1
        sta ftimer
	lda #$0


.spritedone
        sta $201
.animationover