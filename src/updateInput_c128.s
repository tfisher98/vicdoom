.setcpu		"6502"

.export updateInput
.export _readInput
.export _getControlKeys

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
keys = $34
ctrlKeys = $35
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

		
 ;; .segment "LOWCODE"

.proc _getControlKeys : near

lda storedCtrlKeys
rts

.endproc
