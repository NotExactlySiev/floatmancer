
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
        lda #$1
        ldx jtimer
        cpx #WINDUP_TIME
        bcs .jwindup
        lda #$10
.jwindup
        bne .spritedone

.ground
	;;; GROUND ANIMATION
        lda flags	; RUNNING ANIMATION
        and #1
        beq .nrunning
	
	dec ftimer
        bne .sameframe
        lda #4
        sta ftimer
        lda $201
        clc
        adc #1		; next frame
        cmp #$6
        bne .nwrap
        lda #$2 	; wrap around
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