
	MAC LEVEL_HEADER
.here:
        .byte {2}<<6 | {1}-.here-4
        .byte {3}<<5 | {4}
        ENDM
        
        MAC EXIT ; side room offset
        .byte {2} | {1}<<6 | {3}<<3
        ENDM
        
        MAC LEVEL_DATA
        .byte %00111000 ; other bytes are reserved for future use
        ENDM
        
	; 00000 - 00011
        MAC FIL ; select sides
        .byte {1}<<3 | {2}
        ENDM
        


	; 00100 - 00111
	MAC BLK ; x y width height
        .byte {1} | $20
        .byte {2}
        .byte {3}<<4 | {4}
        ENDM
        
        MAC SPK ; x y direction size
        .byte {1} | $40
        .byte {2} | {3}<<6
        .byte {4}
        ENDM
        
        MAC FLG ; x y color
        .byte {1} | $60
        .byte {2} | {3}<<6
        ENDM
        
        ; 10000 - 10011
        MAC BNC ; x y direction
        .byte {1} | $80
        .byte {3}<<6 | {2}
        ENDM
        
        ; 10100 - 10111
        MAC OBJ ; x y type
        .byte {1} | $A0
        .byte {3}<<6 | {2}
        ENDM
        
	; 11000 - 11011
        MAC HOK ; x y type
        .byte {1} | $C0
        .byte {3}<<6 | {2}
        ENDM
        
        ; 11100 - 11111
        MAC PIK ; x y type
        .byte {1} | $E0
        .byte {3}<<6 | {2}
        ENDM
        

        
