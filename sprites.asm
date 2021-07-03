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
        
        
        inx
	lda objlist,x	; Set Sprite and Pallete
        and #$e0
        cmp #$80
        bne .nBouncy
        ; Bouncy
        
        jmp .spritedone
.nBouncy
	cmp #$a0
        bne .nBig
        ; Big
        
        jmp .spritedone
.nBig
	cmp #$c0
        bne .nHook
        ; Hook
        jsr DrawHook
        jmp .spritedone
.nHook
	; Pickup
        
        
.spritedone


        iny
        lda objlist,x
        and #$1f
        clc
        asl
        asl
        asl
        sta $210,y	; set x pos
        inx
        iny
        jmp .next



DrawHook: subroutine
	iny
        lda #$30
        bit flags
        bpl .nhooked
        cpy hookidx
        bne .nhooked	; set the sprite accordingly if it's close and/or hooked
	lda #$33
.nhooked
	sta $210,y
        
        inx
        iny		; set the pallete
	lda objlist,x
        lsr
        lsr
        lsr
        and #$3
        sta $210,y
        rts
