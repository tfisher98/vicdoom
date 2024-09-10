.setcpu "6502X"
.segment "CODE"

.importzp sp
.importzp sreg

.export _load_bank
.export _load_file
.export _waitForRaster
.export _install_nmi_handler

.autoimport on

.segment "LOWCODE2"

; A - bank to load into (0 = bank0 ram; 1 = bank1 ram)
.proc _load_bank: near
	; SETBNK : A = i/o bank (0-15); X = filename bank (0-15)
	; updates ZP values C6, C7 for bank info
	ldx #0 ; FNBANK
	jmp SETBNK
.endproc

; params: filename, length of filename
; A - length of fname
; TOS - fname
.proc _load_file: near
	pha
	ldy #0
	lax (sp), y   ; x contains low byte
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
.endproc
	
.segment "LOWCODE2"

.proc nmi_handler: near
	rti
.endproc

.proc _install_nmi_handler: near
	sei
	lda #<nmi_handler
	sta $318
	lda #>nmi_handler
	sta $319
	cli
	rts
.endproc
	
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

