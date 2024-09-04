cl65 -I c:\retro\cc65-2.13.3\include -I src -I src\textures -I . --lib-path c:\retro\cc65-2.13.3\lib -t c128 -C doom_c128_cc65.cfg -Ln doom128.lbl -O -Cl src\zeropage.s src\core_system.s src\core_system_c.c src\core_math.s src\display_screen.s src\display_screen_c.c src\display_geometry.c src\display_blit.s src\vicdoom.c src\menu.c src\automap.c src\p_enemy.c src\summary.c src\victory.c src\util.c src\cheatsAsm.s src\utilAsm_c128.s src\enemy.s src\m_random.s src\doomlogo.s src\drawLine.s src\updateInput_c128.s src\doomfont.s src\textures\textures.s src\dpsounds.s src\playSound_c128.s src\drawColumnAsm_c128.s src\mapAsm.s -vm -m map.txt -o doom_u128.prg

@IF %ERRORLEVEL% NEQ 0 ( 
   EXIT /b %ERRORLEVEL% 
)

exomizer sfx basic -t128 -odoom128.prg doom_u128.prg

@IF %ERRORLEVEL% NEQ 0 ( 
   EXIT /b %ERRORLEVEL% 
)

cc65mapsort map.txt sortedmap.txt labels.txt

@echo off
mid2vic\debug\prepend_load_address e1m1 ae00
mid2vic\debug\prepend_load_address e1m2 ae00
mid2vic\debug\prepend_load_address e1m3 ae00
mid2vic\debug\prepend_load_address e1m4 ae00
mid2vic\debug\prepend_load_address e1m5 ae00
mid2vic\debug\prepend_load_address e1m6 ae00
mid2vic\debug\prepend_load_address e1m7 ae00
mid2vic\debug\prepend_load_address e1m8 ae00
mid2vic\debug\prepend_load_address e1m9 ae00
mid2vic\debug\prepend_load_address e1m1mus b750
mid2vic\debug\prepend_load_address e1m2mus b750
mid2vic\debug\prepend_load_address e1m3mus b750
mid2vic\debug\prepend_load_address e1m4mus b750
mid2vic\debug\prepend_load_address e1m5mus b750
mid2vic\debug\prepend_load_address e1m6mus b750
mid2vic\debug\prepend_load_address e1m7mus b750
mid2vic\debug\prepend_load_address e1m8mus b750
mid2vic\debug\prepend_load_address e1m9mus b750
mid2vic\debug\prepend_load_address intermus b750
mid2vic\debug\prepend_load_address victormus b750
mid2vic\debug\prepend_load_address sluts 0f00
mid2vic\debug\prepend_load_address lowcode 1140
mid2vic\debug\prepend_load_address textures a000
mid2vic\debug\prepend_load_address sounds ba70
mid2vic\debug\prepend_load_address hicode ad00
mid2vic\debug\prepend_load_address stackcode 0100
mid2vic\debug\prepend_load_address victory1.txt be00
mid2vic\debug\prepend_load_address victory2.txt be00
mid2vic\debug\prepend_load_address credits.txt be00
mid2vic\debug\prepend_load_address order.txt be00
mid2vic\debug\prepend_load_address help.txt be00

c1541 -format doom,id d64 doom128.d64 -write doom128.prg -write ptextures -write pe1m1 -write pe1m2 -write pe1m3 -write pe1m4 -write pe1m5 -write pe1m6 -write pe1m7 -write pe1m8 -write pe1m9 -write pe1m1mus -write pe1m2mus -write pe1m3mus -write pe1m4mus -write pe1m5mus -write pe1m6mus -write pe1m7mus -write pe1m8mus -write pe1m9mus -write pintermus -write pvictormus -write psluts -write psounds -write plowcode -write phicode -write pstackcode -write phelp.txt -write pvictory1.txt -write pvictory2.txt -write pcredits.txt -write porder.txt

@echo on

x128 -silent doom128.d64
