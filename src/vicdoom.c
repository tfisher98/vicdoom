// doom for the vic-20
// written for cc65
// see make.bat for how to compile

// done
// X 1. move angle to sin/cos and logsin/logcos to a separate function and just use those values
// X 2. fix push_out code
// X 2.5. fix push_out code some more
// X 3. add transparent objects
// X 4. finish map and use that instead of the test map
// X 5. enemy AI (update only visible enemies, plus enemies in the current sector)
// X 5.5. per sector objects (link list)
// X 6. add keys and doors
// X 7. add health
// X 8. advance levels
// X 9. menus
// X 10. more optimization?
// X 11. use a double buffer scheme that draws to two different sets of characters and just copies the characters over
// X 12. optimize push_out code
// X 12.5 and the ai try_move code
// X 13. projectiles!
// X 14. remote doors need to be openable from the other side - new edge prop that opens a door with e=e-1
// X 16. make acid do damage
// X 17. fix sound glitches when loading data
// X 18. add weapons

// todo
// 19. test
// X 19.1 fix flashing projectile bug - was a bug in division: (long)/(unsigned int) fails for some negative numerators
// 19.2 fix multiple pickup bug - not sure what's happening; perhaps a stack overflow?
// 19.3 fix horrible flashing sector bug in E1M5 first secret
// 19.4 don't allow enemies to melee through walls/doors (it's just based on distance! ugh)
// 19.5 check E1M[3?] (got 107% pickups - could be 19.2 again?)
// 20. bundle, release, make video

// notes for video
// don't go finding secrets or pickups
// show enemies, weapons
// key/door/barrel
// map (scroll and zoom)
// should probably cut together all music/enemies/pickups/weapons

// memory map:
// see the .cfg file for how to do this
// startup code is $82 bytes long - fix with fill = yes
// 0100-0190 code under ASM stack
// 0400-0FFF look up tables and code
// 1000-11FF screen
// 1200-13FF startup + random data
// 1400-15FF character font
// 1600-17FF 8x8 bitmapped display character ram
// 1800-76FF code/data
// 7700-77FF C stack
// 7800-7FFF fast multiply tables
// A000-BDFF texture data, level data, music, sound
// BE00-BFFF back buffer

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <dbg.h>
#include <cbm.h>

#include "core_math.h"
#include "core_system.h"
#include "display_properties.h"
#include "display_screen.h"
#include "display_geometry.h"
#include "playSound.h"
#include "mapAsm.h"
#include "drawColumn.h"
#include "automap.h"
#include "p_enemy.h"
#include "util.h"
#include "summary.h"
#include "victory.h"
#include "enemy.h"

#pragma staticlocals(on)

unsigned char __fastcall__ testFilled(signed char col);


void __fastcall__ setCameraAngle(unsigned char a);
void __fastcall__ setCameraX(int x);
void __fastcall__ setCameraY(int y);

char P_Random(void);

// these get the player sin/cos
signed char __fastcall__ get_sin(void);
signed char __fastcall__ get_cos(void);

char *pickupNames[] =
{
  "security armor!",
  "combat armor!",
  "ammo!",
  "medikit!",
  "red keycard!",
  "green keycard!",
  "blue keycard!",
  "", "", "", "",
  "chainsaw!",
  "shotgun!",
  "chaingun!"
};

char *weaponNames[] =
{
  "fist",
  "chainsaw",
  "pistol",
  "shotgun",
  "chaingun"
};

char *caLevelNames[10] =
{
  "",
  "hangar",
  "nuclear plant",
  "toxin refinery",
  "command control",
  "phobos lab",
  "central processing",
  "computer station",
  "phobos anomaly",
  "military base"
};

int playerx;
int playery;
char playera;
char playerSector;

int playeroldx;
int playeroldy;

// a render problem (e1m1):
//int playerx = 13*256 + 109;
//int playery = 34*256 + 240;
//char playera = 10;
//char playerSector = 8;

char shells;
char bullets;
char weapons[5];
char weapon;
char armor;
char combatArmor;
signed char health = 0;

char endLevel;
char level;
char clev = 0;

// TODO : signed char distAtCenterOfView
char typeAtCenterOfView;
char itemAtCenterOfView;

unsigned char openDoors[4];
char doorOpenTime[4];
char numOpenDoors = 0;

char eraseMessageAfter = 0;


char frame = 0;

char flashBorderTime = 0;

char *keyCardNames[3] = { " red", "green", "blue" };

extern char difficulty;

char godMode = 0;

void __fastcall__ damagePlayer(char damage)
{
  if (!godMode)
  {
    if (difficulty == 0)
    {
      // approximation for /3
      damage = damage/4 + damage/16;
    }
    else if (difficulty == 1)
    {
      damage = damage/2;
    }
    if (armor > 0)
    {
      char armorDamage = 0;
      if (combatArmor == 1)
      {
        armorDamage = damage/2;
      }
      else
      {
        // approximation for /3
        armorDamage = damage/4 + damage/16;
      }
      damage = damage - armorDamage;
      armor -= armorDamage;
      if (armor > 200)
      {
        armor = 0;
        combatArmor = 0;
      }
      drawHudArmor();
    }
    health -= damage;
    if (health < 0)
    {
       health = 0;
    }
    drawHudHealth();
  
    // flash border red
    flashBorderTime = 1;
    bordercolor(COLOR_RED);
  }
}

char numItemsGot;

char __fastcall__ getItemPercentage(void)
{
  return (100*numItemsGot)/getNumItems();
}

char acidBurn = 0;
void __fastcall__ updateAcid(void)
{
  char o, d;
  int dx, dy;

  if (acidBurn > 0)
  {
    --acidBurn;
  }
  if (acidBurn == 0)
  {
    acidBurn = 4;
    for (o = getFirstObjectInSector(playerSector); o != 0xff; o = getNextObjectInSector(o))
    {
      if (getObjectType(o) == kOT_Acid)
      {
        dx = getObjectX(o) - playerx;
        dy = getObjectY(o) - playery;

        d = P_ApproxDistance(dx, dy);

        if (d < 3)
        {
          playSound(SOUND_OOF);
          damagePlayer(1 + (P_Random()&7));
          break;
        }
      }
    }
  }
}



void __fastcall__ openDoor(char edgeGlobalIndex)
{
    char i;
    if (isDoorClosed(edgeGlobalIndex))
    {
        for (i = 0; i != 4; ++i)
        {
          if (doorOpenTime[i] == 0)
          {
              openDoors[i] = edgeGlobalIndex;
              doorOpenTime[i] = 30;
              break;
          }
        }
        basicOpenDoor(edgeGlobalIndex);
        playSound(SOUND_DOROPN);
    }
}

void __fastcall__ doEdgeSpecial(char edgeGlobalIndex)
{
    char textureIndex = getEdgeTexture(edgeGlobalIndex);
    char type = textureIndex & EDGE_TYPE_MASK;
    if (type == EDGE_TYPE_SWITCH)
    {
      char prop = (textureIndex & EDGE_PROP_MASK) >> EDGE_PROP_SHIFT;
      if (prop == SWITCH_TYPE_ENDLEVEL)
      {
        playSound(SOUND_PISTOL);
        endLevel = 1;
      }
      else if (prop == SWITCH_TYPE_OPENDOOR)
      {
        // arranged so that the door to open is the next edge in the global list
        openDoor(edgeGlobalIndex + 1);
      }
      else if (prop == SWITCH_TYPE_OPENDOORP)
      {
        openDoor(edgeGlobalIndex - 1);
      }
      else if (prop == SWITCH_TYPE_REMOVEDOOR)
      {
        ++edgeGlobalIndex;
        if (isDoorClosed(edgeGlobalIndex))
        {
          playSound(SOUND_DOROPN);
          basicOpenDoor(edgeGlobalIndex);
        }
      }
    }
}

// THIS IS THE NEXT TARGET OF FIXING & OPTIMIZATION!

signed char curSector;
signed char thatSector;
signed char nextSector;

char ni;
signed char v1x, v1y, v2x, v2y, ex, ey;
long px, py;
long height;
long edgeLen;
long edgeLen2;
long dist;
long distanceToPush;
char edgeGlobalIndex;
char vertGlobalIndex, vert2GlobalIndex;
char dgz, dle;
char reversedEdge;

// EPushOutResult enums
#define kPOR_Nada 0
#define kPOR_Wall 1
#define kPOR_Sector 2
#define EPushOutResult char

char totalCheckedEdges;

#define INNERCOLLISIONRADIUS 512
#define OUTERCOLLISIONRADIUS 528
#define COLLISIONDELTA (OUTERCOLLISIONRADIUS - INNERCOLLISIONRADIUS)

EPushOutResult __fastcall__ push_out_from_edge(char i)
{
  ++totalCheckedEdges;

  ni = getNextEdge(curSector, i);
  vertGlobalIndex = getVertexIndex(curSector, i);
  vert2GlobalIndex = getVertexIndex(curSector, ni);

  reversedEdge = 0;
  if (vertGlobalIndex > vert2GlobalIndex)
  {
    edgeGlobalIndex = vertGlobalIndex;
    vertGlobalIndex = vert2GlobalIndex;
    vert2GlobalIndex = edgeGlobalIndex;
    reversedEdge = 1;
  }

  v1x = getVertexX(vertGlobalIndex);
  v1y = getVertexY(vertGlobalIndex);
  v2x = getVertexX(vert2GlobalIndex);
  v2y = getVertexY(vert2GlobalIndex);
  ex = v2x - v1x;
  ey = v2y - v1y;
  px = playerx - (((short)v1x)<<8);
  py = playery - (((short)v1y)<<8);
  // need to precalc 65536/edge.len
  edgeGlobalIndex = getEdgeIndex(curSector, i);

  // get edge len^2 (16.0)
  fastMultiplySetup8x8(ex);
  edgeLen2 = fastMultiply8x8(ex);
  fastMultiplySetup8x8(ey);
  edgeLen2 += fastMultiply8x8(ey);
  // make it 16.8
  edgeLen2 <<= 8;

  // edgeLen is 8.4
  edgeLen = sqrt24(edgeLen2);
  // make it 8.8
  edgeLen <<= 4;

  //edgeLen = getEdgeLen(edgeGlobalIndex);

  //height = px * ey - py * ex;
  {
    long p1, p2;
    fastMultiplySetup16x8e24(ey);
    p1 = fastMultiply16x8e24(px);
    fastMultiplySetup16x8e24(ex);
    p2 = fastMultiply16x8e24(py);
    if (reversedEdge)
    {
      height = p2 - p1;
    }
    else
    {
      height = p1 - p2;
    }
  }
  // height is 16.8

  // height < INNERCOLLISIONRADIUS*edgeLen
  if (height <= 0 || height < (edgeLen<<1))
  {
    // check we're within the extents of the edge
    //dist = px * ex + py * ey;
    {
      long p1, p2;
      p2 = fastMultiply16x8e24(px);
      fastMultiplySetup16x8e24(ey);
      p1 = fastMultiply16x8e24(py);
      dist = p1 + p2;
    }
    dgz = (dist >= 0);
    dle = (dist < edgeLen2);

    if (dgz & dle)
    {
      thatSector = getOtherSector(edgeGlobalIndex, curSector);
      if (thatSector != -1 && !isDoorClosed(edgeGlobalIndex))
      {
        if (height < 0)
        {
          nextSector = thatSector;
                 
          // crossed a line, so check for special
          doEdgeSpecial(edgeGlobalIndex);
        }
        return kPOR_Sector;
      }
      else
      {
        // try just pushing out
        //distanceToPush = OUTERCOLLISIONRADIUS*edgeLen - height;
        // distanceToPush is X.8
        distanceToPush = (edgeLen<<1) + (edgeLen>>4) - height;
        //fastMultiplySetup16x8e24(edgeLen);
        //distanceToPush = fastMultiply16x8e24(OUTERCOLLISIONRADIUS) - height;
        if (reversedEdge)
        {
          ex = -ex;
          ey = -ey;
        }
        //playerx += distanceToPush * ey / (edgeLen*edgeLen);
        //playery -= distanceToPush * ex / (edgeLen*edgeLen);
        {
          //int edgeLen2;
          //fastMultiplySetup8x8(edgeLen);
          //edgeLen2 = fastMultiply8x8(edgeLen);
          // need a X.8 value on the right
          edgeLen2 >>= 8;
          fastMultiplySetup16x8e24(ey);
          playerx += fastMultiply16x8e24(distanceToPush) / edgeLen2;
          fastMultiplySetup16x8e24(ex);
          playery -= fastMultiply16x8e24(distanceToPush) / edgeLen2;
        }
        return kPOR_Wall;
      }
    }
    else
    {
      char checkVert = 0;
      // if (!dgz && (dist > -INNERCOLLISIONRADIUS*edgeLen))
      //if (!dgz && ((dist>>9) > -edgeLen))
      if (!dgz && dist > -(edgeLen<<1))
      {
        checkVert = 1;
      }
      else
      {
        if (!dle)
        {
          //if (dist < (256*edgeLen + INNERCOLLISIONRADIUS)*edgeLen))
          // if (dist < (edgeLen+2)*edgeLen)
          long lim = edgeLen2 + (edgeLen<<1);
          //int paddedEdgeLen = ((int)(edgeLen+2))<<8;
          //fastMultiplySetup16x8e24(edgeLen);
          //if (dist < fastMultiply16x8e24(paddedEdgeLen))
          if (dist < lim)
          {
            checkVert = 1;
            // check the far end
            px = playerx - (((int)v2x)<<8);
            py = playery - (((int)v2y)<<8);
          }
        }
      }
      if (checkVert)
      {
        height = px * px + py * py;
        //if (height < INNERCOLLISIONRADIUS*INNERCOLLISIONRADIUS)
        if ((height&0xfffc0000) == 0)
        {
          height = sqrt24(height);
          distanceToPush = OUTERCOLLISIONRADIUS - height;
          playerx += distanceToPush * px / height;
          playery += distanceToPush * py / height;
          return kPOR_Wall;
        }
      }
    }
  }
  return kPOR_Nada;
}

int getPlayerX(void)
{
  return playerx;
}

int getPlayerY(void)
{
  return playery;
}

char getCurSector(void)
{
  return curSector;
}

char __fastcall__ playerOverlapsEdge(char i);

char oldPlayerInFrontOfEdge(char i)
{
  signed char ppx, ppy;
  int pxey, pyex;
  ni = getNextEdge(curSector, i);
  vertGlobalIndex = getVertexIndex(curSector, i);
  vert2GlobalIndex = getVertexIndex(curSector, ni);
  v1x = getVertexX(vertGlobalIndex);
  v1y = getVertexY(vertGlobalIndex);
  ex = getVertexX(vert2GlobalIndex) - v1x;
  ey = getVertexY(vert2GlobalIndex) - v1y;

  ppx = ((playeroldx + 127)>>8) - v1x;
  ppy = ((playeroldy + 127)>>8) - v1y;

  //height = px * ey - py * ex;
  fastMultiplySetup8x8(ppx);
  pxey = fastMultiply8x8(ey);
  fastMultiplySetup8x8(ppy);
  pyex = fastMultiply8x8(ex);

  return pxey >= pyex;
}

char sectorsToCheck[8];
char numSectorsToCheck;

char sectorStack[8];
char sectorStackTop;

char wallsToCheck_Sector[16];
char wallsToCheck_Edge[16];
char wallsToCheck_Checked[16];
char numWallsToCheck;

char crossablesToCheck_Sector[8];
char crossablesToCheck_Edge[8];
char numCrossablesToCheck;

void push_out(void)
{
  char h, i, j, k, secNumVerts;
  EPushOutResult r;
  char numPushedOutFrom = 0;
  // here's the new plan
  // collect up the edges we're overlapping (bbox) (and that are facing the player's old position)
  // push out in turn from each
  // once we push out from one, remove it from the list and recheck the rest
  // then check the crossable edges

  totalCheckedEdges = 0;

  // collect edges
  sectorsToCheck[0] = playerSector;
  numSectorsToCheck = 1;

  sectorStack[0] = playerSector;
  sectorStackTop = 1;

  numWallsToCheck = 0;
  numCrossablesToCheck = 0;

  h = 1;
  while (sectorStackTop != 0)
  {
    h = 0;
    --sectorStackTop;
    curSector = sectorStack[sectorStackTop];
    secNumVerts = getNumVerts(curSector);

    for (i = 0; i < secNumVerts; ++i)
    {
      edgeGlobalIndex = getEdgeIndex(curSector, i);
      thatSector = getOtherSector(edgeGlobalIndex, curSector);
      if (thatSector != -1 && !isDoorClosed(edgeGlobalIndex))
      {
        k = 0;
        for (j = 0; j < numSectorsToCheck; ++j)
        {
          if (thatSector == sectorsToCheck[j])
          {
            k = 1;
            break;
          }
        }
        if (k == 0)
        {
          if (playerOverlapsEdge(i))
          {
            sectorStack[sectorStackTop] = thatSector;
            ++sectorStackTop;
            sectorsToCheck[numSectorsToCheck] = thatSector;
            ++numSectorsToCheck;
            crossablesToCheck_Sector[numCrossablesToCheck] = curSector;
            crossablesToCheck_Edge[numCrossablesToCheck] = i;
            ++numCrossablesToCheck;
            h = 1;
          }
        }
      }
      else
      {
        if (playerOverlapsEdge(i))
        {
          if (oldPlayerInFrontOfEdge(i))
          {
            wallsToCheck_Sector[numWallsToCheck] = curSector;
            wallsToCheck_Edge[numWallsToCheck] = i;
            wallsToCheck_Checked[numWallsToCheck] = 0;
            ++numWallsToCheck;
          }
        }
      }
    }
  }

  h = 1;
  while (h != 0)
  {
    h = 0;
    for (i = 0; i < numWallsToCheck; ++i)
    {
      if (!wallsToCheck_Checked[i])
      {
        curSector = wallsToCheck_Sector[i];
        r = push_out_from_edge(wallsToCheck_Edge[i]);
        if (r == kPOR_Wall)
        {
          wallsToCheck_Checked[i] = 1;
          ++numPushedOutFrom;
          h = 1;
          break;
        }
      }
    }
  }

  // then check crossables
  for (i = 0; i < numCrossablesToCheck; ++i)
  {
    curSector = crossablesToCheck_Sector[i];
    nextSector = -1;
    r = push_out_from_edge(crossablesToCheck_Edge[i]);
    if (nextSector != -1)
    {
      playerSector = nextSector;
    }
  }

  print3DigitNumToScreen(playerSector, 0x0400 + 40*3);
  print3DigitNumToScreen(totalCheckedEdges, 0x0400 + 40*4);
  print3DigitNumToScreen(numSectorsToCheck, 0x0400 + 40*5);
  print3DigitNumToScreen(numWallsToCheck, 0x0400 + 40*6);
  print3DigitNumToScreen(numPushedOutFrom, 0x0400 + 40*7 +1);
  print3DigitNumToScreen(numCrossablesToCheck, 0x0400 + 40*8);
}

signed char explodingBarrelsObject[4];
char explodingBarrelsTime[4];

void __fastcall__ addExplodingBarrel(char o)
{
  char i;
  setObjectType(o, kOT_ExplodingBarrel);
  for (i = 0; i < 4; ++i)
  {
    if (explodingBarrelsObject[i] == -1)
    {
      explodingBarrelsObject[i] = o;
      explodingBarrelsTime[i] = 3;
      break;
    }
  }
  playSound(SOUND_SHOTGN);
}

void updateBarrels(void)
{
  char i, t, k, d;
  signed char o;
  int dx, dy;
  for (i = 0; i < 4; ++i)
  {
    o = explodingBarrelsObject[i];
    if (o != -1)
    {
      --explodingBarrelsTime[i];
      t = explodingBarrelsTime[i];
      if (t == 2)
      {
        // damage stuff around
        for (k = 0; k < getNumObjects(); ++k)
        {
          if (getObjectSector(k) != 255)
          {
            char ot = getObjectType(k);
            if (ot < 5 || ot == kOT_Barrel)
            {
              dx = getObjectX(k) - getObjectX(o);
              dy = getObjectY(k) - getObjectY(o);

              d = P_ApproxDistance(dx, dy);

              if (d < 7)
              {
                if (ot == kOT_Barrel)
                {
                  addExplodingBarrel(k);
                }
                else
                {
                  p_enemy_damage(k, 30);
                }
              }
            }
          }
        }

        // also damage player
        dx = getObjectX(o) - playerx;
        dy = getObjectY(o) - playery;

        d = P_ApproxDistance(dx, dy);

        // be more lenient for the player
        if (d < 5)
        {
          damagePlayer(30);
        }
      }
      else if (t == 0)
      {
        setObjectSector(o, -1);
        explodingBarrelsObject[i] = -1;
      }
    }
  }
}

void preparePickupMessage(void)
{
  playSound(SOUND_ITEMUP);
  bordercolor(COLOR_CYAN);
  flashBorderTime = 1;
  eraseMessage();
  textcolor(7);
  eraseMessageAfter = 8;
}

void __fastcall__ checkSectorForPickups(char sec)
{
  char o, objectType, d;
  int dx, dy;
  for (o = getFirstObjectInSector(sec); o != 0xff; o = getNextObjectInSector(o))
  {
    objectType = getObjectType(o);
    if (isPickup(objectType))
    {
      dx = getObjectX(o) - playerx;
      dy = getObjectY(o) - playery;

      d = P_ApproxDistance(dx, dy);

      if (d < 3)
      {
        char pickupType = objectType;
        char remove = 1;
        if (objectType == kOT_PossessedCorpseWithAmmo)
        {
          setObjectType(o, kOT_PossessedCorpse);
          remove = 0;
          pickupType = kOT_Bullets;
        }
        if (objectType == kOT_Shotgun && weapons[3])
        {
          pickupType = kOT_Bullets;
        }
        if (objectType == kOT_Chaingun && weapons[4])
        {
          pickupType = kOT_Bullets;
        }

        {
          char pickedUp = 0;

          switch (pickupType)
          {
          case kOT_GreenArmor:
            if (armor < 100)
            {
              armor = 100;
              combatArmor = 0;
              pickedUp = 1;
            }
            break;
          case kOT_BlueArmor:
            if (armor < 200)
            {
              armor = 200;
              combatArmor = 1;
              pickedUp = 1;
            }
            break;
          case kOT_Bullets:
            if (weapons[3])
            {
              if (shells < 50 && (P_Random()&64))
              {
                shells += 4;
                if (shells > 50) shells = 50;
                pickedUp = 1;
              }
            }
            if (!pickedUp && bullets < 99)
            {
              bullets += 10;
              if (bullets > 99) bullets = 99;
              pickedUp = 1;
            }
            break;
          case kOT_Medkit:
            if (health < 100)
            {
              health += 25;
              if (health > 100) health = 100;
              pickedUp = 1;
            }  
            break;
          case kOT_RedKeycard:
            addKeyCard(2);
            pickedUp = 1;
            break;
          case kOT_GreenKeycard:
            addKeyCard(4);
            pickedUp = 1;
            break;
          case kOT_BlueKeycard:
            addKeyCard(8);
            pickedUp = 1;
            break;
          case kOT_Chainsaw:
            weapons[1] = 1;
            weapon = 1;
            pickedUp = 1;
            break;
          case kOT_Shotgun:
            weapons[3] = 1;
            weapon = 3;
            pickedUp = 1;
            break;
          case kOT_Chaingun:
            weapons[4] = 1;
            weapon = 4;
            pickedUp = 1;
            break;
          }
          if (pickedUp)
          {
            drawHudAmmo();
            drawHudHealth();
            drawHudArmor();

            preparePickupMessage();
            printCentered("you got the", 14);
            printCentered(pickupNames[pickupType - kOT_GreenArmor], 15);

            if (remove)
            {
              setObjectSector(o, -1);
              ++numItemsGot;
            }
            break;
          }
        }
      }
    }
  }
}

void checkForPickups(void)
{
  char i, secNumVerts;
  // just check this sector and its neighbours
  checkSectorForPickups(playerSector);
  secNumVerts = getNumVerts(playerSector);

  for (i = 0; i < secNumVerts; ++i)
  {
    char edgeGlobalIndex = getEdgeIndex(curSector, i);
    char thatSector = getOtherSector(edgeGlobalIndex, curSector);
    if (thatSector != 0xff && !isDoorClosed(edgeGlobalIndex))
    {
      checkSectorForPickups(thatSector);
    }
  }
}

char turnLeftSpeed = 0;
char turnRightSpeed = 0;
char reloadStage = 0;

void __fastcall__ setUpScreenForBitmap(void)
{
  clearScreen();
  setupBitmap(COLOR_BLUE+8); 
}

void __fastcall__ setUpScreenForMenu(void)
{
  drawBorders(32);
}

void __fastcall__ setUpScreenForGameplay(void)
{
  clearMenuArea();
  setupBitmap(COLOR_BLUE+8); 
  //POKE(0x900F, 8 + 5); // green border, and black screen
  drawBorders(29);
  // name of level
  textcolor(2);
  printCentered(caLevelNames[level], 18);
  playMapTimer();

  drawHudAmmo();
  drawHudArmor();
  drawHudHealth();
  addKeyCard(1);
  // face
  colorFace(0);
  drawFace();  
}

signed char updateCheatCodes(void);
char *cheatText[] =
{
  "degreelessness mode",
  "keys, full ammo",
  "change level",
  "reveal map",
};

void handleCheatCodes(void)
{
  signed char i = updateCheatCodes();
  if (i != -1)
  {
    preparePickupMessage();
    printCentered(cheatText[i], 15);
    if (i == 0)
    {
      health = 100;
      drawHudHealth();
      godMode = 1-godMode;
      colorFace(godMode);
    }
    else if (i == 1)
    {
      addKeyCard(2+4+8);
      weapons[0] = 1;
      weapons[1] = 1;
      weapons[2] = 1;
      weapons[3] = 1;
      weapons[4] = 1;
      bullets = 99;
      shells = 50;
      drawHudAmmo();
      armor = 200;
      drawHudArmor();
    }
    else if (i == 2)
    {
      endLevel = 1;
      do
      {
	// TODO : wait for key and read it
	//        POKE(198, 0);
        // while (PEEK(198) == 0) ;
        // level = PEEK(631) - 48;
      }
      while (level > 8);
      clev = 1;
      clearScreen();
    }
    else if (i == 3)
    {
      automap_setEdges();
    }
  }
}

char __fastcall__ runMenu(char canReturn);

char caLevel[] = "pe1m1";
char caMusic[] = "pe1m1mus";

char damageBase[15] =
{
  // easy, med, hard
  2, 2, 2, // fist
  2, 2, 2, // saw
  4, 3, 1, // pistol
  10, 8, 4, // shotgun
  2, 1, 1 // chaingun
};

char damageRand[15] =
{
  0, 0, 0,
  3, 3, 3,
  0, 1, 3,
  1, 3, 7,
  1, 1, 0
};

char reloadTimes[5] = { 3, 1, 3, 7, 1 };
char damageSounds[5] = { SOUND_PUNCH, SOUND_SAWFUL, SOUND_PISTOL, SOUND_SHOTGN, SOUND_PISTOL };

char getDamage(void)
{
  // take the high nybble, because it's more random
  char d = P_Random()>>4;
  char w = 3*weapon + difficulty;
  return damageBase[w] + (d & damageRand[w]);
}

void __fastcall__ updateWeapons(char keys)
{
  if (reloadStage != 0)
  {
    --reloadStage;
    if (reloadStage == 3)
    {
      playSound(SOUND_SGCOCK);
    }
  }
  if (!(keys & KEY_FIRE))
  {
    if (weapon == 1)
    {
      playSound(SOUND_SAWIDL);
    }
  }
  else if (reloadStage == 0)
  {
    // pressed fire
    char damage = 0;
    if (weapon == 0)
    {
      // fist
      if (testFilled(0) > 32)
      {
        damage = 1;
      }
      else
      {
        playSound(SOUND_OOF);
      }
    }
    else if (weapon == 1)
    {
      // chainsaw
      if (testFilled(0) > 32)
      {
        damage = 1;
      }
      else
      {
        playSound(SOUND_SAWFUL);
      }
    }
    else if (weapon == 3)
    {
      if (shells > 0)
      {
        --shells;
        damage = 1;
      }
      // no room for this yet
      /*
      else if (bullets > 0)
      {
        weapon = 2;
        drawHudAmmo();
      }
      */
    }
    else
    {
      if (bullets > 0)
      {
        --bullets;
        damage = 1;
      }
      // no room for this yet
      /*
      else if (weapon == 4 && shells > 0)
      {
        weapon = 3;
        drawHudAmmo();
      }
      */
    }

    reloadStage = reloadTimes[weapon];

    if (damage != 0)
    {
      drawHudAmmo();
      // POKE(0x900F, 8+1);

      playSound(damageSounds[weapon]);

      if (typeAtCenterOfView == TYPE_BARREL)
      {
        addExplodingBarrel(itemAtCenterOfView);
      }
      else if (typeAtCenterOfView == TYPE_OBJECT)
      {
        damage = getDamage();
        // shotgun: if close, boost damage
        if (weapon == 3 && testFilled(0) > 32)
        {
          damage += 4;
        }
        p_enemy_damage(itemAtCenterOfView, damage);
      }
      else if (typeAtCenterOfView == TYPE_DOOR)
      {
        char tex = getEdgeTexture(itemAtCenterOfView);
        char prop = (tex & EDGE_PROP_MASK) >> EDGE_PROP_SHIFT;
        if (prop == DOOR_TYPE_SHOT)
        {
          openDoor(itemAtCenterOfView);
        }
      }
    }
  }

  // change weapon
  // TODO : check for keypress, decode number key as weapon switch
 #if 0
  if (PEEK(198) > 0)
  {
    char w = PEEK(631) - 49;
    if (w < 4)
    {
      if (w != 0 || weapons[1])
      {
        ++w;
      }
      // switch between chainsaw and fist
      if (w < 2 && w == weapon)
      {
        w = 1 - w;
      }
      if (w != weapon && weapons[w])
      {
        preparePickupMessage();
        if (w == 3)
        {
          playSound(SOUND_SGCOCK);
        }
        printCentered(weaponNames[w], 14);
        weapon = w;
        drawHudAmmo();
      }
    }
  }
#endif
}

int main()
{
  char keys;
  char ctrlKeys;
  char i;
  int ca, sa;
  char numObj;

  bordercolor(COLOR_BLACK);
  bgcolor(COLOR_BLACK);
  
  // VIC : disable Shift-C= (toggle upper/lower case)
  // POKE(657,128);

  // VIC : install NMI handler
  install_nmi_handler();
  
  // needed for clearScreen
  load_bank(0);
  load_data_file("phicode");

  // processor port 1 :
  // bit 0 : cpu color bank
  // bit 1 : vic color bank
  // bit 2 : CHAREN : 0 vic sees char ROM; 1 vic sees RAM
  // bit 3-5 : cassette write/sense/motor
  // bit 6 : capslock
  POKE(0x01,4); // VIC, CPU both use color bank 0, custom characters 
  
  // clear screen
  clearScreen();
  cputsxy(0, 1, "R_Init: Init DOOM");
  cputsxy(0, 2, "refresh daemon...");

  load_data_file("psounds");
  load_data_file("plowcode");
  load_data_file("pstackcode");
  
  playSoundInitialize(); // takes over IRQ so now its our IRQ not kernal
  
  generateMulTab();
  load_data_file("psluts");
  load_data_file("ptextures");
    
start:
  bordercolor(COLOR_BLUE);
  playMusic("pe1m9mus");
  
  setUpScreenForBitmap();
  setUpScreenForMenu();
  
  POKE(0x01,4); // VIC, CPU both use color bank 0, custom characters 
  POKE(0xd018,25); // unshadowed : charset at $2000, screen at $0400
  POKE(0xd016,0x18); // MC mode
  POKE(0xd022,COLOR_YELLOW);
  POKE(0xd023,COLOR_ORANGE);
  
  runMenu(0);
  level = 1;
  godMode = 0;
  health = 0;

nextLevel:

  bordercolor(COLOR_GREEN);
  clearScreen();

  {
    char p = '0' + level;
    caMusic[4] = p;
    caLevel[4] = p;
  }
  textcolor(2);
  printCentered("entering", 8);
  textcolor(1);
  printCentered(caLevelNames[level], 10);
  load_data_file(caLevel);
  playMusic(caMusic);

  if (health == 0)
  {
    health = 100;
    armor = 0;
    combatArmor = 0;
    bullets = 50;
    shells = 20;
    weapons[0] = 1;
    weapons[1] = 0;
    weapons[2] = 1;
    weapons[3] = 0;
    weapons[4] = 0;
    weapon = 2;
  }
  resetKeyCard();

  setUpScreenForBitmap();
  setUpScreenForGameplay();

  numObj = getNumObjects();

  resetDoorClosedAmounts();
  doorOpenTime[0] = 0;
  doorOpenTime[1] = 0;
  doorOpenTime[2] = 0;
  doorOpenTime[3] = 0;
  
  p_enemy_resetMap();
  automap_resetEdges();
  for (i = 0; i < numObj; ++i)
  {
    if (getObjectType(i) < 5)
    {
      allocMobj(i);
    }  
  }
  
  addObjectsToSectors();
  
  resetSectorsVisited();
  
  numItemsGot = 0;
  playerx = getPlayerSpawnX();
  playery = getPlayerSpawnY();
  playeroldx = playerx;
  playeroldy = playery;
  playera = getPlayerSpawnAngle();
  playerSector = getPlayerSpawnSector();
  endLevel = 0;
  explodingBarrelsObject[0] = -1;
  explodingBarrelsObject[1] = -1;
  explodingBarrelsObject[2] = -1;
  explodingBarrelsObject[3] = -1;

  playMapTimer();
  resetMapTime();

  while (health != 0 && !endLevel)
  {
      if (!flashBorderTime)
      {
	  bordercolor(COLOR_GREEN);
      }
      if (flashBorderTime > 0)
      {
        --flashBorderTime;
      }

      updateBarrels();
      checkForPickups();

      keys = readInput();
      ctrlKeys = getControlKeys();
      
      if (ctrlKeys & KEY_ESC)
      {
        pauseMapTimer();
        setUpScreenForMenu();
        if (runMenu(1) == 1)
        {
          // reset
          level = 1;
          health = 0;
          goto nextLevel;
        }
        setUpScreenForGameplay();
      }
      else if (ctrlKeys & KEY_CTRL)
      {
        pauseMapTimer();
        automap();
        setUpScreenForGameplay();
      }

      if (keys & KEY_TURNLEFT)
      {
        turnRightSpeed = 0;
        if (turnLeftSpeed < 3)
        {
            ++turnLeftSpeed;
        }
        playera -= turnLeftSpeed;
      }
      else if (keys & KEY_TURNRIGHT)
      {
        turnLeftSpeed = 0;
        if (turnRightSpeed < 3)
        {
            ++turnRightSpeed;
        }
        playera += turnRightSpeed;
      }
      else
      {
        turnLeftSpeed = 0;
        turnRightSpeed = 0;
      }
      playera &= 63;
      setCameraAngle(playera);
      ca = ((int)get_cos())<<1;
      sa = ((int)get_sin())<<1;
      playeroldx = playerx;
      playeroldy = playery;
      if (keys & KEY_MOVELEFT)
      {
        playerx -= ca;
        playery += sa;
      }
      if (keys & KEY_MOVERIGHT)
      {
        playerx += ca;
        playery -= sa;
      }

      if (keys & KEY_FORWARD)
      {
        if (!(testFilled(0) > 32 && typeAtCenterOfView == TYPE_OBJECT))
        {
          playerx += (sa<<1);
          playery += (ca<<1);
        } 
      }
      if (keys & KEY_BACK)
      {
        playerx -= sa;
        playery -= ca;
      }

      updateWeapons(keys);

      handleCheatCodes();

      for (i = 0; i < 4; ++i)
      {
        char dot = doorOpenTime[i];
        if (dot > 0)
        {
          --dot;
          doorOpenTime[i] = dot;
          if (dot == 0)
          {
            // try to close the door - should just get pushed out, so go ahead
            basicCloseDoor(openDoors[i]);
            playSound(SOUND_DORCLS);
          }
        }
      }
          
      if (keys & KEY_USE)
      {
        // tried to open a door (pressed K)
        if (testFilled(0) > 32)
        {
            if (typeAtCenterOfView == TYPE_DOOR)
            {
              char tex = getEdgeTexture(itemAtCenterOfView);
              char prop = (tex & EDGE_PROP_MASK) >> EDGE_PROP_SHIFT;
              if (prop < 4)
              {
                if (haveKeyCard(prop))
                {
                  openDoor(itemAtCenterOfView);
                }
                else
                {
                  playSound(SOUND_OOF);
                  eraseMessage();
                  textcolor(7);
                  cputsxy(1, 16, "you need a       key");
                  cputsxy(2, 17, "to open this door!");
                  textcolor(keyCardColor(prop));
                  --prop;
                  cputsxy(12, 16, keyCardNames[prop]);
                  eraseMessageAfter = 8;
                }
              }
              else if (prop == DOOR_TYPE_ONEWAY)
              {
                char otherSec = getOtherSector(itemAtCenterOfView, playerSector);
                if (otherSec < playerSector)
                {
                  openDoor(itemAtCenterOfView);
                }
              }
            }
            else if (typeAtCenterOfView == TYPE_SWITCH)
            {
              doEdgeSpecial(itemAtCenterOfView);
            }
        }
      }

      updateAcid();

      {
        setTickCount();
        push_out();
        print2DigitNumToScreen(getTickCount(), 0x0424);
      }

      setSectorVisited(playerSector);

      setCameraX(playerx);
      setCameraY(playery);

      p_enemy_startframe();
      clearSecondBuffer();
      // draw to second buffer
      setTickCount();
      drawSpans();
      print2DigitNumToScreen(getTickCount(), 0x0400 + 40*1 + 36);
      // this takes about 30 raster lines
      copyToPrimaryBuffer();
      setTickCount();
      p_enemy_think();
      print2DigitNumToScreen(getTickCount(), 0x0400 + 40*2 + 36);
      
      ++frame;
      frame &= 7;
      
      updateFace();

      if (eraseMessageAfter != 0)
      {
        --eraseMessageAfter;
        if (!eraseMessageAfter)
        {
          eraseMessage();
        }
      }
    }
    pauseMapTimer();

    if (!clev)
    {
      textcolor(2);
      if (health == 0)
      {
        cputsxy(5, 13, "you are dead");
        cputsxy(5, 15, "press return");
      }
      else
      {
        cputsxy(5, 13, "map complete");
        playMusic("pintermus");
        ++level;
      }

      meltScreen(health);
    
      if (health != 0)
      {
        summaryScreen();
        if (level == 9)
        {
          victoryScreen();
          goto start;
        }
      }
      stopMusic();
    }
    clev = 0;
    goto nextLevel;
    
    return EXIT_SUCCESS;
}
