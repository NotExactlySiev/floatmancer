HookMode: subroutine
	lda #HOOK_SWING
        sta func2
        
        lda angle0
        clc
        adc #$40
        sta func0
        lda angle1
	sta func1
        jsr CalcSin
        
        ldx #0
        lda func6
        bpl .pos
    	ldx #$ff    
.pos
        stx func5
        
        clc
        lda func7
	adc omega2
        sta omega2
        lda func6
        adc omega1
        sta omega1
        lda func5
        adc omega0
        sta omega0

	; adjusting rotation speed

        clc
        lda angle2
        adc omega2
        sta angle2
        lda angle1
        adc omega1
        sta angle1
        lda angle0
        adc omega0
        sta angle0



	; positioning
        
        lda radius
        sta func2
        
        lda angle0
        sta func0
        lda angle1
        sta func1
        
        jsr CalcSin
        
        lda func6
        sta relpy0
        
        lda angle0
        clc
        adc #$40
        sta func0
        lda angle1
        sta func1
        
	jsr CalcSin
        
        lda func6
        sta relpx0

        lda relpy0
        clc
        adc hookpy
        sta func0	; check for collision

	lda relpx0
        clc
        adc hookpx
        sta func1

	jsr CheckCollision
        lda func2
        bne .undo
        lda func0
        sta py0
        lda func1
        sta px0
        rts
.undo   
	lda relpy0+$20
        sta relpy0
        lda relpx0+$20
        sta relpx0
        lda angle0+$20
        sta angle0
        lda angle1+$20
        sta angle1
        lda angle2+$20
        sta angle2
        lda #0
        sta omega0
        sta omega1
        sta omega2
        rts


Release: subroutine
	sec
        lda px2
        sbc px2+$20
        sta vx2
        lda px1
        sbc px1+$20
        sta vx1
        lda px0
        sbc px0+$20
        sta vx0
        
        sec
        lda py2
        sbc py2+$20
        sta vy2
        lda py1
        sbc py1+$20
        sta vy1
        lda py0
        sbc py0+$20
        sta vy0
        
        
        lda #0
        sta ax0
        sta ax1
        sta ax2
        
        lda #$7f
        and Flags
        sta Flags
        
        rts
        
Attach: subroutine	; 0-1 distances, 7 closest,  t0-t1 current hook
	lda #$ff
        sta tmp2
        ldx #1
.nexthook        
	lda $210,x
	beq .out
        
        cmp #$21
        beq .ishook
        inx
        inx
        inx
        inx
        jmp .nexthook
        
.ishook
        
        dex
        lda $210,x
        clc
        adc #4
        sta tmp0
        inx
        inx
        inx
        lda $210,x
        clc
        adc #4
        sta tmp1
        inx
        inx
        
        lda py0
        sec
        sbc tmp0
        sta func0       
        lda px0
        sec
        sbc tmp1
        sta func1
        
        jsr CalcRadius
        
        lda func6
        cmp tmp2
        bcs .nexthook
        sta tmp2
    	lda tmp0
        sta hookpy
        lda tmp1
        sta hookpx
	jmp .nexthook
.out
	lda tmp2
        sta radius

        and #$fe	; check if close enough
        clc
        cmp #HOOK_RANGE
        bcc .close
        rts
.close  

        lda px0+$20
        sec
        sbc hookpx
        sta relpx0+$20
        sta func0
        
        lda py0+$20
        sec
        sbc hookpy
        sta relpy0+$20
        sta func1
        
        jsr CalcAtan
        lda func6
        sta angle0+$20
        lda func7
        sta angle1+$20
        

	lda px0
        sec
        sbc hookpx
        sta relpx0
        sta func0
        
        lda py0
        sec
        sbc hookpy
        sta relpy0
        sta func1
        
        
	
	jsr CalcAtan
	lda func6
        sta angle0  
        lda func7
        sta angle1
        
	sec
        sbc angle1+$20
        sta omega1
        lda angle0
        sbc angle0+$20
        sta omega0
        
        lda #$80
        ora Flags
        sta Flags
        rts