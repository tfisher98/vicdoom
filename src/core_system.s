.setcpu "6502X"
.segment "CODE"

.importzp sp, sreg, KEY_COUNT
.importzp keys, ctrlKeys
.import KEYD

.export _scan_keyboard
.export _clear_keyboard_buffer
.export _get_key_count
.export _get_key_pressed
.export _load_bank
.export _load_file
.export _waitForRaster
.export _install_nmi_handler

.export updateInput
.export _readInput
.export _getControlKeys

.autoimport on

.segment "LOWCODE2"

.proc _scan_keyboard : near
	;; direction registers : 1 is read/write
	;; kernal scan routine assumes direction set as follows. our ctrlkey scan routine uses rows/columns switched
	lda #$ff
	sta $dc02
	lda #$00
	sta $dc03

	jmp SCNKEY ; $ff9f
.endproc
	
.proc _clear_keyboard_buffer: near
	lda #0
	sta KEY_COUNT ; $d0
	rts
.endproc

.proc _get_key_count: near
	lda KEY_COUNT ; $d0
	rts
.endproc

.proc _get_key_pressed: near
	lda KEYD ; $34a
	rts
.endproc

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

.segment "STACKCODE"

; bits reversed from normal understanding
; so lowest at the left
; -AD-JL--
;   -W--I---  <<2 (shift left because of reversal)
;-S------     >>1
;    ----K--- <<3
;=
; SADWJLIK
;
; <ctr>  -   -  -  -  -  -   -     >>1
; <esc>  -   -  -  -  -  - <ret>
;= 
; <esc><ctr> -  -  -  -  - <ret>  

; sometime soon I'm going to have to make a zero page map!
;  put this on the zero page to speed up the interrupt
framesToNextUpdate:
.byte 3
storedKeys:
.byte 0
storedCtrlKeys:
.byte 0
somethingToRead:
.byte 0

.proc updateInput : near	
	; although, really I should only read the keys every third or so interrupt for speed
	dec framesToNextUpdate
	bne read
	rts
read:
	lda #3
	sta framesToNextUpdate
	sta somethingToRead
	
	;; direction registers : 1 is read/write
	;; note following vic20 code we treat rows/columns opposite to C128 kernal code
	lda #$00
	sta $dc02
	lda #$ff
	sta $dc03
	
	; query the keyboard line containing (VIC) <Ctrl>ADGJL;<Right>
	; query the keyboard line containing (c128) <Right>ADGJL;<Ctrl>
	lda #$fb
	sta $dc01
	lda $dc00
	eor #$ff
	tax
	and #$36 ; get ADJL
	ora keys
	sta keys
	txa
	lsr
	and #$40 				; ctrl is #$80; shifted right to bit 6
	ora ctrlKeys
	sta ctrlKeys
	
	; query the keyboard line containing (VIC) <Left>WRYIP*<Ret>
	; query the keyboard line containing (c128) <Ret>WRYIP*<ESC>  
	lda #$fd
	sta $dc01
	lda $dc00
	eor #$ff
	tax
	asl
	asl
	and #$48 ; get WI
	ora keys
	sta keys
	txa
	and #$81			; <ESC> bit 7; <Ret> bit 1
	ora ctrlKeys
	sta ctrlKeys
	
	; query the keyboard line containing (VIC) <CBM>SFHK:=<F3>
	; query the keyboard line containing (c128) <F3>SFHK:=<CBM>  
	lda #$df
	sta $dc01
	lda $dc00
	eor #$ff
	tax
	lsr
	and #$01			; get S in low bit
	ora keys
	sta keys
	txa
	asl
	asl
	asl
	and #$80			; get K in high bit
	ora keys
	sta keys
	
	rts	
.endproc

.proc _readInput : near
	lda somethingToRead
	beq end

	ldx #0
	; keep the copy and clear as close as possible
	; so there's less chance of losing a keypress
	; even though we're reading key holds, not presses
	lda ctrlKeys
	stx ctrlKeys
	sta storedCtrlKeys
	lda keys
	stx keys
	sta storedKeys
	
	stx somethingToRead
	
end:
	lda storedKeys
	rts
.endproc

.proc _getControlKeys : near
	lda storedCtrlKeys
	rts	
.endproc
