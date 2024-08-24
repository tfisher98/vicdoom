// Code organization:
// display_geometry : routines related to generating the 3d first-person display
// anything that depends on SCREENWIDTH or SCREENHEIGHT should be here
// this code should NOT be aware of details like how the bitmap is represented (as chars/sprites etc)
// this code should NOT be aware of any memory oraganization details
// this code should NOT directly touch any hardware features (VIC registers, etc.)

#include "core_math.h"
#include "display_properties.h"
#include "display_geometry.h"
#include "display_screen.h"
#include "mapAsm.h"
#include "enemy.h"
#include "p_enemy.h"
#include "automap.h"

// TODO : this is in core_math.s ??! needs to be moved
char __fastcall__ getObjectTexIndex(unsigned int halfWidth, unsigned int x);

// TODO : these should be in display_blitter.h
void __fastcall__ drawColumn(char textureIndex, char texI, signed char curX, short curY, unsigned char h);
void __fastcall__ drawColumnSameY(char textureIndex, char texI, signed char curX, short curY, unsigned char h);
void __fastcall__ drawColumnTransparent(char textureIndex, char texYStart, char texYEnd, char texI, signed char curX, short curY, unsigned char h);

// TODO : these should be local to display_geometry
void __fastcall__ clearFilled(void);
char __fastcall__ testFilled(signed char col);
signed char __fastcall__ testFilledWithY(signed char col, unsigned int y);
void __fastcall__ setFilled(signed char col, unsigned int y);

void __fastcall__ preTransformSectors(void);
void __fastcall__ transformSectorToScreenSpace(char sectorIndex);

// global variables referenced here
extern char frame;
extern char playerSector;
extern char typeAtCenterOfView;
extern char itemAtCenterOfView;
extern signed char barrelAtCenterOfScreen;

// stack of spans requiring additional traversal during screen drawing
char spanStackSec[10];
signed char spanStackL[10];
signed char spanStackR[10];

// depth-sorted solid objects within sector being drawn
char objO[8];
int objX[8];
int objY[8];
char sorted[8];
char numSorted;

// transparent objects within sector being drawn
char numTransparent;
char transO[12];
int transX[12];
int transY[12];
signed char transSXL[12];
signed char transSXR[12];


#if DEBUG_SECTORLISTS
int startSectorObjsPos;
#endif

// helper math function for w = h/texFrames[objectType].widthScale;
unsigned char getWidthFromHeight(char ws, unsigned char h)
{
  switch (ws)
  {
  case 2: return h>>1;
  case 3: return (h + (h>>2))>>2;
  case 4: return h>>2;
  case 5: return (h + (h>>1))>>3;
  case 8: return h>>3;
  }
  return 0; // should not occur
}

void __fastcall__ drawWall(char sectorIndex, char curEdgeIndex, char nextEdgeIndex, signed char x_L, signed char x_R)
{
  char edgeGlobalIndex = getEdgeIndex(sectorIndex, curEdgeIndex);
  char textureIndex = getEdgeTexture(edgeGlobalIndex);
  char edgeLen = getEdgeLen(edgeGlobalIndex);

  int x1 = getTransformedX(curEdgeIndex),       y1 = getTransformedY(curEdgeIndex);
  int dx = getTransformedX(nextEdgeIndex) - x1, dy = getTransformedY(nextEdgeIndex) - y1;

  signed char x4, curX;
  int numer, denom;
  unsigned int t, texI, curY, h;
  char fit;

  if ((textureIndex & EDGE_TYPE_MASK) == EDGE_TYPE_JAMB) {
    texI = (textureIndex & EDGE_PROP_MASK) >> EDGE_PROP_SHIFT;
    textureIndex = 7;
    fit = 2;
  } else {
    textureIndex &= EDGE_TEX_MASK;
    fit = (textureIndex == 2 || textureIndex == 5 || textureIndex == 6); // techwall, switch, door
  }

  for (curX = x_L, x4 = (x_L<<1)+3; curX != x_R; ++curX, x4 += 2) {
    if (testFilled(curX) != 0x7f) continue;

    fastMultiplySetup16x8(x4);
    denom = dx - (fastMultiply16x8(dy)<<3);
    if (denom <= 0) continue;
    
    numer = (fastMultiply16x8(y1)<<3) - x1; 
    t = div88(numer, denom);
    if (t > 255) t = 255;
    
    fastMultiplySetup16x8(t>>1);
    curY = (fastMultiply16x8(dy)<<1) + y1;
    setFilled(curX, curY);
    if (curY <= 0) continue;
    
    h = div128over(curY);
    
    if (fit==0) {
      fastMultiplySetup8x8(t>>1);
      texI = (fastMultiply8x8(edgeLen)>>5) & 15;
    } else if (fit==1) { 
      texI = t >> 4;
    } 
    
    drawColumn(textureIndex, texI, curX, curY, h);      
  }
}

void __fastcall__ drawObjectInSector(char objIndex, signed char x_L, signed char x_R)
{
  int vy = objY[objIndex];
  unsigned int h = div128over(vy); // h = (SCREENHEIGHT/16) * 512 / (vy/16); 
  unsigned char hc = (h < 128) ? h : 127;

  char o = objO[objIndex];
  char objectType = getObjectType(o);
  char fliptexture = 0;
  char textureIndex;
  int sx, vx;
  signed char leftX, startX, endX, curX;
  char texI, first=1;

  unsigned char w = getWidthFromHeight(texFrameWidthScale(objectType), hc);
  if (w == 0) return;
  
  if (objectType < 5) {
    textureIndex = p_enemy_get_texture(o);
    if (textureIndex & TEX_ANIMATE) {
      textureIndex &= ~TEX_ANIMATE;
      fliptexture = frame & 2;
    }
  } else {
    textureIndex = texFrameTexture(objectType);
  }
         
  vx = objX[objIndex];
  sx = leftShift4ThenDiv(vx, vy); //sx = vx / (vy / HALFSCREENWIDTH);
  if (!(sx > -64 && sx < 64)) return; 

  leftX = startX = sx - w;
  endX = sx + w;
  
  if (startX >= x_R || endX <= x_L) return;  
  if (startX < x_L) startX = x_L;
  if (endX > x_R) endX = x_R; 

  p_enemy_wasseenthisframe(o);
  
  for (curX = startX; curX != endX; ++curX) {
    if (testFilledWithY(curX, vy) < 0) continue;	
    setFilled(curX, vy);
    
    if (curX == 0) {
      typeAtCenterOfView = TYPE_OBJECT;
      itemAtCenterOfView = o;
    }
    
    texI = getObjectTexIndex(w, curX - leftX); //texI = TEXWIDTH * (2*(curX - leftX) + 1) / (4 * w);
    if (fliptexture)
      texI = (TEXWIDTH - 1) ^ texI;
    
    if (first) {
      first = 0;
      drawColumn(textureIndex, texI, curX, vy, hc);
    } else {
      drawColumnSameY(textureIndex, texI, curX, vy, hc);
    }    
  }
}

signed char __fastcall__ drawDoor(char sectorIndex, char curEdgeIndex, char nextEdgeIndex, signed char x_L, signed char x_R)
{
  char edgeGlobalIndex = getEdgeIndex(sectorIndex, curEdgeIndex);

  if (isDoorClosed(edgeGlobalIndex)) {
    if ((x_L <= 0) && (x_R > 0) && testFilled(0) == 0x7f) {
      typeAtCenterOfView = TYPE_DOOR;
      itemAtCenterOfView = edgeGlobalIndex;
    }    
    drawWall(sectorIndex, curEdgeIndex, nextEdgeIndex, x_L, x_R);    
    return x_R;
  }
  return x_L;
}

void __fastcall__ drawObjectsInSector(char sectorIndex, signed char x_L, signed char x_R)
{
  int vx, vy;
  char o, i, j;
  char column = 3;
  numSorted = 0;

#if DEBUG_SECTORLISTS
  startSectorObjsPos += 40;
  print2DigitNumToScreen(sectorIndex, startSectorObjsPos);
#endif
  
  // loop through the objects
  for (o = getFirstObjectInSector(sectorIndex); o != 0xff; o = getNextObjectInSector(o))
  {
#if DEBUG_SECTORLISTS
    print2DigitNumToScreen(o, startSectorObjsPos + column);
    column += 3;
#endif

    // inverse transform
    vy = transformxy(getObjectX(o), getObjectY(o));
    
    if (vy > 256)
    {
      vx = transformx();
      sorted[numSorted] = numSorted;

      objO[numSorted] = o;
      objX[numSorted] = vx;
      objY[numSorted] = vy;

      ++numSorted;
    }
  }

  if (numSorted > 0)
  {
    // sort
    for (i = 0; i < numSorted - 1; ++i)
    {
        for (j = i + 1; j < numSorted; ++j)
        {
          if (objY[sorted[i]] > objY[sorted[j]])
          {
              o = sorted[j];
              sorted[j] = sorted[i];
              sorted[i] = o;
          }
        }
    }

    // draw
    for (i = 0; i < numSorted; ++i)
    {
      char type;
      char index;
      index = sorted[i];
      p_enemy_add_thinker(objO[index]);
      type = getObjectType(objO[index]);
      if (texFrameSolid(type))
      {
        drawObjectInSector(index, x_L, x_R);
      }
    }
  }
}

// find first edge in sector
signed char __fastcall__ ffeis(char curSec, signed char x_L)
{
  char i;
  char numVerts = getNumVerts(curSec);
  for (i = 0; i != numVerts; ++i)
  {
    signed char sx1, sx2;
    int ty1, ty2;
    char ni = (i + 1);
    if (ni == numVerts) ni = 0;
    sx1 = getScreenX(i);
    sx2 = getScreenX(ni);
    ty1 = getTransformedY(i);
    ty2 = getTransformedY(ni);
    if (curSec == playerSector)
    {
      // when inside the sector, adjust the edges clipping the camera plane
      // so that they are definitely facing the player
      if (sx2 > x_L) {
	if (sx1 <= x_L || (ty1 <= 0 && ty2 > 0)) 
	  return i;
      } else {
	if (sx1 <= x_L && ty1 > 0 && ty2 <= 0)
	  return i;
      }
    }
    else
    {
      if (sx1 <= x_L && sx2 > x_L && (ty1 >= 0 || ty2 >= 0))
        return i;
    }
  }
  return -1;
}

void __fastcall__ queueTransparentObjects(signed char x_L, signed char x_R)
{
  char i, type;
  for (i = 0; i < numSorted; ++i)
  {
    char objIndex = sorted[i];
    type = getObjectType(objO[objIndex]);
    if (!texFrameSolid(type))
    {
      transO[numTransparent] = objO[objIndex];
      transX[numTransparent] = objX[objIndex];
      transY[numTransparent] = objY[objIndex];
      transSXL[numTransparent] = x_L;
      transSXR[numTransparent] = x_R;
      ++numTransparent;
    }
  }
}

void processTransparentObjectAtCenterOfScreen(char o)
{
  char objectType = getObjectType(o);
  if (objectType == kOT_Barrel)
  {
    barrelAtCenterOfScreen = o;
  }
}

void __fastcall__ drawTransparentObject(char transIndex)
{
  int vy = transY[transIndex];
  unsigned int h = div128over(vy);
  unsigned char hc = (h < 128) ? h : 127;

  char o = transO[transIndex];
  char objectType = getObjectType(o);
  char textureIndex;
  int sx, vx;
  signed char leftX, startX, endX, curX, x_L, x_R;
  char texI, startY, height;
  char halfwidth=0, frameStartX=0;
  unsigned char w;

  w = getWidthFromHeight(texFrameWidthScale(objectType), hc);
  if (w == 0) return;
  
  vx = transX[transIndex];
  sx = leftShift4ThenDiv(vx, vy); //sx = vx / (vy / HALFSCREENWIDTH);

  if (!(sx > -64 && sx < 64)) return; 

  leftX = startX = sx - w;
  endX = sx + w;

  x_L = transSXL[transIndex];
  x_R = transSXR[transIndex];
  if (startX >= x_R || endX <= x_L) return;  
  if (startX < x_L) startX = x_L;
  if (endX > x_R) endX = x_R; 

  if (startX <= 0 && endX > 0 && testFilledWithY(curX, vy) >= 0) {
      processTransparentObjectAtCenterOfScreen(o);
  }
  
  textureIndex = texFrameTexture(objectType);
  startY = texFrameStartY(objectType);
  height = texFrameHeight(objectType);
  if (texFrameWidth(objectType) != 16) {
    frameStartX = texFrameStartX(objectType);
    halfwidth = 1;
  }

  for (curX = startX; curX != endX; ++curX) {
    if (testFilledWithY(curX, vy) < 0) continue;	
	  
    texI = getObjectTexIndex(w, curX - leftX); //texI = TEXWIDTH * (2*(curX - leftX) + 1) / (4 * w);
    if (halfwidth)
      texI = frameStartX + (texI>>1);
    drawColumnTransparent(textureIndex, startY, height, texI, curX, vy, hc);
  }
}

void __fastcall__ drawTransparentObjects(void)
{
  signed char i;
  barrelAtCenterOfScreen = -1;
  // draw back to front
  for (i = numTransparent-1; i != -1; --i)
  {
    drawTransparentObject(i);
  }
}

void __fastcall__ drawSpans(void)
{
  signed char stackTop;
  char sectorIndex;
  signed char x_L, x_R;
  signed char firstEdge;
  char curEdge;
  char edgeGlobalIndex;
  signed char curX;
  char nextEdge;
  signed char nextX;
  signed char thatSector;

  clearFilled();
  numTransparent = 0;
  typeAtCenterOfView = 0;

#if DEBUG_SECTORLISTS
  eraseMessage();
  startSectorObjsPos = 0x0400 + 11*40;
  print3DigitNumToScreen(getObjectX(47)>>8, 0x040A);
  print3DigitNumToScreen(getObjectY(47)>>8, 0x040E);
#endif

  stackTop = 0;
  spanStackSec[0] = playerSector;
  spanStackL[0] = -HALFSCREENWIDTH;
  spanStackR[0] = HALFSCREENWIDTH;

  preTransformSectors();

  while (stackTop != -1)
  {
     sectorIndex = spanStackSec[stackTop];
     x_L = spanStackL[stackTop];
     x_R = spanStackR[stackTop];
     --stackTop;

     // STEP 1 - draw objects belonging to this sector!
     // fill in the table of written columns as we progress
     drawObjectsInSector(sectorIndex, x_L, x_R);

     transformSectorToScreenSpace(sectorIndex);

     firstEdge = ffeis(sectorIndex, x_L);
     // didn't find a first edge - must be behind
     if (firstEdge == -1) continue;
     
     // now fill the span buffer with these edges

     curEdge = firstEdge;
     curX = x_L;
     while (curX != x_R)
     {
        // update the edge
        nextEdge = getNextEdge(sectorIndex, curEdge);
        nextX = getScreenX(nextEdge);
        if (nextX < curX || nextX > x_R) nextX = x_R;

        edgeGlobalIndex = getEdgeIndex(sectorIndex, curEdge);
        thatSector = getOtherSector(edgeGlobalIndex, sectorIndex);
        if (thatSector != -1)
        {
           if (isEdgeDoor(edgeGlobalIndex))
           {
	     automap_sawEdge(edgeGlobalIndex);
	     curX = drawDoor(sectorIndex, curEdge, nextEdge, curX, nextX);
           }
           if (curX < nextX)
           {
               // come back to this
               if (stackTop < 10)
               {
                 ++stackTop;
                 spanStackSec[stackTop] = thatSector;
                 spanStackL[stackTop] = curX;
                 spanStackR[stackTop] = nextX;
               }
               else
               {
                 print2DigitNumToScreen(thatSector, 0x0400 + 5*40);
               }
           }
        }
        else
        {
	  if (isEdgeSwitch(edgeGlobalIndex) && (curX <= 0) && (nextX > 0) && testFilled(0) == 0x7f) {
	    typeAtCenterOfView = TYPE_SWITCH;
	    itemAtCenterOfView = edgeGlobalIndex;
	  }    	  
	  automap_sawEdge(edgeGlobalIndex);
	  drawWall(sectorIndex, curEdge, nextEdge, curX, nextX);
        }
        curX = nextX;
        curEdge = nextEdge;
     }
     
     queueTransparentObjects(x_L, x_R);
  }

  drawTransparentObjects();
}
