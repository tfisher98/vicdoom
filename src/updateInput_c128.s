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

dec $d020
	
lda #3
sta framesToNextUpdate
sta somethingToRead

	;; direction registers : 1 is read/write
	lda #$ff
	sta $dc02
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
asl
and #2 			
ora ctrlKeys
sta ctrlKeys

; query the keyboard line containing (VIC) <Left>WRYIP*<Ret>
; query the keyboard line containing (c128) <Ret>WRYIP*<Left>  
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
and #$81
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
and #$01
ora keys
sta keys
txa
asl
asl
asl
and #$80
ora keys
sta keys

inc $d020
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
