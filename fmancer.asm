
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




	;;; MAIN LOOP
.endless	
        jmp .endless


StartAnimation:
	sta anim
        pla
        sta animreturn+1
        pla
        sta animreturn
        lda #0
        sta animcounter
        jmp NMIEnd

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

	;; PPU WRITES
        jsr UpdatePlayer
        
        
        lda anim
        beq .nanim
        ldx animcounter
        inx
        stx animcounter
        
        cmp #1
        bne .nfadeout
        
        cpx #4
        bcc .animdone
        ldy darkness
        iny
        cpy #5
        beq .animfinish
        sty darkness
        jsr SetDarkness
	ldx #0
        stx animcounter
        jmp .animdone
.nfadeout
	
        cmp #2
        bne .nfadein
        
        cpx #4
        bcc .animdone
        ldy darkness
        dey
        cpy #$ff
        beq .animfinish
        sty darkness
        jsr SetDarkness
        ldx #0
        stx animcounter
        jmp .animdone
.nfadein

.animfinish
	lda #0
        sta anim
        lda animreturn
        pha
        lda animreturn+1
        pha
        rts
.animdone
	jmp NMIEnd
.nanim
	;; GAME LOOP
        
	lda loop
        beq GamePaused
        ; set hero sprite


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

	lda loop
        beq NMIEnd

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
        
	include "palette.asm"

	include "level.asm"
	include "sprites.asm"

PlayerDeath: subroutine
	
	rts


        ;;; DATA
CastlePalette:
	.hex 0f
        .hex 10002d
        .hex 0b1a07
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