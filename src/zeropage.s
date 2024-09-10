.fopt		compiler,"cc65 v 2.13.2"
.setcpu		"6502X"
.autoimport	on
.case		on
.debuginfo	off

.segment "ZEROPAGE"

;; hardware addresses $00 - $01
;; cc65 addresses $02 .. $15

;; playsound : IRQ access : TODO move out of ZP
.exportzp soundPointer    := $30
.exportzp soundPointer_hi := $31
.exportzp songindex       := $32
.exportzp songindex_hy    := $33
;; updateInput : IRQ access : TODO move out of ZP
.exportzp keys            := $34
.exportzp ctrlKeys        := $35

;; core_math
.exportzp tmple           := $40
.exportzp tmps            := $41
;; drawColumn
.exportzp tmp             := $42
.exportzp tmp_hi          := $43
.exportzp texIndex        := $44
.exportzp texI            := $45
.exportzp curX            := $46
.exportzp texY            := $47
.exportzp texY_hi         := $48
.exportzp height          := $49
;; core_math
.exportzp savex           := $4c
.exportzp savex_hi        := $4d
.exportzp angle           := $50
;; core_math / mapAsm
.exportzp cosa            := $51
.exportzp sina            := $52
.exportzp cameraX         := $57
.exportzp cameraX_hi      := $58
.exportzp cameraY         := $59
.exportzp cameraY_hi      := $5a
;; core_math
.exportzp T1              := $5b
.exportzp T2              := $5c
.exportzp T2_hi           := $5d
.exportzp PRODUCT         := $5e
.exportzp PRODUCT_hi      := $5f
;; mapAsm
.exportzp vertexCount     := $60
.exportzp vertexCounter   := $61
.exportzp vertexCounterPP := $62
.exportzp x_L             := $63
.exportzp x_R             := $65
.exportzp outsideSector   := $67
;; core_math / mapAsm
.exportzp xToTransform    := $68
.exportzp xToTransform_hi := $69
.exportzp yToTransform    := $6a
.exportzp yToTransform_hi := $6b
;; mapAsm
.exportzp edgeIndex       := $80
.exportzp sectorIndex     := $81
.exportzp numberOfVerts   := $82

;; C=128 Kernal
;; many addresses $90-$f8
.exportzp KEY_COUNT       := $D0
.exportzp SHFLG           := $D3

.export KEYD              := $34A
