
	include "nesdefs.dasm"	
	include "levelmacros.asm"
        
	include "vars.asm"


; physics values
UP_GRAVITY	= $006000
DOWN_GRAVITY	= $003500
MAX_FALL	= $056010 ; doesn't do anything yet :/
JUMP_FORCE	= $035000
FLING_FORCE_H	= 6
FLING_FORCE_V	= 6
WALK_ACCEL	= $006a80
AIR_ACCEL	= $003080
MAX_WALK	= $009cc0
AIR_ACCEL_LIMIT	= $009cc0 ; you are not allowed to accelerate on air if your velocity is higher than this
HOOK_SWING	= 27
HOOK_RANGE	= 60

; frame times
MAX_JUMP	= 9 ; how many frames you can hold jump for
COYOTE_TIME	= 5
BUFFER_WINDOW	= 3
BHOP_WINDOW	= 2 ; not implemented yet


WINDUP_TIME	= $1 ; jump delay

SIN_HEAD	= $c0
PYTAN_HEAD	= $e0
LEVEL_HEAD	= $98

BACKUP_OFFSET	= $10

SCROLL_THOLD	= 90
SCREEN_HEIGHT	= 240
SCREEN_WIDTH	= 256
MARGIN		= 8

MENU_ITEMS	= 3

	org $0

	;;; HEADER        
	NES_HEADER 0,2,1,0 ; mapper 0, 2 PRGs, 1 CHR, horiz. mirror

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
        lda #0
        sta PPU_SCROLL
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
	;; PPU WRITES
        jsr UpdatePlayer
        
        jsr ControlInput
        
        lda loop
        bne .gameloop
        jmp NMIEnd
.gameloop
                
	;; GAME LOOP
        bit anim
        beq .nanim
	jsr CharacterAnimation
.nanim        
        lda frame
        sta $201

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
        
        
	include "common.asm"
        include "physics.asm"
	include "hookmode.asm"   
	include "collision.asm"
	include "math.asm"
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


	;; sequence data
CallTableHi:
	.byte >(ClearLevel-1), >(SetDarkness-1), >(InitPlay-1), >(UpdateSprites-1)
        .byte >(ClearState-1), >(ClearDMA-1), >(LoadLevel-1), >(RenderLevel-1)
        .byte >(DisablePPU-1), >(EnablePPU-1), 0, 0
        .byte 0, 0, 0, 0

CallTableLo:
	.byte <(ClearLevel-1), <(SetDarkness-1), <(InitPlay-1), <(UpdateSprites-1)
        .byte <(ClearState-1), <(ClearDMA-1), <(LoadLevel-1), <(RenderLevel-1)
        .byte <(DisablePPU-1), <(EnablePPU-1), 0, 0				; DO NOT wait after disabling ppu
        .byte 0, 0, 0, 0


SequencesTable:
	.byte SEQ_FadeOut-Sequences
        .byte SEQ_FadeIn-Sequences
        .byte SEQ_ResetLevel-Sequences
        .byte SEQ_Death-Sequences
        .byte SEQ_PlayerStop-Sequences
        .byte SEQ_InitLevel-Sequences
Sequences:
SEQ_FadeOut:
	.byte $61, $13, $21, $02, $82, $21, $02, $83, $21, $02, $84, $21, $00
SEQ_FadeIn:
	.byte $63, $13, $21, $02, $82, $21, $02, $81, $21, $02, $80, $21, $00
SEQ_ResetLevel:
	.byte $40, $45, $41, $00
SEQ_Death:
	; i stopped changing the state and it stopped randomly scrolling at death
	; .byte $60, state
        ; TODO: death animation
	.byte $42, $00
SEQ_PlayerStop:	; i don't think we need this
	.byte $60, $95, $02, $67, $3C, $02, $88, $01, $60, $26, $60, $27, $00
SEQ_InitLevel:
	.byte $28, $20, $25, $26, $27, $23, $22, $29, $00


Animations:
ANIM_Idle:
	.byte $0, $6, $6, $6, $6, $6, $7, $0
        .byte $9, $0, $0, $0, $0, $0, $0, $0

ANIM_Run:
	.byte $5, $2, $3, $4, $1, $2, $4, $4
        .byte $4, $5, $0, $0, $0, $0, $0, $0


	org LEVEL_HEAD<<8
	include "leveldata.asm"

        ; math look up tables
        org SIN_HEAD<<8
        include "sinetable.asm"    
	include "pythtantable.asm"
        
Text:
Worlds:
        dc "TSACGNUJ"
MenuOptions:
	dc "]    LE^", 0, "CODE@@[[[[", 0, "SPEEDRUN", 0

        dc "PRESS A TO JUMP", 0
	dc "PRESS AND HOLD B WHEN CLOSE TO THE", 27, "PURPLE HOOK TO SWING FROM IT", 0

TXT_Credits:
        dc "A@GAME@BY@SIEV", 0

	;;; VECTORS  
	NES_VECTORS




	;;; CHR ROM
	incbin "chars.chr"