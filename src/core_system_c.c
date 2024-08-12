#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "core_system.h"
#include "display_screen.h"
#include "util.h"
#include "playSound.h"

#pragma staticlocals(on)

void __fastcall__ load_data_file(char *fname)
{
  load_file(fname, strlen(fname));
}

void __fastcall__ playMusic(char *name)
{
  stopMusic();
  load_data_file(name);
  startMusic();
}
