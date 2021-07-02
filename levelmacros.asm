
	MAC LEVEL_HEADER
        .byte {2}<<6 | {1}-1
        .byte {3}<<5 | {4}
        ENDM

	; 00000 - 00011
        MAC FIL
        .byte {2}<<2 | {1}
        ENDM

	; 00100 - 00111
	MAC BLK
        .byte {1} | $20
        .byte {2}
        .byte {3}<<4 | {4}
        ENDM
        
	; 01000 - 01011
        MAC HOK
        .byte {1} | $40
        .byte {3}<<6 | {2}
        ENDM
        
        ; 01100 - 01111
        MAC PIK
        .byte {1} | $60
        .byte {3}<<6 | {2}
        ENDM
        
        ; 10000 - 10011
        MAC BNC
        .byte {1} | $80
        .byte {3}<<6 | {2}
        ENDM
        
        MAC OBJ
        .byte {1} | $A0
        .byte {3}<<6 | {2}
        ENDM
        
