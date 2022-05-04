; this is probably the highes amount of accuarcy we'll ever need
; 10 bit input -> 16 bit output which is then multiplied by an 8 bit
; magnitude, resulting in a 24 bit value, the top 16 bits of which
; will be used.

; sine values for fixed point angles 0x00.00-0x3F.C0, step=0x00.40

	org (SIN_HEAD<<8)

SineHigh:
        ; high byte
	.byte $00,$01,$03,$04,$06,$07,$09,$0a
	.byte $0c,$0e,$0f,$11,$12,$14,$15,$17
	.byte $19,$1a,$1c,$1d,$1f,$20,$22,$24
	.byte $25,$27,$28,$2a,$2b,$2d,$2e,$30
	.byte $31,$33,$35,$36,$38,$39,$3b,$3c
	.byte $3e,$3f,$41,$42,$44,$45,$47,$48
	.byte $4a,$4b,$4d,$4e,$50,$51,$53,$54
	.byte $56,$57,$59,$5a,$5c,$5d,$5f,$60
	.byte $61,$63,$64,$66,$67,$69,$6a,$6c
	.byte $6d,$6e,$70,$71,$73,$74,$75,$77
	.byte $78,$7a,$7b,$7c,$7e,$7f,$80,$82
	.byte $83,$84,$86,$87,$88,$8a,$8b,$8c
	.byte $8e,$8f,$90,$92,$93,$94,$95,$97
	.byte $98,$99,$9b,$9c,$9d,$9e,$9f,$a1
	.byte $a2,$a3,$a4,$a6,$a7,$a8,$a9,$aa
	.byte $ab,$ad,$ae,$af,$b0,$b1,$b2,$b3
	.byte $b5,$b6,$b7,$b8,$b9,$ba,$bb,$bc
	.byte $bd,$be,$bf,$c0,$c1,$c2,$c3,$c4
	.byte $c5,$c6,$c7,$c8,$c9,$ca,$cb,$cc
	.byte $cd,$ce,$cf,$d0,$d1,$d2,$d3,$d3
	.byte $d4,$d5,$d6,$d7,$d8,$d9,$d9,$da
	.byte $db,$dc,$dd,$dd,$de,$df,$e0,$e1
	.byte $e1,$e2,$e3,$e3,$e4,$e5,$e6,$e6
	.byte $e7,$e8,$e8,$e9,$ea,$ea,$eb,$eb
	.byte $ec,$ed,$ed,$ee,$ee,$ef,$ef,$f0
	.byte $f1,$f1,$f2,$f2,$f3,$f3,$f4,$f4
	.byte $f4,$f5,$f5,$f6,$f6,$f7,$f7,$f7
	.byte $f8,$f8,$f9,$f9,$f9,$fa,$fa,$fa
	.byte $fb,$fb,$fb,$fb,$fc,$fc,$fc,$fc
	.byte $fd,$fd,$fd,$fd,$fe,$fe,$fe,$fe
	.byte $fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff
	.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

SineLow:
	; low byte
	.byte $00,$92,$24,$b6,$48,$da,$6c,$fe
	.byte $8f,$21,$b2,$44,$d5,$66,$f6,$87
	.byte $17,$a7,$37,$c7,$56,$e5,$73,$02
	.byte $90,$1d,$aa,$37,$c4,$50,$db,$66
	.byte $f1,$7b,$05,$8e,$17,$9f,$26,$ad
	.byte $33,$b9,$3e,$c3,$47,$ca,$4d,$ce
	.byte $50,$d0,$50,$cf,$4d,$ca,$47,$c3
	.byte $3e,$b8,$31,$aa,$22,$98,$0e,$83
	.byte $f7,$6a,$dc,$4d,$bd,$2d,$9b,$08
	.byte $74,$df,$49,$b1,$19,$80,$e5,$4a
	.byte $ad,$0f,$70,$d0,$2e,$8b,$e7,$42
	.byte $9c,$f4,$4b,$a1,$f5,$48,$9a,$ea
	.byte $39,$87,$d3,$1e,$68,$b0,$f6,$3c
	.byte $7f,$c2,$02,$42,$7f,$bc,$f6,$2f
	.byte $67,$9d,$d2,$05,$36,$66,$94,$c0
	.byte $eb,$14,$3b,$61,$85,$a8,$c8,$e7
	.byte $04,$20,$3a,$52,$68,$7c,$8f,$a0
	.byte $ae,$bc,$c7,$d0,$d8,$de,$e2,$e3
	.byte $e4,$e2,$de,$d8,$d1,$c7,$bb,$ae
	.byte $9f,$8d,$7a,$64,$4d,$33,$18,$fa
	.byte $db,$b9,$95,$70,$48,$1e,$f2,$c4
	.byte $94,$61,$2d,$f6,$be,$83,$46,$06
	.byte $c5,$82,$3c,$f4,$aa,$5e,$0f,$be
	.byte $6b,$16,$bf,$65,$09,$ab,$4b,$e8
	.byte $83,$1c,$b2,$46,$d8,$68,$f5,$80
	.byte $09,$8f,$13,$94,$14,$91,$0b,$84
	.byte $fa,$6d,$de,$4d,$ba,$24,$8b,$f1
	.byte $53,$b4,$12,$6e,$c7,$1e,$73,$c5
	.byte $14,$61,$ac,$f5,$3b,$7e,$bf,$fe
	.byte $3a,$74,$ab,$e0,$13,$43,$70,$9b
	.byte $c4,$ea,$0e,$2f,$4e,$6a,$84,$9c
	.byte $b1,$c3,$d3,$e1,$ec,$f4,$fb,$fe
