	include "nesdefs.dasm"	
	include "levelmacros.asm"
	include "constants.inc"        
	include "vars.asm"


	org $0

	;;; HEADER        
	NES_HEADER 0,2,1,0 ; mapper 0, 2 PRGs, 1 CHR, horiz. mirror

        ;;; this is a teest for push

        ;;; INIT
Start:	
	include "init.asm"

	;;; MAIN LOOP
.endless	
        jmp .endless

NMIHandler:
	jsr SequenceFrame
        jsr ReadPad	; putting this after diable nmi causes bugs :/
        
        
        lda state
        bne .ntransition
        rti
.ntransition
        
        ; disable nmi, set nametable
	ldx scrollx
        inx
        stx PPU_SCROLL
        ldx #$08
        lda scroll
        cmp #240
        bcc .notend
        lda #0
        ldx #$0A
.notend
        sta PPU_SCROLL
        stx PPU_CTRL
        lda #02
        sta PPU_OAM_DMA
        


	lda state
        cmp #STATE_PLAY
        beq .playing
	jsr UpdateMenu
        jsr MenuInput
	jmp NMIEnd

.playing

        bit anim
        beq .nanim
	jsr CharacterAnimation
.nanim        
        lda frame
        sta $201
        
	;; PPU WRITES
        jsr UpdatePlayer
        
        jsr ControlInput
        
        lda loop
        bne .gameloop
        jmp NMIEnd
.gameloop
                
	;; GAME LOOP


	jsr UpdateSprites

        bit flags
        bmi .nosearch
        jsr FindCloseHook
.nosearch 

	jsr PlayInput
	; backup variables from last frame
	ldx #$f
.copyold
	lda $30,x
        sta $40,x
        dex
        bpl .copyold

	; do physics calculations based on mode
        lda physics
        beq .physdone
        
        bit flags
        bmi .hook
        jsr NormalMode
        jmp .physdone
.hook
	jsr HookMode
.physdone

	jsr UpdateScroll
        ;checking if the player has fallen outside the level        
	lda py0
        cmp #239
        bcc .noutside
	ldx #3
        jsr PlaySequence
        jmp NMIEnd
.noutside

	ldx #2
        ldy #$7F
	; room transition when crosses screen boundry
	lda px0
        cmp #LEFT_BOUND
        bcc .toleft
        cmp #RIGHT_BOUND
        bcs .toright     
        bcc .ntran

.toright
	inx
        iny
.toleft
	sty tmp3
	txa
        ; look for exits that match this direction
        ldx #$8
.next        
        dex
        bmi .nroom
        cmp exits,x
	bne .next
	lda exits_room,x
	
        clc
        adc lvl
	sta func0
        
        ; now check if offset works
        lda scroll
        lsr
        lsr
        clc
        adc exits_off,x ; this only overflows if offset is negative
        ; in fact, if it doesn't overflow when offset is negative, it should
        ; be considered an underflow
        cmp #$3C+1
        bcc .nover
        sec
        sbc #$3C
        asl
        asl
        asl
        clc
        adc py0
        ; now if this one over or underflows the exit shouldn't work since it
        ; leads the player out of bounds
	; OH MY GOD I JUST REALIZED WHAT THE OVERFLOW FLAG IS FOR
        bvs .next
        
        sta py0
        lda #$3C
.nover
        asl
        asl
        sta scroll
        
        jsr FindLevel

	lda tmp3
        eor #%01110000	; reducing the intensity
        sta scrollx	; or remove this line for a hard cut

        ldx #SEQ_ROOMTRAN
        jsr PlaySequence
        inc $3FF ; TODO: name this var
        lda px0
        eor #$ff
        sta px0
.nroom
	ldx #LEFT_BOUND
	lda px0
        bpl .pushleft
        ldx #RIGHT_BOUND
.pushleft
        stx px0
.ntran


NMIEnd:
	; enable nmi, set nametable
        ldx #$88
        lda scroll
        cmp #240
        bcc .notend2
        ldx #$8A
.notend2
	ldy PPU_STATUS
        stx PPU_CTRL
        
        rti


        ;;; SUBROUTINES
PlayerDeath: subroutine
	ldx #3
        jsr PlaySequence
        ldx #0
        stx physics
        pla
        pla
        ; alternate method below. isn't much different but is faster so the nmi routine
        ; ends before vblank finishes
        ;ldx #$fc
        ;txs
        ;jmp NMIEnd
        rts
        
    	include "math.asm"

	include "common.asm"
        include "physics.asm"
	include "hookmode.asm"   
	include "collision.asm"
        include "scroll.asm"	
	include "text.asm"

	include "menu.asm"
	include "animation.asm"

	include "input.asm"

	include "sequence.asm"

	include "palette.asm"

	include "level.asm"
	include "sprites.asm"

        ;;; DATA

	include "sequencedata.asm"

Animations:
ANIM_Idle:
	.byte $0, $6, $6, $6, $6, $6, $7, $0
        .byte $9, $0, $0, $0, $0, $0, $0, $0

ANIM_Run:
	.byte $4, $2, $3, $4, $1, $2, $4, $4
        .byte $4, $5, $0, $0, $0, $0, $0, $0


	org LEVEL_HEAD<<8
	include "leveldata.asm"

        ; math look up tables
        org SIN_HEAD<<8
        include "sinetable.asm"    

        ;; color data
CastlePalette:
	.hex 0f
        .hex 102d00
        .hex 2d1a30
        .hex 0b1a07
        .hex 0b1a07
        .hex 041320
        .hex 041903
        .hex 24152d
        .hex 111111
        
HueShift:	; hues to shift into for each dark color before going to black
	.byte 1, 15, 1, 4, 15, 4, 7, 15, 15, 8, 15, 12, 15, 15, 15, 15
DarkTable:	; where the palettes of each darkness degree are located
	.byte basepalette, basepalette+25, basepalette+50, basepalette+75, basepalette+100

	;; texts
	org $ff00
Text:
Worlds:
        dc "TSACGNUJ"
MenuOptions:
	dc "]    LE^", 0, "CODE@@[[[[[[", 0, "SPEEDRUN", 0

        dc "PRESS A TO JUMP", 0
	dc "PRESS AND HOLD B WHEN CLOSE TO THE", 27, "PURPLE HOOK TO SWING FROM IT", 0

TXT_Credits:
        dc "A@GAME@BY@SIEV", 0

	;;; VECTORS
      
	NES_VECTORS




	;;; CHR ROM
	incbin "chars.chr"
