
LoadPallete: subroutine
	PPU_SETADDR $3f00
        ldx #$0
.loop   lda Pallete,x
        sta PPU_DATA
        inx
        cpx #$20
        bne .loop
        rts


	; finds the first zero byte after Y
FindEmptyZp: subroutine
	lda $00,Y
        bne .found
	inx
	bne FindEmptyZp
.found  rts


	; finds the first zero byte in page A after AY
FindEmpty: subroutine
	sta tmp3
.loop
        lda (tmp3),y
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