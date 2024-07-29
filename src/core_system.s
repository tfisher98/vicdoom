.setcpu "6502"
.segment "CODE"

.importzp sp
.importzp sreg

.export _load_file
.export _waitForRaster
.export _install_nmi_handler

.autoimport on

.segment "LOWCODE2"

; params: filename, length of filename
; A - length of fname
; TOS - fname

_load_file:
  pha
  ldy #0
  lda (sp), y
  tax           ; x contains low byte
  iny
  lda (sp), y
  tay           ; y contains high byte
  pla

  jsr SETNAM ; $FFBD
  lda #1
  ldx #8      ; default to device 8
  ldy #1      ; 1 means: load to address stored in file
  jsr SETLFS ; $FFBA

  lda #$00      ; $00 means: load to memory (not verify)
  jsr LOAD ; $FFD5

  jmp incsp2

.segment "LOWCODE2"

nmi_handler:
  rti
_install_nmi_handler:
  sei
  lda #<nmi_handler
  sta $318
  lda #>nmi_handler
  sta $319
  cli
  rts

vicraster := $d012
.segment "CODE"
.proc _waitForRaster: near

  tay
  @loop:
    :
    lda vicraster
    cmp #16
    bpl :-
    :
    lda vicraster
    cmp #16
    bmi :-
    dey
    bne @loop
  rts

.endproc
