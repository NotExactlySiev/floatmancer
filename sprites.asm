UpdatePlayer: subroutine
        lda py0
        bcc .topscreen
	adc #7
.topscreen
        sec
        sbc #5
        sta $200
        
        lda px0
        sec
        sbc #4
        sta $203
        rts

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
        sta $210,y
        iny
        iny
        iny
        iny
        bne .next
.onscreen
	asl
	sta func0	; if is on screen, load the data for the object
        
        inx
	lda objlist,x
        sta func1
        inx
        lda objlist,x
        clc
        asl
        asl
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