UpdatePlayer: subroutine
        lda py0
        sec
        sbc #5
        sta $200
        
        lda px0
        sec
        sbc #4
        sta $203
        
        lda #1
        bit flags
        beq .nrotate
        lda flags
        asl
        asl
        and #$40
        sta $202
.nrotate        

	lda frame
        beq .nbobbing
	cmp #$6
        bcs .nbobbing
        and #1
        bne .nbobbing
        dec $200
.nbobbing

        rts

; handles scrolling the sprites on the screen. hero sprite handled seperately
UpdateSprites: subroutine
	; clear oam objects before drawing
        ldx #$10
	jsr ClearDMA
	
	lda scroll
        lsr
        sta tmp0
        
        lda scrollx
        lsr
        sta tmp1

	ldx #0 ; object list
        ldy #0 ; oam
.next
	lda objlist,x
        bne .draw
	rts
.draw	
	; maybe we don't need to write all 4 field of oam every time
        ; just update the y position and don't touch the rest since the
        ; objlist doesn't change. we only need to write the chr index and
        ; attr once when loading the level.
        ; on the other hand i don't wanna limit myself to static levels
        ; with object that don't change or move around and this doesn't 
        ; take processing time anyway so...	
        asl	; Set Y pos
        asl
	sec
        sbc tmp0
        cmp #120
        bcc .onscreen
        ; it's not in the viewport. put it offscreen and go to next obj
        lda #$ff
        sta $210,y
        
        cpy #252
        bcs .spritedone
.onscreen
	asl
	sta func0	; is on screen, load the data for the object
        
        inx
	lda objlist,x
        sta func1
        inx
        lda objlist,x
        asl
        asl
        sec
        sbc tmp1 ; this is a temporaty solution
        asl
        sta func2
        inx
        
        txa
        pha
        
        lda func1
        and #$1c
        cmp #$10
        bne .nBouncy
        ; Bouncy
        jsr DrawBouncy
        jmp .spritedone
.nBouncy
	cmp #$14
        bne .nBig
        ; Big
        jsr DrawBig
        jmp .spritedone
.nBig
	cmp #$18
        bne .nHook
        ; Hook
        jsr DrawHook
        jmp .spritedone
.nHook
	; Pickup
        
        
.spritedone

	pla
        tax
        
        jmp .next


BouncyFlip:
	.byte $00, $40
        .byte $80, $c0
        .byte $00, $80
        .byte $40, $c0

DrawBouncy: subroutine
	lda func0
        sta $210,y
        sta $214,y
        sta $218,y
        iny
        
        lda func1
        and #$2
        sta func4
        clc
        adc #$40
        sta $210,y
        sta $218,y
        adc #1
        sta $214,y
        iny
        
        lda func1
        asl
        and #$6
        tax
        lda BouncyFlip,x
        sta $210,y
        sta $214,y
        inx
        lda BouncyFlip,x
        sta $218,y
        iny
        
        lda func2
        sta $210,y
        sta $214,y
        sta $218,y
	
        lda func4
        beq .ver
    	dey
        dey
        dey
.ver
        lda $210,y
        clc
        adc #$8
        sta $214,y
        adc #$8
        sta $218,y

	lda func4
        beq .ver2
        iny
        iny
        iny
.ver2	iny

        rts


DrawHook: subroutine
	lda func0
        sta $210,y
        iny
        
        lda #$30
        bit flags
        bpl .nhooked
        cpy hookidx
        bne .nhooked	; set the sprite accordingly if it's close and/or hooked
	
        lda #$33
.nhooked
	sta $210,y
        iny
        
	lda func1 ; set the pallete
        and #$3
        sta $210,y
        iny
        
        lda func2
        sta $210,y
        iny
        
        rts

DrawBig: subroutine ; draws one of four meta sprite objects
	lda objlist,x
        and #$f
        clc
        adc #4
        asl
        asl
        sta $210,y
        
        iny
        lda #1
        sta $210,y
        
        rts