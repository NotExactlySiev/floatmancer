LoadMenu: subroutine
	
        PPU_SETADDR $23C0
        ldx #0
.attr
	lda #$55
        sta PPU_DATA
        dex
        bne .attr
        
        lda #$24
        sta func0
        sta PPU_ADDR
        lda #$a7
        sta func1
        lda #$8a
        sta PPU_ADDR
        
        ldx #$b6
.title
        stx PPU_DATA
        inx
        cpx #$c8
        bcc .title


	ldx #$80
.logo
	lda func0
        sta PPU_ADDR
        lda func1
        sta PPU_ADDR
        
	ldy #18
.row        
        stx PPU_DATA
        inx
        dey
        bne .row
        lda func1
        clc
        adc #$20
        sta func1
        bcc .logo
        
	PPU_SETADDR $00
	rts