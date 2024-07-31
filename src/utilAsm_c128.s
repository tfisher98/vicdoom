.setcpu "6502"
.segment "CODE"

.import addysp
.importzp sp
.importzp sreg
.import _P_Random
.import _readInput
.import _getControlKeys

.export intToAsc

.export _addKeyCard
.export _keyCardColor
.export _resetKeyCard
.export _haveKeyCard

.export _setObjForMobj
.export _objForMobj
.export _mobjForObj

.autoimport on

.segment "CODE"
	
intToAsc:
  ldy #$2f
  ldx #$3a
  sec
:   iny
    sbc #100
    bcs :-
:   dex
    adc #10
    bmi :-
  adc #$2f
  rts

.segment "HICODE"
	
keyCard:
.byte 0
keyCardColors:
.byte 0,2,5,6
keyCardMasks:
.byte 1,2,4,8

_resetKeyCard:
  lda #0
  sta keyCard
  rts

_addKeyCard:
  ora keyCard
  sta keyCard

  tay

  ldx #3
keyLoop:
;;;  todo todo todo
	lda #';'
  ;; sta $11df,x
  tya
  and keyCardMasks,x
  beq :+
  lda keyCardColors,x
  :
  ;; sta $95df,x
  dex
  bne keyLoop
  rts

_keyCardColor:
  tax
  lda keyCardColors,x
  rts

_haveKeyCard:
  tax
  lda keyCardMasks,x
  and keyCard
  rts

.segment "CODE"
	
objForMobj:
.res 21,0
mobjForObj:
.res 49,0

_setObjForMobj:
  ; A - mobj
  ; TOS - obj

  ; x - mobj
  tax
  ; y - obj
  ldy #0
  lda (sp),y
  tay
  sta objForMobj,x
  txa
  sta mobjForObj,y
  ldy #1
  jmp incsp1

_objForMobj:
  tax
  lda objForMobj,x
  rts

_mobjForObj:
  tax
  lda mobjForObj,x
  rts

