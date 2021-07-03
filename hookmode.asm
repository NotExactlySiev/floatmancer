HookMode: subroutine
	dec jtimer
        bne .ngrip
        ldx hookidx
        lda #$24
        sta $210,x
        
.ngrip

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
        
        rol func7
        rol func6
        rol func7
        rol func6
        
        
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

	lda func0
        sta py0
        lda func1
        sta px0

	

        rts


Release: subroutine
	sec
        lda px1
        sbc px1+BACKUP_OFFSET
        sta vx1
        lda px0
        sbc px0+BACKUP_OFFSET
        sta vx0
        
        sec
        lda py1
        sbc py1+BACKUP_OFFSET
        sta vy1
        lda py0
        sbc py0+BACKUP_OFFSET
        sta vy0
                
        lda #0
        sta ax0
        sta ax1
        sta ax2
        
        lda #$7f
        and flags
        sta flags
        
        ldx hookidx
        lda #$23
        sta $210,x
        
        rts

; finds the closest hook to the player that is also in range, and loads its position and index
; if none are found puts -1
FindCloseHook: subroutine
	ldx hookidx
        lda #$30
        sta $210,x
	

	lda #$ff
        sta radius
        ldx #1		; [] [x] [] [] | [] ...
.nexthook        
	lda $210,x
	beq .out
        
        cmp #$30
        beq .ishook
        inx
        inx
        inx
        inx		; ... | [] [] [] [] | [] [x] ...
        jmp .nexthook
        
.ishook
	dex		; y at y pos, x at x pos of the hook
        txa
        tay
        inx
        inx
        inx		; .. | [y] [] [] [x] | ...
        
        sec
        lda py0
        sbc $210,y
	sec
        sbc #4
        sta func0
     
        sec
        lda px0
        sbc $210,x
        sec
        sbc #4
        sta func1
	
        tya
        pha
        
        jsr CalcRadius
        
        pla
        tay
        
        lda func6
        and #$fe
        cmp radius
        bcc .isclose
        inx
        inx		; ... | [y] [] [] [] | [] [x] ...
        bcs .nexthook
.isclose
        sta radius	; still .. | [y] [] [] [x] | ...
        lda $210,y
        clc
        adc #4
        sta hookpy
        lda $210,x
        clc
        adc #4
        sta hookpx
        
        dex		
        dex
        stx hookidx 	; .. | [y] [x] [] [] | ...
        inx
        inx
        
        inx		; ... | [y] [] [] [] | [] [x] ...
        inx
        
        jmp .nexthook
        
.out
	lda radius
        cmp #HOOK_RANGE
        bcc .close
        lda #$ff
        sta hookidx
.close  

	ldx hookidx
        lda #$31
        sta $210,x

	rts
        
        


Attach: subroutine	; 0-1 distances, t0-t1 current hook, t2 closest distance
        lda px0+BACKUP_OFFSET	; attaching. calculate angle at t and t-dt, subtract to get omega
        sec
        sbc hookpx+BACKUP_OFFSET
        sta relpx0+BACKUP_OFFSET
        sta func0
        
        lda py0+BACKUP_OFFSET
        sec
        sbc hookpy+BACKUP_OFFSET
        sta relpy0+BACKUP_OFFSET
        sta func1
        
        jsr CalcAtan
        lda func6
        sta angle0+BACKUP_OFFSET
        lda func7
        sta angle1+BACKUP_OFFSET
        
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
        sbc angle1+BACKUP_OFFSET
        sta omega1
        lda angle0
        sbc angle0+BACKUP_OFFSET
        sta omega0
        
        ldx hookidx
        lda #$23
        sta $210,x
        
        lda #4
        sta jtimer ; use jump timer for hook gripping animation
        
        lda #$80
        ora flags
        sta flags
        rts