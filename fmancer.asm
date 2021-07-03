
	include "nesdefs.dasm"
	
	include "levelmacros.asm"


; maybe change the item types 00 for objects 10 for dirt

;;;;; VARIABLES

;; LOCAL VARIABLES
func0	= $0
func1	= $1
func2	= $2
func3	= $3
func4	= $4
func5	= $5
func6	= $6
func7	= $7

tmp0	= $8
tmp1	= $9
tmp2	= $A
tmp3	= $B

; pointers
lvlptr	= $C
lvl	= $E
lvlsize	= $F

;; GAME VARIABLES

pad	= $10
padold	= $11
padedge	= $12
paused	= $13

;; LEVEL VARIABLES

coyote	= $1C ; how many frames ago you were on the ground?
jbuffer	= $1D ; how many frames ago you pressed jump?
jtimer	= $1E ; jump timer
ftimer	= $1F ; frame timer


; level generation variables
blknum	= $20
filbyte	= $21

blkptr1	= $22
blkptr2	= $23

; set 1 variables
ax0	= $20
ax1	= $21
ax2	= $22
ay0	= $23
ay1	= $24
ay2	= $25
vx0	= $26
vx1	= $27
vx2	= $28
vy0	= $29
vy1	= $2A
vy2	= $2B
omega0	= $2C	; angular momentum. 24 bit (should be 16?)
omega1	= $2D
omega2	= $2E
hookidx	= $2F	; hook index in oam dma

; set 2 variables - backed up every frame

px0	= $30
px1	= $31
relpx0	= $32	; x and y distance from the hook. 8 bit

py0	= $33	; in relation to other objects on the screen, doesn't account for scroll
py1	= $34
relpy0	= $35

angle0	= $36	; angle from the hook. 24 bit (should be 16?)
angle1	= $37
angle2	= $38
radius	= $39	; radius from the hook. 8 bit (but actually 7)
hookpx	= $3A	; hook pixel position. 8 bit
hookpy	= $3B

scroll	= $3C	; screen scroll. [0, 240]
flags	= $3D	; hook mode | on air | on ceiling | direction | jumping | ------- | moving | active moving



BACKUP_OFFSET = $10

; $40-$5F are the same from last frame

lvldat	= $100
objlist	= $80
collist	= $a8

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