HookMode: subroutine
	dec jtimer
        bne .ngrip
        ldx hookidx
        lda #$33
        sta $210,x
        
.ngrip

	lda #HOOK_SWING
        sta func2
        lda #0
        sta func3
        
        lda angle0
        clc
        adc #$40
        sta func0
        lda angle1
	sta func1
        jsr CalcSinAndMultiply
        
        ldx #0
        lda func4
        bpl .pos
    	dex
.pos
        stx func7
        
        clc
        lda func4
        adc omega1
        sta omega1
        lda func7
        adc omega0
        sta omega0

	; adjusting rotation speed

        clc
;        lda angle2
;        adc omega2
;        sta angle2
        lda angle1
        adc omega1
        sta angle1
        lda angle0
        adc omega0
        sta angle0
        
        jsr UpdateAngularPosition

	; drawing some cool shit while hooked
 IF LINE
        lda hookpx
        sta func0
        lda hookpy
        sta func1
        
        lda #0
        sta tmp3
        sta func6
        
        lda py0+BACKUP_OFFSET
        sec
        sbc hookpy
        sta tmp1
        tay
        
        lda px0+BACKUP_OFFSET
        sec
        sbc hookpx
        sta tmp0
        
        cmp tmp1
        bcs .nswap ; x >= y
	
        sty tmp0
        sta tmp1
        
        lda #$80
        sta tmp3 ; remember that we swapped
        
.nswap		; x < y
        
        lda tmp0	; divide the bigger one by 8
        lsr
        lsr
        lsr
        tax
        inx
        stx func5	; count
        
        lda tmp1	; divide the smaller one by count
        ldy #-1
.divide
	iny
        sec
        sbc func5
        bpl .divide
        
        sty tmp2	; offset
        tya
        tay
        

        bit tmp3
        bpl .nsw
	lda #$F
        sec
        sbc $700,y
.nsw

	ora #$f0
        sta func4
        
        lda #8
        tax
        tay
        lda tmp2
        
        bit tmp3
        bpl .nsw2
        tax
        tya
.nsw2
	
        stx func2
        sta func3

        ; 0 x0
        ; 1 y0
        ; 2 x step
        ; 3 y step
        ; 4 tile
        ; 5 count
        ; 6 attr
        
        ldx func5
        dex
	ldy #$ff
.loop        
        lda func0
        sta $200,y
	dey
        
        lda func6
        sta $200,y
        dey
        
        lda func4
        ora #$f0
        sta $200,y
        dey
        
        lda func1
        sta $200,y
        dey
        
        lda func0
        clc
        adc func2
        sta func0
        
        lda func1
        clc
        adc func3
        sta func1
        
        dex
	bne .loop
        
 ENDIF
 
 IF 0
        ldx hookidx
        lda $200+$F,x
        clc
        adc $200
        ror
        sta $2FC
        
        lda $203+$F,x
        clc
        adc $203
        ror
        sta $2FF
        
        lda angle0
        clc
        adc #%00001000
	and #%01110000
        lsr
        lsr
        lsr
        lsr
        ora #$D0
        sta $2FD
        lda #2
        sta $2FE
 ENDIF
	;; TODO: hook mode collision needs a serious rework
        ;; 	 we need some sort of momentum that converts into deltaradius
        ;;	 and is somehow related to downward velocity
        
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
        beq .nground
        jsr Release
        rts
.nground
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
;        lda angle2+BACKUP_OFFSET
;        sta angle2
        lda #0
        sta omega0
        sta omega1
;        sta omega2
        jsr UpdateAngularPosition
.coldone
 ENDIF       

	
 IF 0
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
        inc radius0
        bne .done
        
.short
	dec radius0
        
.nstretch

.done
 ENDIF

        rts

UpdateAngularPosition: subroutine
	lda radius0
        sta func2
        lda radius1
        sta func3
        
        lda angle0
        sta func0
        lda angle1
        sta func1
        
        jsr CalcSinAndMultiply
        
        lda func4
        clc
        adc hookpy
        sta py0
        lda func5
        sta py1
        
        lda angle0
        clc
        adc #$40
        sta func0
        lda angle1
        sta func1
        
	jsr CalcSinAndMultiply
        
        lda func4
        clc
        adc hookpx
        sta px0
        lda func5
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
        lda #FLING_FORCE_L
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
        sta radius0
        
        bit flags
        bvs .nground
        rts
.nground
        
        ldx #1		; [] [x] [] [] | [] ...
.nexthook        
	lda $210,x
	bne .continue
        jmp .out
.continue
        
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
        ; Abs		; do we need to get abs here? it happens in arctan anyway
        bpl .ypos
        
        sec
        lda #0
        sbc py1
        sta func1
        lda #0
        sbc func0
.ypos
        cmp #HOOK_RANGE
        bcs .nclose
        sta func0
     
        lda px1
        sta func3
        
        sec
        lda px0
        sbc $210,x
        sec
        sbc #4
        sta func2
        ; Abs
        bpl .xpos
        
        sec
        lda #0
        sbc px1
        sta func3
        lda #0
        sbc func2
.xpos
        cmp #HOOK_RANGE
        bcs .nclose
        sta func2
	
        tya
        pha
        
        jsr CalcRadius
        
        pla
        tay
        
        lda func4
        cmp radius0 ; TODO: this comparison is 8 bit only
        bcc .isclose
.nclose
        inx
        inx		; ... | [y] [] [] [] | [] [x] ...
        bcs .nexthook
.isclose
        sta radius0	; still .. | [y] [] [] [x] | ...
        lda func5
        sta radius1
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
	lda radius0
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
        lda px1+BACKUP_OFFSET
        sta func1
        
        lda py0+BACKUP_OFFSET
        sec
        sbc hookpy+BACKUP_OFFSET
        sta func2
        lda py1+BACKUP_OFFSET
        sta func3
        
        jsr CalcAtan
        lda func6
        sta angle0+BACKUP_OFFSET
        lda func7
        sta angle1+BACKUP_OFFSET
        
	lda px0
        sec
        sbc hookpx
        sta func0
        lda px1
        sta func1
        
        lda py0
        sec
        sbc hookpy
        sta func2
        lda py1
        sta func3
        	
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