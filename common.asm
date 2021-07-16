DisablePPU: subroutine
	lda #0
        sta PPU_MASK
        lda #$08
        sta PPU_CTRL
	rts
        
EnablePPU: subroutine
	lda #$18
        sta PPU_MASK
        lda #$18
        sta PPU_CTRL
	rts

InitPlay: subroutine
	ldx #$ff
        stx hookidx
        stx jbuffer
        inx
        stx vx1
        stx vx0
        stx vx2
        stx vy0  
        inx
        stx loop
        stx physics
        stx anim
        rts
        

ClearState: subroutine
	lda #0
        ldx #$38
.loop   sta $18,x
        dex
        bne .loop
	rts

	; call only once per frame, otherwise the edge data would be lost
ReadPad: subroutine
	ldx #1
	stx JOYPAD1
        dex
        stx JOYPAD1
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
	rts    


	; use this to jsr to indirect address, index x from 
CallFromTable: subroutine
	lda CallTableHi,x
        pha
        lda CallTableLo,x
        pha
        rts

	; clears DMA from x onwards
ClearDMA: subroutine
	lda #0
.loop
        sta $0200,x
        inx
        bne .loop
	rts

; finds the first zero byte after X
FindEmptyZp: subroutine
.loop
	lda $00,x
        beq .found
	inx
	bne .loop
.found  rts


	; finds the first zero byte in page A after AY
FindEmpty: subroutine
	sta tmp3
	lda #0
        sta tmp2
.loop
        lda (tmp2),y
        beq .found
        iny
        bne .loop
.found	rts


; reverses horizontal acceleration
NegativeAclX: subroutine
	clc
        lda ax2
        eor #$ff
        adc #1
        sta ax2
        lda ax1
        eor #$ff
        adc #0
        sta ax1
        lda ax0
        eor #$ff
        adc #0
        sta ax0
        rts


ClearRAM: subroutine
	lda #0
        tax
.clearRAM
	sta $0,x	; clear $0-$ff
        cpx #$fe	; last 2 bytes of stack?
        bcs .skipStack	; don't clear it
	sta $100,x	; clear $100-$1fd
.skipStack
	sta $200,x	; clear $200-$2ff
	sta $300,x	; clear $300-$3ff
	sta $400,x	; clear $400-$4ff
	sta $500,x	; clear $500-$5ff
	sta $600,x	; clear $600-$6ff
	sta $700,x	; clear $700-$7ff
        inx		; X = X + 1
        bne .clearRAM	; loop 256 times
        rts


WaitSync: subroutine
	bit PPU_STATUS
	bpl WaitSync
        rts

PPUFormat: subroutine ; 0-1 xy -> 6-7 PPU memory address
	lda func0
        cmp #30
        bcc .screen
        sec		; TODO: this part is broken? writes to weird places
        adc #$21	; ready for shifting to become ppu 2000 or 2800
.screen
	clc
        ror		; this should be a subroutie 0-1 -> 6-7
        ror
        ror
        ror
        sta func6
	and #$e0
        ora func1
        sta func7
        lda func6
        rol
        and #$0f
        ora #$20
        sta func6
        rts