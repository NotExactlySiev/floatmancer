	; Block 3 bytes
        ; Object 2 Bytes
        ; Filler 1 Byte
        
        ; Level 1
        LEVEL_HEADER 9, 0, 5, 8
        BLK 13, 6, 6, 6
        BLK 17, 9, 6, 6
        .byte %11000000
        ;FIL 1, 1, 1, 0, 0, 0
        OBJ 10, 15, 1
        
        ; Level 2
        LEVEL_HEADER 6, 1, 6, 14
        BLK 17, 10, 2, 1
        BLK 19, 12, 2, 1
        
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
