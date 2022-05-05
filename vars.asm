;;;;;;;;;;;;;;;;;;;;;;;
;;; LOCAL VARIABLES ;;;
;;;;;;;;;;;;;;;;;;;;;;;

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


;;;;;;;;;;;;;;;;;;;;;;;;
;;; GLOBAL VARIABLES ;;; C-18
;;;;;;;;;;;;;;;;;;;;;;;;

; TODO: some of these that aren't accessed more than a few times every frame
; can be moved out of zero page to make space for bigger obj and col tables

lvlptr	= $C
lvl	= $E
lvlsize	= $F

pad	= $10
padold	= $11
padedge	= $12

darkness = $13

state	= $14
STATE_TRAN	= $0 ; in between states. nothing is updated in nmi
STATE_PLAY	= $1 ; in levels. the main game loop, physics etc. are running
STATE_MENU	= $2 ; in main menu. menu logic is running

;;; SEQUENCE
sqvar0	= $15
sqvar1	= $16
sqtimer	= $17
sqidx	= $18


;;;;;;;;;;;;;;;;;;;;;;;
;;; STATE VARIABLES ;;; 19-50
;;;;;;;;;;;;;;;;;;;;;;;

;;; LEVEL GENERATION
blknum	= $40
filbyte	= $41

blkptr1	= $42
blkptr2	= $43

sidestmp = $44


;;; MENU
select	= $20

code0	= $21
code1	= $22
code2	= $23
code3	= $24
typing	= $25
codeidx	= $26

world	= $27


options	= $80


;;; GAME

; turn on and off
loop	= $19
anim	= $1A
physics	= $1B

coyote	= $1C ; how many frames ago you were on the ground?
jbuffer	= $1D ; how many frames ago you pressed jump?
jtimer	= $1E ; jump timer
ftimer	= $1F ; frame timer

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

py0	= $33	; in relation to other objects on the screen, doesn't account for scroll
py1	= $34

angle0	= $36	; angle from the hook. 24 bit (should be 16?)
angle1	= $37
angle2	= $38
radius	= $39	; radius from the hook. 8 bit (but actually 7)
hookpx	= $3A	; hook pixel position. 8 bit
hookpy	= $3B

frame	= $3C	; character's animation frame index

scroll	= $3D	; screen scroll. [0, 240]
flags	= $3E ; hook mode | on air | on ceiling | direction | jumping | ------- | moving | active moving
scrollx	= $400
roomtran	= $401

	
; $40-$4E are the same but from the previous frame




;;;;;;;;;;;;;;;;;;;;;;;
;;; TABLES AND DATA ;;;
;;;;;;;;;;;;;;;;;;;;;;;

objlist	= $50
collist	= $80

lvldat		= $100
basepalette	= $170 ; - $1EE

; $200-$2FF is OAM DMA

sequence	= $310