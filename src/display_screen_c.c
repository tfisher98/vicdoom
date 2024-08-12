#include <string.h>
#include <conio.h>

#include "util.h"
#include "core_system.h"
#include "display_screen.h"

extern char weapon;
extern char armor;
extern char combatArmor;
extern char shells;
extern char bullets;
extern signed char health;

void __fastcall__ printCentered(char *str, char y)
{
  char len = strlen(str);
  cputsxy(11 - len/2, y, str);
}

void __fastcall__ load_full_text_screen(char *fname)
{
  int i, k, m, q;
  char x, c, d;

  //POKE(0x900f,8); //black border
  //POKE(198, 0);

  // read in the text, then type it out
  load_data_file(fname);

  // clear screen
  clearScreen();

  k = 0xbe00; // back buffer
  i = 0x0400; // screen
  m = i;
  q = 0xd800; // color ram
  c = 2;
  d = 0;
  while (1)
  {
    x = PEEK(k);
    if (x == '@') break;
      
    if (x == '\n')
    {
      i += 40;
      m = i;
      q = m + 0xd800-0x0400;
    }
    else if (x == '^')
    {
      // toggle between red and yellow
      c = 9 - c;
    }
    else if (x == '#')
    {
      d = 1;
    }
    else if (x != '\r')
    {
      if (x > 96) x -= 96;
      x &= 63;
      POKE(m, x);
      POKE(q, c);
      ++m;
      ++q;
      POKE(m, 29);
      if (x != 32)
      {
        char wait = 4;
        if (d == 0)
        {
          if (x == '.' || x == '?' || x == '!') wait = 48;
          if (x == ',') wait = 16;
        }
        d = 0;
        // if (PEEK(198) == 0)
	waitForRaster(wait);
      }
      POKE(m, 32);
    }
    ++k;
  }
  
  // POKE(198, 0);
  while (1)
  {
    waitForRaster(32);
    POKE(m,29);
    //   if (PEEK(198)) break;
    waitForRaster(32);
    POKE(m,32);
    // if (PEEK(198)) break;
  }

  clearScreen();
}

void __fastcall__ drawHudArmor(void)
{
    char armorColor = 5 + combatArmor;
    POKE(0x0400 + 40*21 + 13, 30); // armor symbol in font
    POKE(0xd800 + 40*21 + 13, armorColor);
    setTextColor(armorColor);
    print3DigitNumToScreen(armor, 0x0400 + 40*21 + 14);
}

char weaponSymbol[] = { 62, 61, 38, 31, 34 };

void __fastcall__ drawHudAmmo(void)
{
  // weapon and ammo
  char sym = weaponSymbol[weapon];
  POKE(0x0400 + 40*21 + 1, sym);
  POKE(0xd800 + 40*21 + 1, 3);
  if (weapon < 2)
  {
    POKE(0x0400 + 40*21 + 2, 32);
    POKE(0x0400 + 40*21 + 3, 32);
    POKE(0x0400 + 40*21 + 4, 32);
  }
  else
  {
    setTextColor(3);
    print2DigitNumToScreen(weapon == 3 ? shells : bullets, 0x0400 + 40*21 + 2);
  }
}

void __fastcall__ drawHudHealth(void)
{
  // health
  POKE(0x0400 + 40*21 + 5, '/');
  POKE(0xd800 + 40*21 + 5, 2);
  setTextColor(2);
  print3DigitNumToScreen(health, 0x0400 + 40*21 + 6);
}
