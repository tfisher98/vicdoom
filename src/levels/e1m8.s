.segment "MAPDATA"
; sector data
secVerts:
.byte 45, 44, 51, 52, 0, 0, 0, 0, 47, 48, 42, 43, 44, 45, 46, 0
.byte 50, 49, 48, 47, 5, 51, 13, 0, 36, 35, 34, 30, 33, 37, 16, 0
.byte 32, 31, 38, 39, 40, 41, 0, 0, 0, 24, 25, 1, 21, 15, 14, 0
.byte 7, 12, 15, 18, 19, 6, 14, 0, 53, 7, 6, 54, 20, 6, 14, 0
.byte 56, 53, 54, 55, 20, 6, 14, 0, 30, 56, 55, 31, 20, 6, 14, 0
.byte 12, 17, 16, 15, 20, 6, 68, 0, 18, 22, 23, 19, 20, 6, 0, 0
.byte 33, 30, 31, 32, 20, 6, 0, 0, 42, 33, 32, 43, 20, 6, 0, 0
.byte 9, 26, 10, 11, 14, 13, 0, 0, 21, 2, 3, 27, 4, 20, 0, 0
.byte 8, 9, 13, 12, 7, 28, 0, 0, 6, 19, 20, 4, 5, 29, 45, 44
.byte 11, 0, 1, 2, 21, 14, 0, 0
.res 360, 0

secEdges:
.byte 61, 42, 41, 40, 0, 0, 0, 0, 62, 45, 44, 43, 61, 39, 38, 0
.byte 36, 35, 62, 37, 77, 61, 51, 0, 53, 52, 51, 48, 55, 54, 19, 0
.byte 49, 56, 57, 60, 59, 58, 0, 0, 17, 18, 19, 3, 16, 8, 32, 0
.byte 29, 71, 33, 73, 34, 72, 33, 0, 67, 72, 68, 70, 36, 74, 33, 0
.byte 66, 70, 69, 63, 37, 75, 34, 0, 65, 63, 64, 50, 37, 75, 34, 0
.byte 10, 9, 8, 71, 38, 76, 89, 0, 14, 13, 12, 73, 38, 76, 0, 0
.byte 48, 50, 49, 74, 39, 77, 0, 0, 46, 74, 47, 44, 39, 77, 0, 0
.byte 20, 21, 1, 30, 7, 28, 0, 0, 31, 5, 23, 22, 32, 15, 0, 0
.byte 0, 28, 11, 29, 25, 24, 0, 0, 34, 16, 32, 6, 27, 26, 39, 38
.byte 2, 3, 4, 31, 75, 30, 0, 0
.res 360, 0

; summary data (8 bytes)
numVerts:
.byte 57
numEdges:
.byte 76
numSectors:
.byte 19
numObj:
.byte 23
playerSpawnX:
.byte -14
playerSpawnY:
.byte -49
playerSpawnAngle:
.byte 16
playerSpawnSector:
.byte 2
numEnemies:
.byte 4
numItems:
.byte 13
numSecrets:
.byte 1
parTime:
.byte 90
secretSectors:
.byte 0
.res 7, 0

; sector info
secNumVerts:
.byte 4, 7, 4, 6, 6, 4, 6, 4, 4, 4, 4, 4, 4, 4, 6, 6
.byte 6, 6, 6
.res 45, 0

; object data
objXhi:
.byte -4, 5, 4, 4, 0, 11, 9, 9, -10, -9, -2, 2, -20, -27, 20, 27
.byte -21, 20, 10, -7, 9, 6, -8
.res 25, 0

objYhi:
.byte 18, 18, -47, -51, -49, -50, -25, -32, -24, -30, -5, -5, -9, 27, -9, 27
.byte 28, 23, -50, -25, -28, -27, -28
.res 25, 0

objType:
.byte 3, 3, 2, 2, 12, 6, 5, 8, 8, 14, 14, 14, 7, 8, 8, 7
.byte 14, 12, 18, 7, 7, 7, 17
.res 25, 0

objSec:
.byte 10, 11, 1, 1, 1, 0, 4, 4, 3, 3, 9, 9, 16, 14, 17, 15
.byte 14, 15, 0, 3, 4, 4, 3
.res 25, 0

; vertex data
vertX:
.byte -3, 3, 10, 30, 15, 24, 4, -4, -24, -15, -30, -10, -7, -9, -7, -2
.byte -2, -7, 2, 7, 9, 7, 2, 7, -3, 3, -30, 30, -19, 19, -3, 3
.byte 3, -3, -7, -13, -13, -7, 7, 13, 13, 7, -3, 3, 8, 8, 0, -8
.byte -8, -17, -17, 14, 14, -4, 4, 4, -4
.res 83, 0

vertY:
.byte 52, 52, 30, 30, 14, -11, 2, 2, -11, 14, 30, 30, 16, 21, 25, 16
.byte 21, 21, 16, 16, 21, 25, 21, 21, 57, 57, 25, 25, -13, -13, -25, -25
.byte -30, -30, -21, -21, -34, -34, -21, -21, -34, -34, -42, -42, -47, -52, -55, -52
.byte -47, -47, -52, -47, -52, 1, 1, -2, -2
.res 83, 0

; edge data
edgeTex:
.byte 0, 0, 0, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 2, 197, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 1, 6, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0
.byte 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 64, 70, 117
.byte 0, 0, 0, 0, 0, 0, 208, 104, 208, 104, 70, 0
.res 124, 0

edgeSec1:
.byte -1, -1, -1, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
.byte -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 14, 6, 14, 15
.byte 15, -1, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, 1, -1, -1, -1
.byte 3, 4, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 1, 8
.byte -1, -1, -1, -1, -1, -1, 7, 6, 6, 6, 12, -1
.res 124, 0

edgeSec2:
.byte -1, -1, -1, 18, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
.byte -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 16, 16, 18, 18
.byte 17, -1, 17, -1, -1, -1, -1, -1, -1, -1, -1, -1, 13, -1, -1, -1
.byte 12, 12, 12, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 1, 2, 9
.byte -1, -1, -1, -1, -1, -1, 8, 10, 7, 11, 13, -1
.res 124, 0

edgeLen:
.byte 27, 20, 24, 6, 24, 20, 27, 5, 5, 5, 5, 6, 5, 5, 5, 5
.byte 6, 5, 6, 5, 19, 5, 19, 5, 6, 22, 22, 6, 10, 15, 6, 6
.byte 10, 4, 15, 9, 5, 9, 9, 9, 6, 5, 6, 8, 6, 8, 12, 12
.byte 5, 5, 6, 6, 6, 13, 6, 6, 6, 6, 6, 6, 13, 5, 5, 8
.byte 24, 24, 3, 1, 1, 3, 8, 5, 8, 5, 6, 14
.res 124, 0

