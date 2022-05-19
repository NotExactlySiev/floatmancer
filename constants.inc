; turning certain mechanics on and off
; TODO: implement all of these, so we can try different combinaitons of mechanicas
; and see what works, removing the rest
ENABLE_FLING	= 0
ENABLE_UNFLING	= 1 ; reduce speed at release (if above threshold)
ENABLE_COOLDOWN	= 0 ; not implemented yet
ENABLE_GLIDE	= 0 ; not implemented yet
ENABLE_BHOP	= 0 ; not implemented yet
ENABLE_AIR_RES	= 1 ; slow down mid air if not directly controlled
ENABLE_STRETCH	= 0 ; radius changes when on hook and colliding
LIMIT_ROT	= 0 ; not implemented yet

; physics values
UP_GRAVITY	= $006000
DOWN_GRAVITY	= $003500
MAX_FALL	= $056010 ; doesn't do anything yet :/
JUMP_FORCE	= $035000
FLING_FORCE_H	= 6
FLING_FORCE_V	= 6
WALK_ACCEL	= $006a80
AIR_ACCEL	= $004100 ;$006080
AIR_RES		= $000600
MAX_WALK	= $00D000 ;$010cc0
MAX_SPEED	= 4 ; absolute max speed value permitted by the engine
AIR_ACCEL_LIMIT	= $00C800 ;$009cc0 ; you are not allowed to accelerate on air if your velocity is higher than this
HOOK_SWING	= 108
HOOK_RANGE	= 48


; frame times
MAX_JUMP	= 8 ; how many frames you can hold jump for
COYOTE_TIME	= 5
BUFFER_WINDOW	= 3
BHOP_WINDOW	= 2 ; not implemented yet


WINDUP_TIME	= $1 ; jump delay

SIN_HEAD	= $c0
PYTAN_HEAD	= $e0
LEVEL_HEAD	= $98

SCROLL_THOLD	= 90
SCREEN_HEIGHT	= 240
SCREEN_WIDTH	= 256
MARGIN		= 8

MENU_ITEMS	= 3