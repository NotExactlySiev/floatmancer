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
	lda relpy0+BACKUP_OFFSET
        sta relpy0
        lda relpx0+BACKUP_OFFSET
        sta relpx0
        lda angle0+BACKUP_OFFSET
        sta angle0
        lda angle1+BACKUP_OFFSET
        sta angle1
        lda #0
        sta omega0
        sta omega1
        sta omega2
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
        ldx hookidx
        sta $210,x
        
        lda #$7f
        and flags
        sta flags
        
        rts
        
Attach: subroutine	; 0-1 distances, t0-t1 current hook, t2 closest distance
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
        ; TODO: maybe we don't need to load all this shit?
        dex
        lda $210,x	; load hook position and index
        clc
        adc #4
        sta tmp0
        inx
        inx
        stx tmp3	; attributes byte
        inx
        lda $210,x
        clc
        adc #4
        sta tmp1
        inx
        inx
        
        lda py0		; calculate distance from hook
        sec
        sbc tmp0
        sta func0       
        lda px0
        sec
        sbc tmp1
        sta func1
        
        jsr CalcRadius
        
        lda func6	; compare with the closest hook. replace if closer
        cmp tmp2
        bcs .nexthook
        sta tmp2
    	lda tmp0
        sta hookpy
        lda tmp1
        sta hookpx
        lda tmp3
        sta hookidx
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

        lda px0+BACKUP_OFFSET	; attaching. calculate angle at t and t-dt, subtract to get omega
        sec
        sbc hookpx
        sta relpx0+BACKUP_OFFSET
        sta func0
        
        lda py0+BACKUP_OFFSET
        sec
        sbc hookpy
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
        lda #2
        sta $210,x
        
        lda #$80
        ora flags
        sta flags
        rts