CharacterAnimation: subroutine
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
	lda #$4
        ldx vy0
        bmi .upwards
	lda #$4
.upwards
	bne .spritedone

.ground
	;;; GROUND ANIMATION
        dec ftimer
        bne .animationover
        lda flags
        asl
        asl
        asl
        asl
        and #$10
        clc
        adc frame
        tax
        lda #5
        sta ftimer
        lda Animations,x
.spritedone
        sta frame
.animationover
	rts