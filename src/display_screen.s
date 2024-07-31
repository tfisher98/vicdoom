.setcpu "6502"
.segment "CODE"

.import addysp
.importzp sp

.export _eraseMessage
.export _meltScreen
.export _setTextColor
.export _print3DigitNumToScreen
.export _print2DigitNumToScreen
.export _clearScreen
.export _setupBitmap
.export _clearMenuArea
.export _drawBorders
.export _colorFace
.export _drawFace
.export _updateFace
	
.autoimport on

.segment "HICODE"

charrowsize = 40
charscreenstart := $0400
charcolorstart := $d800	
message1 := charscreenstart + charrowsize*16
message2 := charscreenstart + charrowsize*17
menustart := charscreenstart + charrowsize*11
facestart := charscreenstart + charrowsize*20+10
facecolorstart := charcolorstart + charrowsize*20+10	
bitmaprows = 8
bitmapcols = 8
bitmapcharstart := charscreenstart + charrowsize*2 + charrowsize/2 -bitmapcols/2
bitmapcolorstart := charcolorstart + charrowsize*2 + charrowsize/2 -bitmapcols/2
firstbitmapchar = 64
	
_eraseMessage:

ldx #40
lda #32
woop:
sta message1,x
sta message2,x
dex
bpl woop
rts

yyy:
.byte 0
yyyx22:
.byte 0
xxx:
.byte 0
charColor:
.byte 0

_clearScreen:

ldy #0
:
  lda #32
  sta charscreenstart+0,y ; clear screen
  sta charscreenstart+$100,y
  sta charscreenstart+$200,y ; clear screen
  sta charscreenstart+$300,y
  lda #2
  sta charcolorstart,y
  sta charcolorstart+$100,y
  sta charcolorstart+$200,y
  sta charcolorstart+$300,y
  iny
  bne :-
  rts

_setupBitmap:

sta charColor

  jsr _clearSecondBuffer
  jsr _copyToPrimaryBuffer

; write an 8x8 block for the graphics
; into the middle of the screen

lda #<bitmapcharstart
sta bitmapwritechar+1
sta bitmapwritecolor+1
lda #>bitmapcharstart	
sta bitmapwritechar+2
lda #>bitmapcolorstart
sta bitmapwritecolor+2
	
lda #0
sta yyy	

outerloop:
;;  start with yyy in A
clc
adc #64 			; first bitmap char
ldx #0
innerloop:

bitmapwritechar:
sta bitmapcharstart,x		; selfmod address

tay
lda charColor	
bitmapwritecolor:
sta bitmapcolorstart,x 		; selfmod address
tya
	
clc
adc #8 				; bitmaprows
inx
cpx #8 				; bitmapcols
bne innerloop

lda bitmapwritechar+1
clc
adc #40
sta bitmapwritechar+1
sta bitmapwritecolor+1
bcc :+
inc bitmapwritechar+2
inc bitmapwritecolor+2
:
inc yyy
lda yyy
cmp #bitmaprows
bne outerloop

rts

_clearMenuArea:

lda #32
ldx #charrowsize*5-1
:
sta menustart,x
dex
bpl :-
rts

_drawBorders:
rts

;;;  TODO
;; tay

;; ; borders at the bottom
;; ldx #21
;; :
;; tya
;; sta $1176,x
;; sta $11a2,x
;; lda #6
;; sta $9576,x
;; sta $95a2,x
;; dex
;; bpl :-

;; ; top and bottom of bitmap

;; ldx #9
;; :
;; tya
;; sta $101c,x
;; sta $10e2,x
;; lda #6
;; sta $941c,x
;; sta $94e2,x
;; dex
;; bpl :-

;; ; left and right of bitmap
;; ldx #154
;; :
;; tya
;; sta $1032,x
;; sta $103b,x
;; lda #6
;; sta $9432,x
;; sta $943b,x
;; txa
;; sec
;; sbc #22
;; tax
;; bcs :-

;; rts

textcolor:
.byte 1

_setTextColor:
  sta textcolor
  rts

.segment "CODE"
x22p7:
.byte 51, 73, 95, 117, 139, 161, 183
meltCount:
.byte 0
column:
.byte 0

.proc _meltScreen: near

    sta sm+1
   
    lda #180
    sta meltCount

again:
    jsr _P_Random
    lsr
    lsr
    and #7
    sta column
   
    lda #1
    jsr _waitForRaster
   
    ; melt column
    ldy #6
:
    lda x22p7,y
    clc
    adc column
    tax
    lda $0400,x
    sta $0400+40,x
    dey
    bpl :-
    ldx column
    lda #32
    sta $0400+51,x
   
sm: lda #0 ; health
    beq :+
   
    dec meltCount
    bne again
    rts
:
    jsr _readInput
    jsr _getControlKeys
    and #$01 ; KEY_RETURN (0x80 on VIC)
    beq again
    rts

.endproc


.segment "CODE"
.proc _print3DigitNumToScreen: near
  ; AX pos
  ; TOS num (char)

  sta sm1+1
  sta sm2+1
  txa
  sta sm1+2
  clc
  adc #(charcolorstart-charscreenstart)/256
  sta sm2+2

  ldy #0
  lda (sp),y
  jsr intToAsc
  pha
  txa
  pha
  tya
  pha

  ldy #0
  :
  pla
sm1: sta $0400,y
  lda textcolor
sm2: sta $d800,y
  iny
  cpy #3
  bne :-

  jmp incsp1

.endproc


.proc _print2DigitNumToScreen: near
  ; AX pos
  ; TOS num (char)

  sta sm1+1
  sta sm2+1
  txa
  sta sm1+2
  clc
  adc #(charcolorstart-charscreenstart)/256
  sta sm2+2

  ldy #0
  lda (sp),y
  jsr intToAsc
  pha
  txa
  pha

  ldy #0
  :
  pla
sm1: sta $0400,y
  lda textcolor
sm2: sta $d800,y
  iny
  cpy #2
  bne :-

  jmp incsp1

.endproc


faceColor:
.byte 7,3
faceChars:
.byte 27,28,35,36,42,43
faceOff:
.byte 0,1,40,41,80,81
;; .byte $c2,$c3,$d8,$d9,$ee,$ef	
changeLookTime:
.byte 7
lookDir:
.byte 0

_colorFace:
  ; A = godMode 0 or 1
  ; convert to yellow (7) or cyan (3)
  tay
  lda faceColor,y
  ldx #5
  :
  ldy faceOff,x
  sta facecolorstart,y
  dex
  bpl :-
  rts

_drawFace:
  ldx #5
  :
  ldy faceOff,x
  lda faceChars,x
  sta facestart,y
  dex
  bpl :-
  rts

_updateFace:
  dec changeLookTime
  beq :+
  rts
  :
  lda lookDir
  eor #$ff
  sta lookDir
  beq :+
  ldx #6
  ldy #40
  bne drawFacePart
  :
  ldx #12
  ldy #35
drawFacePart:
  stx changeLookTime
  sty facestart+40
  iny
  sty facestart+41
  rts
