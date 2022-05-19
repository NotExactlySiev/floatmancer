SEQ_FADEOUT	= 0
SEQ_FADEIN	= 1
SEQ_JUMPLVL	= 2
SEQ_DEATH	= 3
SEQ_PAUSE	= 4
SEQ_INITLVL	= 5
SEQ_ROOMTRAN	= 6

CallTableHi:
	.byte >(ClearLevel-1), >(SetDarkness-1), >(InitPlay-1), >(UpdateSprites-1)
        .byte >(ClearState-1), >(ClearDMA-1), >(LoadLevel-1), >(RenderLevel-1)
        .byte >(DisablePPU-1), >(EnablePPU-1), 0, 0
        .byte 0, 0, 0, 0

CallTableLo:
	.byte <(ClearLevel-1), <(SetDarkness-1), <(InitPlay-1), <(UpdateSprites-1)
        .byte <(ClearState-1), <(ClearDMA-1), <(LoadLevel-1), <(RenderLevel-1)
        .byte <(DisablePPU-1), <(EnablePPU-1), 0, 0	; DO NOT wait after disabling ppu
        .byte 0, 0, 0, 0

SequencesTable:
	.byte SEQ0_Data-Sequences
        .byte SEQ1_Data-Sequences
        .byte SEQ2_Data-Sequences
        .byte SEQ3_Data-Sequences
        .byte SEQ4_Data-Sequences
        .byte SEQ5_Data-Sequences
	.byte SEQ6_Data-Sequences
Sequences:
SEQ0_Data:
	.byte $61, $13, $21, $02, $82, $21, $02, $83, $21, $02, $84, $21, $00
SEQ1_Data:
	.byte $63, $13, $21, $02, $82, $21, $02, $81, $21, $02, $80, $21, $00
SEQ2_Data:
	.byte $40, $45, $41, $00
SEQ3_Data:
	; i stopped changing the state and it stopped randomly scrolling at death
	; .byte $60, state
        ; TODO: death animation
	.byte $42, $00
SEQ4_Data:
	.byte $60, $95, $02, $67, $3C, $02, $88, $01, $60, $26, $60, $27, $00
SEQ5_Data: ; no fadeout
	.byte $28, $20, $25, $26, $27, $22, $01, $29, $00
SEQ6_Data:
	.byte $01, $45, $0