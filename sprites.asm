	; handles scrolling the sprites on the screen. hero sprite handled seperately
UpdateSprites: subroutine
	; clear oam objects before drawing
	lda #0
        ldx #$10
.cleardma
        sta $0200,x
        inx
        bne .cleardma
	
	lda scroll
        lsr
        sta tmp0


	ldx #0 ; object list
        ldy #0 ; oam
.next
	lda objlist,x
        bne .draw
	rts
.draw	
	clc		; Set Y pos
        asl
        asl
	sec
        sbc tmp0
        cmp #120
        bcc .onscreen
        lda #$ff
.onscreen
	clc
	asl
	sta $210,y
        iny		; Set Sprite and Pallete
        
        inx
	lda objlist,x
        and #$1c
        cmp #$10
        bne .nBouncy
        ; Bouncy
        
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


        iny		; Set X pos
        inx
        lda objlist,x
        and #$1f
        clc
        asl
        asl
        asl
        sta $210,y
        inx
        iny
        
        jmp .next



DrawHook: subroutine
        lda #$30
        bit flags
        bpl .nhooked
        cpy hookidx
        bne .nhooked	; set the sprite accordingly if it's close and/or hooked
	lda #$33
.nhooked
	sta $210,y
        
        iny		; set the pallete
	lda objlist,x
        and #$3
        sta $210,y
        
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