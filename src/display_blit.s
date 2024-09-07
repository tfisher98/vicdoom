.setcpu "6502X"
.autoimport	on

.macro c128_bank_game
	lda #$0e
	sta $ff00
.endmacro

.macro c128_bank_blit
	lda #$7f
	sta $ff00
.endmacro

c128_mmu_mzp := $d507
c128_mmu_m1p := $d509

;; memory design
;; blit code is run from a modified zero page location, so can be anywhere in memory
;; blit code stores output results in a modified one page location, so can be anywhere in memory
;; in practice we will put blit code in formerly texture space in bank 0?
;; in practice we will be sprite data in first 16k of bank 0 
;; blit setup needs to be called from main game code
;;   -> blit setup in bank 0 code
;; column tables are set from main game code, read from blit setup
;;   -> column tables in bank 0 data
;; blit code needs to access stride, texture, xlate tables which will be in bank 1
;;   -> switch bank within mzp code so code unaffected by the switch
;;   -> stride, texture, xlate tables [66 pages] in bank 1 data
;; during blit, interrupts may still occur. current IRQ setup calls kernal code which vectors via page3 to ???
;;   -> easier to leave kernal mapped in for bank_blit ? 
;;   -> need to make sure IRQ code is in ram shared per the RCR settings, currently bottom 1k
;;   -> need to make sure IRQ code uses <=7 stack entries (S=0..6). we reserve bottom two sprite pix rows as junk for this
;;   -> need to make sure IRQ code modifies only RCR-shared ram not in page 0 or 1

;; display design
;; we will use a bitmap on a 6*4 sprite wall. x and y expanded this covers 36 char wide * 21 char tall region.
;; pixel dimensions are 72 mc pixels wide by 80 pixels tall.
;; top two pixel rows and bottom two pixel rows of the sprite wall are junk and must be hidden
;; the 4 sprites of a column share the same memory page
;; eventually fast mode enabled during the sprite wall area (badlines occur but don't halt CPU)
;;   -> invalid video mode during bitmap area
;; initially slow mode, allow badlines during the sprite wall area. maybe still invalid mode during bitmap area for screen ram reuse?
;; IRQs :
;;   1  -> top of screen : set invalid video mode. 1st y sprite positions. blank screen page for sprite pointers
;;   2  -> 2nd raster 1st sprite row : 1st screen page for sprite pointers. 2nd y sprite positions. slow mode
;;   3  -> bottom raster 1st sprite row : 2nd screen page for sprite pointers. wait til next raster; 3rd y sprite positions
;;   4  -> bottom raster 2nd sprite row : 3rd screen page for sprite pointers. wait til next raster; 4th y sprite positions
;;   5  -> bottom raster 3rd sprite row : 4th screen page for sprite pointers
;;   6  -> 2nd from bottom raster 4th sprite row : blank screen page for sprite pointers. fast mode
;;   7a -> [if message active] before text badline : slow mode
;;   7b -> [no message active] before HUD badline : slow mode
;;   8  -> after HUD : fast mode

.segment "BLITDATA"
column_ha: .res 72
column_hb = column_ha+1
column_hc = column_ha+2
column_hd = column_ha+3

column_talo: .res 72
column_tblo = column_talo+1
column_tclo = column_talo+2
column_tdlo = column_talo+3

column_tahi: .res 72
column_tbhi = column_tahi+1
column_tchi = column_tahi+2
column_tdhi = column_tahi+3

bytecolumn_mzp: .res 18
bytecolumn_m1p: .res 18
frame_m1p_eor: .byte 0

stride_hi: .res 256
stride_lo: .res 256

;; stride tables are 40 bytes long interleaved at 2 bytes. 6 tables per page, aligned so no indexing across pages  
.segment "BANK1DATA"
stride_tables: .res 256*43
;; stride_za etc are standins for self-modified pointers to per-pixel-column stride tables in blit code below
stride_za = stride_tables
stride_zb = stride_tables
stride_zc = stride_tables
stride_zd = stride_tables

;; texture storage bits interleaved for top/bottom pixel : 0 t0 0 t1 0 b0 0 b1
;; texture columns interleaved are 16 bytes. add 17th byte = 0 as floor/ceiling value
;; 15*17 = 255 bytes. every 15th texture column we skip one byte to avoid page crossing
;; calculate address for column j of texture i (i=0..25, j=0..15):
;;    col = i*16+j
;;    extra = floor(col/15)
;;    offset = 17*col + extra
;;           = 16*17*i + 17*j + extra
;;    for texture i=0..14, extra occurs after column j=14-i
;;    between texture i=14 and i=15 there is another extra
;;    for texture i=15..25 extra occurs after column j=29-i
;;  => if (i<15) extra = (i+j<14) ? i-1 : i;
;;     else extra = (i+j<29) ? i : i+1;
;;     address = baseaddress + 256*i + 17*(i+j) + extra
;;    
.segment "BANK1DATA"
full_textures: .res 28*256 ; 26*16*17 + 26 extra + 70 bytes fill
tex_a = full_textures
tex_b = full_textures
tex_c = full_textures
tex_d = full_textures

;;   xlate1 : at0 bt0 at1 bt1 ab0 bb0 ab1 bb1 -> at0 at1 bt0 bt1   0   0   0   0
;;   xlate2 : ct0 dt0 ct1 dt1 cb0 db0 cb1 db1 ->   0   0   0   0 ct0 ct1 dt0 dt1
;;   xlate3 : at0 bt0 at1 bt1 ab0 bb0 ab1 bb1 -> ab0 ab1 bb0 bb1   0   0   0   0
;;   xlate4 : ct0 dt0 ct1 dt1 cb0 db0 cb1 db1 ->   0   0   0   0 cb0 cb1 db0 db1
.segment "BANK1DATA"
xlate1: .res 256
xlate2: .res 256
xlate3: .res 256
xlate4: .res 256


;; (!!!!) NEW BESTEST MOSTEST TEX*2 4 COLOR SPRITE ONLY
;; quad load dual quad store looped ... code in mzp / out high in m1p / out low via pointer table in mzp
;; stride tables are 40 bytes long interleaved at 2 bytes. 6 tables per page, aligned so no indexing across pages 
;; setup selfmods the high/low byte index_table for za/zb/zc/zd, high/low byte of tex_a,tex_b,tex_c,tex_d
;; selfmod setup 16 bytes * 7 cycles = 112 cycles
;; texture storage bits interleaved for top/bottom pixel : 0 t0 0 t1 0 b0 0 b1
;;   xlate1 : at0 bt0 at1 bt1 ab0 bb0 ab1 bb1 -> at0 at1 bt0 bt1   0   0   0   0
;;   xlate2 : ct0 dt0 ct1 dt1 cb0 db0 cb1 db1 ->   0   0   0   0 ct0 ct1 dt0 dt1
;; need 3 copies (on separate mzp pages) for sprite byte columns (zp_top,zp_bot tables modified by +0,+1,+2)
;;
;;  (tex[ti]) ldy index_tab_za,x / lda tex_a,y / asl                  ... 4 4 2   = 10
;;  (tex[ti]) ldy index_tab_zb,x / ora tex_b,y / sta x12t / sta x12b  ... 4 4 3 3 = 14
;;  (tex[ti]) ldy index_tab_zc,x / lda tex_c,y / asl                  ... 4 4 2   = 10
;;  (tex[ti]) ldy index_tab_zd,x / ora tex_d,y / tay                  ... 4 4 2   = 10
;;  (topquad) lda xlate1 / ora xlate2,y / sta (zp_top,x)              ... 4 4 6   = 14
;;  (botquad) lda xlate3 / ora xlate4,y / sta (zp_bot,x)              ... 4 4 6   = 14
;;  (looping) dex / dex / bpl loop                                    ... 2 2 3   = 7
;; [bytes 7 10 7 7 8 8 4 = 51 + 160 tables = 211 ]                   ======= 79*Q = 39.5*D = 19.75*N = 9.9*M


;;   on entry X is outermost top/bottom pixel pair to draw
;;   mzp to point to this routine with its associated tables
;;   m1p to point to the sprites for output
;;   sm_za,sm_zb,sm_zc,sm_zd addresses+1 set up to point to correct stride tables for pixel columns a,b,c,d
;;   sm_ta,sm_tb,sm_tc,sm_td addresses+1 set up to point to correct texture tables for pixel columns a,b,c,d
.segment "MODIFIEDZP1" : zeropage

.proc blit_byte_column_mzp:near
	.globalzp sm_t12, sm_b12

mzp_top:
	.word $106, $109, $10c, $10f, $112, $115, $118, $11b, $11e, $121
	.word $124, $127, $12a, $12d, $130, $133, $136, $139, $13c
	.word $140, $143, $146, $149, $14c, $14f, $152, $155, $158, $15b
	.word $15e, $161, $164, $167, $16a, $16d, $170, $173, $176, $179, $17c
mzp_bot:
	.word $1f6, $1f3, $1f0, $1ed, $1ea, $1e7, $1e4, $1e1, $1de, $1db
	.word $1d8, $1d5, $1d2, $1cf, $1cc, $1c9, $1c6, $1c3, $1c0
	.word $1bc, $1b9, $1b6, $1b3, $1b0, $1ad, $1aa, $1a7, $1a4, $1a1
	.word $19e, $19b, $198, $195, $192, $18f, $18c, $189, $186, $183, $180	

mzpblit:
	c128_bank_blit ;; code is running in mmu-modified zero page so unaffected by bank switch
mzploop:
sm_za:  ldy stride_za,x
sm_ta:  lda tex_a,y
	asl
sm_zb:  ldy stride_zb,x
sm_tb:  ora tex_b,y
	sta sm_t12+1
	sta sm_b12+1
sm_zc:  ldy stride_zc,x
sm_tc:  lda tex_c,y
	asl
sm_zd:  ldy stride_zd,x
sm_td:  ora tex_d,y
	tay
sm_t12: lda xlate1
	ora xlate2,y
	sta (mzp_top,x)
sm_b12: lda xlate3
	ora xlate4,y
	sta (mzp_bot,x)
	dex
	dex
	bpl mzploop
	c128_bank_game
	jmp sm_sp

	;; inputs:
	;;   A =: col : byte column to blit 
	;;   column_h[col*4],column_h[col*4+1],column_h[col*4+2],column_h[col*4+3] : stride rates for columns a,b,c,d
	;;   column_tlo[col*4],column_tlo[col*4+1],column_tlo[col*4+2],column_tlo[col*4+3] : texture lo pointers for columns a,b,c,d
	;;   column_thi[col*4],column_thi[col*4+1],column_thi[col*4+2],column_thi[col*4+3] : texture hi pointers for columns a,b,c,d
	;; outputs:
	;;   composited bytes at (mzp_top,i) and (mzp_bot,i) for i in 0..X
	;; assumptions
	;;   caution about interrupts and mzp/m1p
	;;   
	.segment "CODE"
blit_byte_column:
	tsx
	stx sm_sp+1
	tax
	asl
	asl
	tay
	lda bytecolumn_mzp,x
	sta c128_mmu_mzp
	lda bytecolumn_m1p,x
	eor frame_m1p_eor
	ldx #0
	sei
	sta c128_mmu_m1p
	tsx
	cli

	ldx column_ha,y
	lda stride_lo,x
	sta sm_za+1
	lda stride_hi,x
	sta sm_za+2
	lda column_talo,y
	sta sm_ta+1
	lda column_tahi,y
	sta sm_ta+2

	ldx column_hb,y
	lda stride_lo,x
	sta sm_zb+1
	lda stride_hi,x
	sta sm_zb+2
	lda column_tblo,y
	sta sm_tb+1
	lda column_tbhi,y
	sta sm_tb+2

	ldx column_hc,y
	lda stride_lo,x
	sta sm_zc+1
	lda stride_hi,x
	sta sm_zc+2
	lda column_tclo,y
	sta sm_tc+1
	lda column_tchi,y
	sta sm_tc+2

	ldx column_hd,y
	lda stride_lo,x
	sta sm_zd+1
	lda stride_hi,x
	sta sm_zd+2
	lda column_tdlo,y
	sta sm_td+1
	lda column_tdhi,y
	sta sm_td+2

	ldx #$28     ; SCREENHEIGHT/2
	jmp mzpblit
	
sm_sp:  ldx #0
	sei
	sta c128_mmu_m1p
	txs
	cli
	ldx #0
	stx c128_mmu_mzp
	rts
.endproc
