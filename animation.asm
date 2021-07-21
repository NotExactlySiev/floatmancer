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
	lda #$0
        ldx vy0
        bmi .upwards
	lda #$3
.upwards
	bne .spritedone

.ground
	;;; GROUND ANIMATION
        bit flags+BACKUP_OFFSET
        bvc .nlanded
        lda #$10
        bne .spritedone
        
.nlanded
        
        lda flags	; RUNNING ANIMATION
        and #1
        beq .nrunning
	
	dec ftimer
        bne .sameframe
        lda #5
        sta ftimer
        
        lda $201
        cmp #$8
        bne .nrotate
        lda #3
        sta ftimer
        lda vx0
        bmi .left
        cmp #$2
        bcs .fast
        bcc .slow
.left
	cmp #$fe
        bcc .fast
.slow
	lda #$9
        bne .spritedone
.fast
	lda #$2
        bne .spritedone

.nrotate
	cmp #$9
        bne .nfastdone
        lda #2
        bne .nwrap
        
.nfastdone
        clc
        adc #1		; next frame
        cmp #$6
        bcc .nwrap
        lda #2	 	; wrap around
.nwrap  
	sta frame
.sameframe
        lda #1
        bit frame
        bne .nobobbing
        dec $200
.nobobbing      
        jmp .animationover
.nrunning

	lda flags
        and #2
        beq .nmoving
	ldx #4
        jsr PlaySequence
	lda #6
        bne .spritedone
.nmoving
	;; IDLE ANIMATION
	lda #1
        sta ftimer
	lda #$0


.spritedone
        sta frame
.animationover
	rts