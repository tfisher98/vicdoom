cl65 -t vic20 -C vic20-32k-udg.cfg -O vicdoom.c menu.c doomlogo.s updateInput.s doomfont.s textures.s dpsounds.s playSound.s drawColumnAsm.s logMathAsm.s mapAsm.s -vm -m map.txt -o doom.prg
c:\app\WinVice-2.1\WinVice-2.1\c1541 -format doom,id d64 doom.d64 -write doom.prg -write textures
c:\app\WinVice-2.1\WinVice-2.1\xvic-r23120-win32 doom.d64
