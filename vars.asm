
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
darkness = $13

; turn on and off
loop	= $14
anim	= $15
physics	= $16

;; SEQUENCE VARIABLES
sqvar0	= $17
sqvar1	= $18
sqtimer	= $19
sqidx	= $1A



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

sidestmp = $24

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

frame	= $3C	; character's animation frame index

scroll	= $3D	; screen scroll. [0, 240]
flags	= $3E	; hook mode | on air | on ceiling | direction | jumping | ------- | moving | active moving

; $40-$4E are the same but from the previous frame
objlist	= $50
collist	= $80

lvldat		= $100
basepalette	= $170 ; - $1EE

; $200-$2FF is OAM DMA

sequence	= $310