	; Block 3 bytes
        ; Object 2 Bytes
        ; Filler 1 Byte
        
        ; Level 1
        LEVEL_HEADER 29, 0, 3, 4
        OBJ 6, 13, 1

        BLK 14, 5, 6, 2
        BLK 15, 1, 2, 5
        FIL 0, 0, 0, 0, 0, 0
        BLK 16, 6, 4, 3
        FIL 0, 1, 0, 1, 0, 0
        
        BLK 19, 8, 2, 11
	FIL 0, 0, 0, 0, 0, 0
        
        OBJ 22, 23, 1
        BLK 28, 15, 1, 5
        
        BLK 14, 20, 4, 3
	BLK 17, 21, 1, 4
        FIL 0, 0, 0, 1, 0, 0
        
        ; Level 2
        LEVEL_HEADER 7, 0, 4, 11
        BLK 17, 10, 3, 2
        BLK 19, 11, 2, 14
        FIL 0, 0, 0, 0, 0, 0
        
        ; Level 3
        LEVEL_HEADER 6,1, 6, 14
        BLK 21, 14, 2, 2
        BLK 23, 16, 2, 1
        
        ; Level 4
        LEVEL_HEADER 6, 1, 6, 14
        BLK 15, 3, 2, 1
        BLK 15, 40, 2, 1
        
        ; Level 5
        LEVEL_HEADER 6, 2, 6, 14
        BLK 28, 22, 2, 2
        BLK 30, 24, 2, 2
