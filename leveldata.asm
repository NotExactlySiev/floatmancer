; stupid dasm doesn't understand my macros so here's how exit data works:
; EXIT A, B, C
; where A is which side of the room this exit is on: 0 up, 1 down, 2 left, 3 right
; and B is what room it leads to relative to the current one:
; 	0 = -4
; 	1 = -3
; 	2 = -2
; 	3 = -1
; 	4 = 1
; 	5 = 2
; 	6 = 3
; 	7 = 4
; and finally C is the height difference between the rooms / 64
; 	0 = -3
; 	1 = -2
; 	2 = -1
; 	3 = 0
; 	4 = 1
; 	5 = 2
; 	6 = 3

Levels:

LVL_1:
	LEVEL_HEADER LVL0, 3, 4, 12
        EXIT 2, 4, 4
        EXIT 3, 5, 3
        
        LEVEL_DATA
        BLK 1, 1, 15, 3
        BLK 1, 48, 15, 1
        BLK 29, 40, 2, 6
        BLK 15, 44, 15, 2
        FIL 0, 3
        HOK 23, 47, 0
        BLK 1, 54, 13, 2
        ;BLK 24, 37, 4, 4
        ;BLK 10, 40, 15, 1
        ;FIL 0, 3

LVL0:
	LEVEL_HEADER LVL1, 0, 2, 5
        EXIT 3, 3, 2
        
        LEVEL_DATA
        BLK 30, 1, 1, 15
        BLK 3, 13, 15, 2
        HOK 10, 3, 0
        HOK 24, 6, 0
        
        BLK 6, 26, 4, 4
        BLK 20, 26, 8, 4
        BLK 9, 29, 13, 1
        FIL 0, 3
        FIL 1, 3
        SPK 11, 28, 0, 7
        HOK 15, 19, 0
        
	BLK 9, 39, 15, 5
        BLK 2, 43, 8, 1
        SPK 3, 42, 0, 4
        HOK 9, 32, 0

                
        BLK 3, 53, 5, 4
        BLK 24, 53, 4, 4
        
        HOK 15, 47, 0

LVL1:
	LEVEL_HEADER LVL2, 3, 6, 5
        EXIT 2, 2, 3
        
        LEVEL_DATA
        BLK 0, 40, 2, 6
        BLK 1, 44, 4, 2
        FIL 0, 3
        
        BLK 13, 53, 15, 5
        BLK 3, 56, 15, 2
        FIL 0, 0
        
        BLK 17, 49, 5, 1
        BLK 10, 45, 9, 1
        
        
        ;BLK 7, 40, 6, 1
        ;BLK 2, 42, 1, 1
        ;BLK 20, 40, 8, 1
        
        BLK 27, 36, 1, 1
        BLK 27, 32, 1, 1
        BLK 27, 28, 1, 1
        
        BLK 7, 26, 15, 1
        BLK 3, 26, 6, 1
        FIL 0, 4
        


LVL2:
	LEVEL_HEADER LVL3, 3, 5, 4
        
        LEVEL_DATA
        BLK 3, 56, 3, 2
        
        BLK 27, 56, 1, 2
	BLK 25, 52, 1, 1
        HOK 11, 47, 0
        HOK 20, 47, 0
        BLK 27, 48, 1, 1
        
        BLK 3, 46, 3, 1
        HOK 5, 39, 0

LVL3:
	LEVEL_HEADER LVL4, 0, 5, 5
        
        LEVEL_DATA
        BLK 1, 28, 15, 1
        BLK 14, 28, 15, 1
        FIL 0, 4
        BLK 29, 14, 2, 15
        BLK 27, 23, 3, 1
        FIL 0, 0
        BLK 11, 25, 2, 1
        BLK 15, 19, 8, 1
        SPK 14, 27, 0, 10
        HOK 19, 17, 0
	BLK 15, 14, 3, 1
	BLK 16, 10, 1, 6
        FIL 0, 0
        BLK 1, 10, 7, 1

LVL4:
	.byte 0

Stages:
	