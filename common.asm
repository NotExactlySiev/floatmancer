HardReset: subroutine
	jsr ClearLevel
        jsr FindLevel
        jsr LoadLevel
        jsr RenderLevel
	jsr UpdateSprites
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