HookMode: subroutine
	dec jtimer
        bne .ngrip
        ldx hookidx
        lda #$33
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
        jsr CalcSinAndMultiply
        
        ldx #0
        lda func5
        bpl .pos
    	dex   
.pos
        stx func4        
        
        clc
        lda func6
	adc omega2
        sta omega2
        lda func5
        adc omega1
        sta omega1
        lda func4
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
        
        jsr UpdateAngularPosition

	;; normal hook mode collision
	; hitbox is smaller while swinging
 IF 1
	lda py0
	sec
        sbc py0+BACKUP_OFFSET
	sta vy0
        
        bmi .up
        lda #7
        jsr DownCollision
        bvc .vchecked
.up
	lda #4
        jsr UpCollision
.vchecked
	bne .undo

        sec
        sbc px0+BACKUP_OFFSET
        sta vx0
        
        lda #3
        jsr FrontCollision
        bne .undo
	
        beq .coldone

.undo
	clc
	lda angle0+BACKUP_OFFSET
        sta angle0
        lda angle1+BACKUP_OFFSET
        sta angle1
        lda angle2+BACKUP_OFFSET
        sta angle2
        lda #0
        sta omega0
        sta omega1
        sta omega2
        jsr UpdateAngularPosition
.coldone
 ENDIF       

	

	; trying stretch method where radius can change
        ; for simplicity's sake let's say it doesn't happen when you're on ground
        
        ; wait, the hitbox needs to be a bit bigger for this part
        ldy omega0
        lda angle0
        sec
        sbc #$40
        tax
        bmi .fine
     	dey   
.fine        
        eor $700,y
        bpl .nstretch
.moving
	sty tmp0
        txa
        asl
        bpl .right
        lda flags
        ora #$10
        sta flags
        bne .check
.right 
        lda flags
        and #$ef
        sta flags

.check
        lda #4
        jsr FrontCollision
        beq .nstretch
        
        lda angle0
        asl
        eor tmp0
        bmi .short
        inc radius
        bne .done
        
.short
	dec radius
        
.nstretch

.done


        rts

UpdateAngularPosition: subroutine
	lda radius
        sta func2
        
        lda angle0
        sta func0
        lda angle1
        sta func1
        
        jsr CalcSinAndMultiply
        
        lda func5
        ;ta relpy0
        clc
        adc hookpy
        sta py0
        lda func6
        sta py1
        
        lda angle0
        clc
        adc #$40
        sta func0
        lda angle1
        sta func1
        
	jsr CalcSinAndMultiply
        
        lda func5
        ;sta relpx0
        clc
        adc hookpx
        sta px0
        lda func6
        sta px1
        
        rts


Release: subroutine
	sec
        lda px1
        sbc px1+BACKUP_OFFSET
        sta vx1
        lda px0
        sbc px0+BACKUP_OFFSET
        sta vx0
        
 IF ENABLE_UNFLING
        lda vx0
        cmp #$80
        ror vx0
        ror vx1
        ror vx2
        
        lda vx0
        cmp #$80
        ror
        sta func0
        lda vx1
        ror
        sta func1
        lda vx2
        ror
        
        clc
        adc vx2
        sta vx2
        lda func1
        adc vx1
        sta vx1
        lda func0
        adc vx0
        sta vx0
        
 ENDIF
 
 
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

 IF ENABLE_FLING ; TODO: this is mainly incomplete
	; TODO: only give extra velocity if omega is above some threshold
        lda omega0
        ldx omega1
        jsr CalcAbs
        cmp #1
        bcc .nextra
        bne .extra
        cpx #$80
        bcc .nextra
        
.nextra
	jmp .extradone
.extra

	; vertical extra velocity is easy, just calculate and subtract
	lda angle0
        and #$1F
        sec
        sbc #$40
        sta func0
        lda angle1
        sta func1
        lda #FLING_FORCE_V
        sta func2
        jsr CalcSinAndMultiply

	lda #0
        sec
        ror func6
        ror func7
        ror


	clc
        adc vy2
        sta vy2
        lda vy1
        adc func7
        sta vy1
        lda vy0
        adc func6
        sta vy0
        

	; horizontal depends on direction
	; cos(angle-90) = sin(180-angle)
        
        sec
        lda angle0
        sta func0
        lda angle1
        sta func1
        lda #FLING_FORCE_H
        sta func2
        jsr CalcSinAndMultiply

	; calculate the horizontal direction of extra velocity
	lda angle0
        asl
        eor angle0
        and #$80
        bne .left
	; then divide the result by 4 and add
.right
	
      	lda #0
	lsr func6
        ror func7
        ror
        lsr func6
        ror func7
        ror 
        lsr func6
        ror func7
        ror 
        lsr func6
        ror func7
        ror 
        lsr func6
        ror func7
        ror 
        
        clc
        adc vx2
        sta vx2
        lda vx1
        adc func7
        sta vx1
        lda vx0
        adc func6
        sta vx0
        jmp .extradone  
        
.left
	sec
        lda vx2
        sbc func7
        sta vx2
        lda vx1
        sbc func6
        sta vx1    
        lda vx0
        sbc #0
        sta vx0

.extradone

 ENDIF ; end of fling
 

        lda #$7f
        and flags
        sta flags
        
        ldx hookidx
        lda #$23
        sta $210,x
        
        rts

; finds the closest hook to the player that is also in range, and loads its position and index
; if none are found puts -1
; wait... why is this function looking in the oam for hooks? that seems very dumb!
; there will be weird shit happening with offscreen hooks. TODO: fix this
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
.skipone
        inx
        inx
        inx
        inx		; ... | [] [] [] [] | [] [x] ...
        jmp .nexthook
        
.ishook
	dex
        lda $210,x
        cmp #$FE
        bne .onscreen
        inx
        bne .skipone
.onscreen
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
        sta func0
        
        lda py0+BACKUP_OFFSET
        sec
        sbc hookpy+BACKUP_OFFSET
        sta func1
        
        jsr CalcAtan
        lda func6
        sta angle0+BACKUP_OFFSET
        lda func7
        sta angle1+BACKUP_OFFSET
        
	lda px0
        sec
        sbc hookpx
        sta func0
        
        lda py0
        sec
        sbc hookpy
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
        lda #$32
        sta $210,x
        
        lda #4
        sta jtimer ; use jump timer for hook gripping animation
        
        lda #$80
        ora flags
        sta flags
        rts