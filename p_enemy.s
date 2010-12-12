;
; File generated by cc65 v 2.13.2
;
	.fopt		compiler,"cc65 v 2.13.2"
	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.debuginfo	off
	.importzp	sp, sreg, regsave, regbank, tmp1, ptr1, ptr2
	.macpack	longbranch
	.import		_abs
	.export		_player
	.import		_P_Random
	.export		_P_ApproxDistance
	.export		_opposite
	.export		_diags
	.export		_P_CheckSight
	.export		_P_LookForPlayers
	.export		_S_StartSound
	.export		_P_SetMobjState
	.export		_P_DamageMobj
	.export		_P_SpawnMissile
	.export		_P_RadiusAttack
	.export		_P_CheckMeleeRange
	.export		_P_CheckMissileRange
	.export		_xspeed
	.export		_yspeed
	.import		_P_TryMove
	.export		_P_Move
	.export		_P_TryWalk
	.export		_P_NewChaseDir
	.export		_A_Look
	.export		_A_Chase
	.export		_R_PointToAngle
	.export		_A_FaceTarget
	.export		_A_PosAttack
	.export		_A_TroopAttack
	.export		_A_Fall
	.export		_A_Explode

.segment	"DATA"

_opposite:
	.word	$0004
	.word	$0005
	.word	$0006
	.word	$0007
	.word	$0000
	.word	$0001
	.word	$0002
	.word	$0003
	.word	$0008
_diags:
	.word	$0003
	.word	$0001
	.word	$0005
	.word	$0007
_xspeed:
	.word	$0100
	.word	$00B5
	.word	$0000
	.word	$FF4B
	.word	$FF00
	.word	$FF4B
	.word	$0000
	.word	$00B5
_yspeed:
	.word	$0000
	.word	$00B5
	.word	$0100
	.word	$00B5
	.word	$0000
	.word	$FF4B
	.word	$FF00
	.word	$FF4B

.segment	"BSS"

_player:
	.res	2,$00

; ---------------------------------------------------------------
; int __near__ P_ApproxDistance (int, int)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_ApproxDistance: near

.segment	"CODE"

	ldy     #$03
	jsr     ldaxysp
	jsr     _abs
	ldy     #$02
	jsr     staxysp
	ldy     #$01
	jsr     ldaxysp
	jsr     _abs
	ldy     #$00
	jsr     staxysp
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     tosltax
	jeq     L0009
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     tosaddax
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     asrax1
	jsr     tossubax
	jmp     L0002
L0009:	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     tosaddax
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     asrax1
	jsr     tossubax
	jmp     L0002
L0002:	jsr     incsp4
	rts

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ P_CheckSight (__near__ struct mobj_T*, __near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_CheckSight: near

.segment	"CODE"

	ldy     #$03
	jsr     ldaxysp
	ldy     #$06
	jsr     ldauidx
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$06
	jsr     ldauidx
	jsr     toseqax
	jeq     L001D
	ldx     #$00
	lda     #$01
	jmp     L001C
L001D:	ldy     #$03
	jsr     ldaxysp
	ldy     #$08
	jsr     ldauidx
	ldx     #$00
	and     #$20
	stx     tmp1
	ora     tmp1
	jeq     L0020
	ldx     #$00
	lda     #$01
	jmp     L001C
L0020:	ldx     #$00
	lda     #$00
	jmp     L001C
L001C:	jsr     incsp4
	rts

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ P_LookForPlayers (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_LookForPlayers: near

.segment	"CODE"

	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	lda     _player
	ldx     _player+1
	jsr     pushax
	jsr     _P_CheckSight
	tax
	jeq     L0025
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	lda     _player
	ldx     _player+1
	ldy     #$0E
	jsr     staxspidx
	ldx     #$00
	lda     #$01
	jmp     L0024
L0025:	ldx     #$00
	lda     #$00
	jmp     L0024
L0024:	jsr     incsp2
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ S_StartSound (__near__ struct mobj_T*, unsigned char)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_S_StartSound: near

.segment	"CODE"

	jsr     incsp3
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ P_SetMobjState (__near__ struct mobj_T*, unsigned char)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_SetMobjState: near

.segment	"CODE"

	jsr     incsp3
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ P_DamageMobj (__near__ struct mobj_T*, __near__ struct mobj_T*, __near__ struct mobj_T*, int)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_DamageMobj: near

.segment	"CODE"

	ldy     #$07
	jsr     ldaxysp
	jsr     pushax
	ldy     #$0B
	jsr     ldaidx
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     tossubax
	ldy     #$0B
	jsr     staspidx
	ldy     #$07
	jsr     ldaxysp
	ldy     #$0B
	jsr     ldaidx
	sec
	sbc     #$01
	bvc     L0034
	eor     #$80
L0034:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jeq     L0032
	ldy     #$07
	jsr     ldaxysp
	jsr     pushax
	ldy     #$09
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$0D
	jsr     ldauidx
	jsr     pusha
	jsr     _P_SetMobjState
	jmp     L0038
L0032:	ldy     #$07
	jsr     ldaxysp
	jsr     pushax
	ldy     #$08
	jsr     ldauidx
	ora     #$02
	ldy     #$08
	jsr     staspidx
L0038:	jsr     incsp8
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ P_SpawnMissile (__near__ struct mobj_T*, __near__ struct mobj_T*, unsigned char)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_SpawnMissile: near

.segment	"CODE"

	ldy     #$02
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     pushax
	ldy     #$06
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	ldy     #$04
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     pushax
	ldy     #$08
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	ldy     #$09
	jsr     addysp
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ P_RadiusAttack (__near__ struct mobj_T*, __near__ struct mobj_T*, int)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_RadiusAttack: near

.segment	"CODE"

	jsr     incsp6
	rts

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ P_CheckMeleeRange (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_CheckMeleeRange: near

.segment	"CODE"

	jsr     decsp4
	ldy     #$05
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     bnegax
	jeq     L0040
	ldx     #$00
	lda     #$00
	jmp     L003F
L0040:	ldy     #$05
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$02
	jsr     staxysp
	ldy     #$03
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     pushax
	ldy     #$09
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	jsr     _P_ApproxDistance
	ldy     #$00
	jsr     staxysp
	ldy     #$01
	jsr     ldaxysp
	cmp     #$00
	txa
	sbc     #$40
	bvs     L004C
	eor     #$80
L004C:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jeq     L0049
	ldx     #$00
	lda     #$00
	jmp     L003F
L0049:	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     pushax
	jsr     _P_CheckSight
	jsr     bnega
	jeq     L004E
	ldx     #$00
	lda     #$00
	jmp     L003F
L004E:	ldx     #$00
	lda     #$01
	jmp     L003F
L003F:	jsr     incsp6
	rts

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ P_CheckMissileRange (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_CheckMissileRange: near

.segment	"CODE"

	jsr     decsp2
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     pushax
	jsr     _P_CheckSight
	jsr     bnega
	jeq     L0055
	ldx     #$00
	lda     #$00
	jmp     L0054
L0055:	ldy     #$03
	jsr     ldaxysp
	ldy     #$08
	jsr     ldauidx
	ldx     #$00
	and     #$01
	stx     tmp1
	ora     tmp1
	jeq     L005A
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldy     #$08
	jsr     ldauidx
	and     #$FE
	ldy     #$08
	jsr     staspidx
	ldx     #$00
	lda     #$01
	jmp     L0054
L005A:	ldy     #$03
	jsr     ldaxysp
	ldy     #$09
	jsr     ldauidx
	jeq     L005F
	ldx     #$00
	lda     #$00
	jmp     L0054
L005F:	ldy     #$03
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$01
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$03
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	jsr     _P_ApproxDistance
	jsr     pushax
	ldx     #$40
	lda     #$00
	jsr     tossubax
	ldy     #$00
	jsr     staxysp
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$0B
	jsr     ldauidx
	jsr     bnega
	jeq     L0066
	ldx     #$80
	lda     #$00
	ldy     #$00
	jsr     subeqysp
L0066:	ldy     #$01
	jsr     ldaxysp
	ldy     #$00
	jsr     staxysp
	ldy     #$01
	jsr     ldaxysp
	cmp     #$C9
	txa
	sbc     #$00
	bvs     L006E
	eor     #$80
L006E:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jeq     L006C
	ldx     #$00
	lda     #$C8
	ldy     #$00
	jsr     staxysp
L006C:	jsr     _P_Random
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     tosultax
	jeq     L0071
	ldx     #$00
	lda     #$00
	jmp     L0054
L0071:	ldx     #$00
	lda     #$01
	jmp     L0054
L0054:	jsr     incsp4
	rts

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ P_Move (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_Move: near

.segment	"CODE"

	jsr     decsp4
	ldy     #$05
	jsr     ldaxysp
	ldy     #$07
	jsr     ldauidx
	cmp     #$08
	jsr     booleq
	jeq     L0088
	ldx     #$00
	lda     #$00
	jmp     L0087
L0088:	ldy     #$05
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$00
	jsr     ldauidx
	jsr     pushax
	ldy     #$09
	jsr     ldaxysp
	ldy     #$07
	jsr     ldauidx
	jsr     aslax1
	clc
	adc     #<(_xspeed)
	tay
	txa
	adc     #>(_xspeed)
	tax
	tya
	ldy     #$01
	jsr     ldaxidx
	jsr     tosumulax
	jsr     tosaddax
	ldy     #$02
	jsr     staxysp
	ldy     #$05
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$00
	jsr     ldauidx
	jsr     pushax
	ldy     #$09
	jsr     ldaxysp
	ldy     #$07
	jsr     ldauidx
	jsr     aslax1
	clc
	adc     #<(_yspeed)
	tay
	txa
	adc     #>(_yspeed)
	tax
	tya
	ldy     #$01
	jsr     ldaxidx
	jsr     tosumulax
	jsr     tosaddax
	ldy     #$00
	jsr     staxysp
	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_TryMove
	jmp     L0087
L0087:	jsr     incsp6
	rts

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ P_TryWalk (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_TryWalk: near

.segment	"CODE"

	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_Move
	jsr     bnega
	jeq     L0096
	ldx     #$00
	lda     #$00
	jmp     L0095
L0096:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_Random
	ldx     #$00
	and     #$0F
	ldy     #$0A
	jsr     staspidx
	ldx     #$00
	lda     #$01
	jmp     L0095
L0095:	jsr     incsp2
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ P_NewChaseDir (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_P_NewChaseDir: near

.segment	"CODE"

	ldy     #$10
	jsr     subysp
	ldy     #$11
	jsr     ldaxysp
	ldy     #$07
	jsr     ldauidx
	ldx     #$00
	ldy     #$02
	jsr     staxysp
	ldy     #$03
	jsr     ldaxysp
	jsr     aslax1
	clc
	adc     #<(_opposite)
	tay
	txa
	adc     #>(_opposite)
	tax
	tya
	ldy     #$01
	jsr     ldaxidx
	ldy     #$00
	jsr     staxysp
	ldy     #$11
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$01
	jsr     ldaxidx
	jsr     pushax
	ldy     #$13
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     tossubax
	ldy     #$0E
	jsr     staxysp
	ldy     #$11
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$03
	jsr     ldaxidx
	jsr     pushax
	ldy     #$13
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     tossubax
	ldy     #$0C
	jsr     staxysp
	ldy     #$0F
	jsr     ldaxysp
	cmp     #$01
	txa
	sbc     #$0A
	bvs     L00AA
	eor     #$80
L00AA:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jeq     L00A8
	ldx     #$00
	lda     #$00
	ldy     #$08
	jsr     staxysp
	jmp     L00B5
L00A8:	ldy     #$0F
	jsr     ldaxysp
	cmp     #$00
	txa
	sbc     #$F6
	bvc     L00B1
	eor     #$80
L00B1:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jeq     L00AF
	ldx     #$00
	lda     #$04
	ldy     #$08
	jsr     staxysp
	jmp     L00B5
L00AF:	ldx     #$00
	lda     #$08
	ldy     #$08
	jsr     staxysp
L00B5:	ldy     #$0D
	jsr     ldaxysp
	cmp     #$00
	txa
	sbc     #$F6
	bvc     L00BB
	eor     #$80
L00BB:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jeq     L00B9
	ldx     #$00
	lda     #$06
	ldy     #$0A
	jsr     staxysp
	jmp     L00BF
L00B9:	ldy     #$0D
	jsr     ldaxysp
	cmp     #$01
	txa
	sbc     #$0A
	bvs     L00C2
	eor     #$80
L00C2:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jeq     L00C0
	ldx     #$00
	lda     #$02
	ldy     #$0A
	jsr     staxysp
	jmp     L00BF
L00C0:	ldx     #$00
	lda     #$08
	ldy     #$0A
	jsr     staxysp
L00BF:	ldy     #$09
	jsr     ldaxysp
	cpx     #$00
	bne     L00CD
	cmp     #$08
L00CD:	jsr     boolne
	jeq     L00CE
	ldy     #$0B
	jsr     ldaxysp
	cpx     #$00
	bne     L00D0
	cmp     #$08
L00D0:	jsr     boolne
	jne     L00CB
L00CE:	ldx     #$00
	lda     #$00
	jeq     L00D1
L00CB:	ldx     #$00
	lda     #$01
L00D1:	jeq     L00D9
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	ldy     #$0F
	jsr     ldaxysp
	cpx     #$80
	lda     #$00
	ldx     #$00
	rol     a
	jsr     aslax1
	jsr     pushax
	ldy     #$13
	jsr     ldaxysp
	cmp     #$01
	txa
	sbc     #$00
	bvs     L00D8
	eor     #$80
L00D8:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jsr     tosaddax
	jsr     aslax1
	clc
	adc     #<(_diags)
	tay
	txa
	adc     #>(_diags)
	tax
	tya
	ldy     #$00
	jsr     ldauidx
	ldy     #$07
	jsr     staspidx
	ldy     #$11
	jsr     ldaxysp
	ldy     #$07
	jsr     ldauidx
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     tosneax
	jeq     L00DB
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_TryWalk
	tax
	jne     L00DA
L00DB:	ldx     #$00
	lda     #$00
	jeq     L00DD
L00DA:	ldx     #$00
	lda     #$01
L00DD:	jeq     L00D9
	jmp     L009D
L00D9:	jsr     _P_Random
	cmp     #$C9
	lda     #$00
	ldx     #$00
	rol     a
	jne     L00DF
	ldy     #$0D
	jsr     ldaxysp
	jsr     _abs
	jsr     pushax
	ldy     #$11
	jsr     ldaxysp
	jsr     _abs
	jsr     tosgtax
	jne     L00DF
	ldx     #$00
	lda     #$00
	jeq     L00E2
L00DF:	ldx     #$00
	lda     #$01
L00E2:	jeq     L00DE
	ldy     #$09
	jsr     ldaxysp
	ldy     #$04
	jsr     staxysp
	ldy     #$0B
	jsr     ldaxysp
	ldy     #$08
	jsr     staxysp
	ldy     #$05
	jsr     ldaxysp
	ldy     #$0A
	jsr     staxysp
L00DE:	ldy     #$09
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     toseqax
	jeq     L00ED
	ldx     #$00
	lda     #$08
	ldy     #$08
	jsr     staxysp
L00ED:	ldy     #$0B
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     toseqax
	jeq     L00F3
	ldx     #$00
	lda     #$08
	ldy     #$0A
	jsr     staxysp
L00F3:	ldy     #$09
	jsr     ldaxysp
	cpx     #$00
	bne     L00FC
	cmp     #$08
L00FC:	jsr     boolne
	jeq     L00F9
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	ldy     #$0A
	ldx     #$00
	lda     (sp),y
	ldy     #$07
	jsr     staspidx
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_TryWalk
	tax
	jeq     L00F9
	jmp     L009D
L00F9:	ldy     #$0B
	jsr     ldaxysp
	cpx     #$00
	bne     L0106
	cmp     #$08
L0106:	jsr     boolne
	jeq     L010A
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	ldy     #$0C
	ldx     #$00
	lda     (sp),y
	ldy     #$07
	jsr     staspidx
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_TryWalk
	tax
	jeq     L010A
	jmp     L009D
L010A:	ldy     #$03
	jsr     ldaxysp
	cpx     #$00
	bne     L010F
	cmp     #$08
L010F:	jsr     boolne
	jeq     L0112
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	ldy     #$04
	ldx     #$00
	lda     (sp),y
	ldy     #$07
	jsr     staspidx
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_TryWalk
	tax
	jeq     L0112
	jmp     L009D
L0112:	jsr     _P_Random
	ldx     #$00
	and     #$01
	stx     tmp1
	ora     tmp1
	jeq     L0115
	ldx     #$00
	lda     #$00
	ldy     #$04
	jsr     staxysp
L0117:	ldy     #$05
	jsr     ldaxysp
	cmp     #$08
	txa
	sbc     #$00
	bvc     L011E
	eor     #$80
L011E:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jne     L011A
	jmp     L0118
L011A:	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     tosneax
	jeq     L0119
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	ldy     #$06
	ldx     #$00
	lda     (sp),y
	ldy     #$07
	jsr     staspidx
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_TryWalk
	tax
	jeq     L0119
	jmp     L009D
L0119:	ldy     #$05
	jsr     ldaxysp
	sta     regsave
	stx     regsave+1
	jsr     incax1
	ldy     #$04
	jsr     staxysp
	lda     regsave
	ldx     regsave+1
	jmp     L0117
L0118:	jmp     L0129
L0115:	ldx     #$00
	lda     #$07
	ldy     #$04
	jsr     staxysp
L0128:	ldy     #$05
	jsr     ldaxysp
	cpx     #$FF
	bne     L0130
	cmp     #$FF
L0130:	jsr     boolne
	jne     L012B
	jmp     L0129
L012B:	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     tosneax
	jeq     L012A
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	ldy     #$06
	ldx     #$00
	lda     (sp),y
	ldy     #$07
	jsr     staspidx
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_TryWalk
	tax
	jeq     L012A
	jmp     L009D
L012A:	ldy     #$05
	jsr     ldaxysp
	sta     regsave
	stx     regsave+1
	jsr     decax1
	ldy     #$04
	jsr     staxysp
	lda     regsave
	ldx     regsave+1
	jmp     L0128
L0129:	ldy     #$01
	jsr     ldaxysp
	cpx     #$00
	bne     L013B
	cmp     #$08
L013B:	jsr     boolne
	jeq     L013E
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	ldy     #$02
	ldx     #$00
	lda     (sp),y
	ldy     #$07
	jsr     staspidx
	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_TryWalk
	tax
	jeq     L013E
	jmp     L009D
L013E:	ldy     #$11
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$08
	ldy     #$07
	jsr     staspidx
L009D:	ldy     #$12
	jsr     addysp
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ A_Look (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_A_Look: near

.segment	"CODE"

	ldy     #$01
	jsr     ldaxysp
	ldy     #$08
	jsr     ldauidx
	ldx     #$00
	and     #$20
	stx     tmp1
	ora     tmp1
	jne     L0145
	ldy     #$01
	jsr     ldaxysp
	ldy     #$06
	jsr     ldauidx
	jsr     pushax
	lda     _player
	ldx     _player+1
	ldy     #$06
	jsr     ldauidx
	jsr     toseqax
	jne     L0145
	ldx     #$00
	lda     #$00
	jeq     L0147
L0145:	ldx     #$00
	lda     #$01
L0147:	jeq     L0144
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	lda     _player
	ldx     _player+1
	ldy     #$0E
	jsr     staxspidx
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$01
	jsr     ldauidx
	jsr     pusha
	jsr     _S_StartSound
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$09
	jsr     ldauidx
	jsr     pusha
	jsr     _P_SetMobjState
L0144:	jsr     incsp2
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ A_Chase (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_A_Chase: near

.segment	"CODE"

	ldy     #$01
	jsr     ldaxysp
	ldy     #$09
	jsr     ldauidx
	jeq     L0151
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$09
	jsr     ldauidx
	pha
	sec
	sbc     #$01
	ldy     #$09
	jsr     staspidx
	pla
L0151:	ldy     #$01
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     bnegax
	jne     L0155
	ldy     #$01
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$08
	jsr     ldauidx
	ldx     #$00
	and     #$04
	jsr     bnegax
	jne     L0155
	ldx     #$00
	lda     #$00
	jeq     L0157
L0155:	ldx     #$00
	lda     #$01
L0157:	jeq     L0154
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_LookForPlayers
	tax
	jeq     L0158
	jmp     L0184
L0158:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$08
	jsr     ldauidx
	jsr     pusha
	jsr     _P_SetMobjState
	jmp     L0184
L0154:	ldy     #$01
	jsr     ldaxysp
	ldy     #$08
	jsr     ldauidx
	ldx     #$00
	and     #$02
	stx     tmp1
	ora     tmp1
	jeq     L015E
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$08
	jsr     ldauidx
	and     #$FD
	ldy     #$08
	jsr     staspidx
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_NewChaseDir
	jmp     L0184
L015E:	ldy     #$01
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$0B
	jsr     ldauidx
	jeq     L0166
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_CheckMeleeRange
	tax
	jne     L0165
L0166:	ldx     #$00
	lda     #$00
	jeq     L0168
L0165:	ldx     #$00
	lda     #$01
L0168:	jeq     L0164
	ldy     #$01
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$04
	jsr     ldauidx
	jeq     L0169
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$04
	jsr     ldauidx
	jsr     pusha
	jsr     _S_StartSound
L0169:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$0B
	jsr     ldauidx
	jsr     pusha
	jsr     _P_SetMobjState
	jmp     L0184
L0164:	ldy     #$01
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$0C
	jsr     ldauidx
	jeq     L0171
	ldy     #$01
	jsr     ldaxysp
	ldy     #$0A
	jsr     ldaidx
	jeq     L0173
	jmp     L0171
L0173:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_CheckMissileRange
	jsr     bnega
	jeq     L0176
	jmp     L0171
L0176:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$0C
	jsr     ldauidx
	jsr     pusha
	jsr     _P_SetMobjState
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$08
	jsr     ldauidx
	ora     #$02
	ldy     #$08
	jsr     staspidx
	jmp     L0184
L0171:	ldy     #$01
	jsr     ldaxysp
	sta     ptr1
	stx     ptr1+1
	ldy     #$0A
	ldx     #$00
	lda     (ptr1),y
	sec
	sbc     #$01
	sta     (ptr1),y
	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jne     L017F
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_Move
	jsr     bnega
	jne     L017F
	ldx     #$00
	lda     #$00
	jeq     L0181
L017F:	ldx     #$00
	lda     #$01
L0181:	jeq     L017E
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_NewChaseDir
L017E:	ldy     #$01
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$02
	jsr     ldauidx
	jeq     L0186
	jsr     _P_Random
	cmp     #$03
	jsr     boolult
	jne     L0185
L0186:	ldx     #$00
	lda     #$00
	jeq     L0187
L0185:	ldx     #$00
	lda     #$01
L0187:	jeq     L0184
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0D
	jsr     ldaxidx
	ldy     #$02
	jsr     ldauidx
	jsr     pusha
	jsr     _S_StartSound
L0184:	jsr     incsp2
	rts

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ R_PointToAngle (int, int)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_R_PointToAngle: near

.segment	"CODE"

	ldy     #$03
	jsr     ldaxysp
	txa
	jsr     boolge
	jeq     L018C
	ldy     #$01
	jsr     ldaxysp
	txa
	jsr     boolge
	jeq     L018E
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$02
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     tosmulax
	jsr     tosgtax
	jeq     L0190
	ldx     #$00
	lda     #$00
	jmp     L018B
	jmp     L0197
L0190:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$02
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	jsr     tosmulax
	jsr     tosgtax
	jeq     L0194
	ldx     #$00
	lda     #$02
	jmp     L018B
	jmp     L0197
L0194:	ldx     #$00
	lda     #$01
	jmp     L018B
L0197:	jmp     L01A3
L018E:	ldy     #$01
	jsr     ldaxysp
	jsr     negax
	ldy     #$00
	jsr     staxysp
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$02
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     tosmulax
	jsr     tosgtax
	jeq     L019C
	ldx     #$00
	lda     #$00
	jmp     L018B
	jmp     L01A3
L019C:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$02
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	jsr     tosmulax
	jsr     tosgtax
	jeq     L01A0
	ldx     #$00
	lda     #$06
	jmp     L018B
	jmp     L01A3
L01A0:	ldx     #$00
	lda     #$07
	jmp     L018B
L01A3:	jmp     L01BD
L018C:	ldy     #$03
	jsr     ldaxysp
	jsr     negax
	ldy     #$02
	jsr     staxysp
	ldy     #$01
	jsr     ldaxysp
	txa
	jsr     boolge
	jeq     L01A8
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$02
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     tosmulax
	jsr     tosgtax
	jeq     L01AA
	ldx     #$00
	lda     #$04
	jmp     L018B
	jmp     L01B1
L01AA:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$02
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	jsr     tosmulax
	jsr     tosgtax
	jeq     L01AE
	ldx     #$00
	lda     #$02
	jmp     L018B
	jmp     L01B1
L01AE:	ldx     #$00
	lda     #$01
	jmp     L018B
L01B1:	jmp     L01BD
L01A8:	ldy     #$01
	jsr     ldaxysp
	jsr     negax
	ldy     #$00
	jsr     staxysp
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$02
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     tosmulax
	jsr     tosgtax
	jeq     L01B6
	ldx     #$00
	lda     #$04
	jmp     L018B
	jmp     L01BD
L01B6:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldx     #$00
	lda     #$02
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	jsr     tosmulax
	jsr     tosgtax
	jeq     L01BA
	ldx     #$00
	lda     #$06
	jmp     L018B
	jmp     L01BD
L01BA:	ldx     #$00
	lda     #$05
	jmp     L018B
L01BD:	ldx     #$00
	lda     #$00
	jmp     L018B
L018B:	jsr     incsp4
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ A_FaceTarget (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_A_FaceTarget: near

.segment	"CODE"

	ldy     #$01
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     bnegax
	jeq     L01C1
	jmp     L01C0
L01C1:	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$08
	jsr     ldauidx
	and     #$F7
	ldy     #$08
	jsr     staspidx
	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$01
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$03
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	jsr     _R_PointToAngle
	ldy     #$07
	jsr     staspidx
L01C0:	jsr     incsp2
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ A_PosAttack (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_A_PosAttack: near

.segment	"CODE"

	jsr     decsp4
	ldy     #$05
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     bnegax
	jeq     L01CA
	jmp     L01DA
L01CA:	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	jsr     _A_FaceTarget
	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	lda     #$01
	jsr     pusha
	jsr     _S_StartSound
	ldy     #$05
	jsr     ldaxysp
	ldy     #$01
	jsr     ldaxidx
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$01
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	ldy     #$03
	jsr     ldaxidx
	jsr     pushax
	ldy     #$09
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	ldy     #$03
	jsr     ldaxidx
	jsr     tossubax
	jsr     pushax
	jsr     _P_ApproxDistance
	ldy     #$00
	jsr     staxysp
	ldy     #$01
	jsr     ldaxysp
	cmp     #$DD
	txa
	sbc     #$00
	bvs     L01D7
	eor     #$80
L01D7:	asl     a
	lda     #$00
	ldx     #$00
	rol     a
	jeq     L01D5
	ldy     #$01
	jsr     ldaxysp
	cpx     #$00
	bne     L01D9
	cmp     #$DC
L01D9:	jsr     booleq
L01D5:	jsr     _P_Random
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     tosugtax
	jeq     L01DA
	jsr     _P_Random
	ldx     #$00
	and     #$03
	jsr     incax2
	jsr     mulax3
	ldy     #$02
	jsr     staxysp
	ldy     #$05
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	jsr     pushax
	ldy     #$09
	jsr     ldaxysp
	jsr     pushax
	ldy     #$09
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_DamageMobj
L01DA:	jsr     incsp6
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ A_TroopAttack (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_A_TroopAttack: near

.segment	"CODE"

	jsr     decsp2
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     bnegax
	jeq     L01E6
	jmp     L01E5
L01E6:	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	jsr     _A_FaceTarget
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_CheckMeleeRange
	tax
	jeq     L01EA
	jsr     _P_Random
	ldx     #$00
	and     #$07
	jsr     incax1
	jsr     mulax3
	ldy     #$00
	jsr     staxysp
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	jsr     pushax
	ldy     #$07
	jsr     ldaxysp
	jsr     pushax
	jsr     _P_DamageMobj
	jmp     L01E5
L01EA:	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldy     #$05
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     pushax
	lda     #$06
	jsr     pusha
	jsr     _P_SpawnMissile
L01E5:	jsr     incsp4
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ A_Fall (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_A_Fall: near

.segment	"CODE"

	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$08
	jsr     ldauidx
	and     #$EF
	ldy     #$08
	jsr     staspidx
	jsr     incsp2
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ A_Explode (__near__ struct mobj_T*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_A_Explode: near

.segment	"CODE"

	ldy     #$01
	jsr     ldaxysp
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	ldy     #$0F
	jsr     ldaxidx
	jsr     pushax
	ldx     #$00
	lda     #$80
	jsr     pushax
	jsr     _P_RadiusAttack
	jsr     incsp2
	rts

.endproc
