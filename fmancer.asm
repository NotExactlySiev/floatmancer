
	include "nesdefs.dasm"	
	include "levelmacros.asm"
        
	include "vars.asm"


;; Physics Constants
GRAVITY	        = $007000
MAX_FALL	= $056010
JUMP_FORCE	= $035000
WALK_ACCEL	= $006a80
MAX_WALK	= $015000
PASSIVE_DECEL	= $003540
HOOK_SWING	= 35
HOOK_RANGE	= 60
MAX_JUMP	= 7
COYOTE_TIME	= 5
BUFFER_WINDOW	= 3
MARGIN		= $8

SIN_HEAD	= $a0
PYTAN_HEAD	= $e0
LEVEL_HEAD	= $90

BACKUP_OFFSET	= $10

SCROLL_THOLD	= 90
SCREEN_HEIGHT	= 240
SCREEN_WIDTH	= 256

	org $0

	;;; HEADER        
	NES_HEADER 0,2,1,0 ; mapper 0, 2 PRGs, 1 CHR, horiz. mirror




        ;;; INIT
Start:	
	include "init.asm"




	;;; MAIN GAME LOGIC      
.endless	
        jmp .endless

NMIHandler:       
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

	
	lda paused
        bne GamePaused
        ; set hero sprite

        lda py0
        bcc .topscreen
	adc #7
.topscreen
        sec
        sbc #5
        sta $200
	include "animation.asm"
.spritedone
        
        ; draw sprites
        lda #02
        sta PPU_OAM_DMA
	
        bit flags
        bmi .nosearch
        jsr FindCloseHook
.nosearch 

GamePaused:

	include "readpad.asm" 

	lda paused
        bne NMIEnd

	; backup variables from last frame
	ldx #$f
.copyold
	lda $30,x
        sta $40,x
        dex
        bpl .copyold

	; do physics calculations based on mode
        bit flags
        bmi .hook
        jsr NormalMode
        jmp .physdone
.hook
	jsr HookMode
.physdone

	include "scroll.asm"

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
	include "common.asm"
        include "physics.asm"
	include "hookmode.asm"   
	include "collision.asm"
	include "math.asm"
        
	include "level.asm"
	include "sprites.asm"


        ;;; DATA
Pallete:
	.hex 1d
        .hex 10002d 00
        .hex 0b1a07 00
        .hex 0b1a07 00
        .hex 0b1a07 1d
        .hex 041320 00
        .hex 041903 00
        .hex 24152d 00
        .hex 000000 00

	org LEVEL_HEAD<<8
	include "leveldata.asm"

        ; math look up tables
        org SIN_HEAD<<8
        include "sinetable.asm"    
	include "pythtantable.asm"

Text:
	dc "WELCOME TO FLOATMANCER!", 0

	;;; VECTORS  
	NES_VECTORS




	;;; CHR ROM
	incbin "chars.chr"