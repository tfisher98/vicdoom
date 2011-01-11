// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// $Id:$
//
// Copyright (C) 1993-1996 by id Software, Inc.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// $Log:$
//
// DESCRIPTION:
//	Enemy thinking, AI.
//	Action Pointer Functions
//	that are associated with states/frames. 
//
//-----------------------------------------------------------------------------

#include <stdlib.h>
#include <conio.h>

#include "p_enemy.h"

#include "playSound.h"
#include "p_enemy.h"
#include "player.h"
#include "mapAsm.h"
#include "util.h"

#pragma staticlocals(on)

char __fastcall__ P_ApproxDistance( int dx, int dy );

#define fixed_t int
#define boolean char
#define false 0
#define true 1

#define MELEERANGE 2

#define MF_JUSTATTACKED 1
#define MF_THOUGHTTHISFRAME 2
#define MF_WASSEENTHISFRAME 4

// states are specific to enemy types
#define STATE_POSCHASE 0
#define STATE_POSPAIN 1
#define STATE_POSSHOOT 2
#define STATE_POSFALL 3
#define STATE_IMPCHASE 4
#define STATE_IMPPAIN 5
#define STATE_IMPCLAW 6
#define STATE_IMPMISSILE 7
#define STATE_IMPFALL 8
#define STATE_IMPSHOTFLY 9

typedef struct
{
   char speed;
   char seesound;
   char activesound;
   char painsound;
   char meleesound;
   char missilesound;
   
   char spawnhealth;
   char painchance;

   char chasestate;
   char painstate;
   char meleestate;
   char shootstate;
   char deathstate;
   
   char deathObjectType;
   char dummy;
}
mobjInfo_t;

#define MOBJINFO_POSSESSED 0
#define MOBJINFO_IMP 1
#define MOBJINFO_IMPSHOT 2 // 5
#define MOBJINFO_DEMON 2
#define MOBJINFO_CACODEMON 3
#define MOBJINFO_BARON 4

// TODO: fill out
mobjInfo_t mobjinfo[] =
{
  { 3, -1, SOUND_GURGLE, SOUND_POPAIN, -1, SOUND_PISTOL, 30, 4,
    STATE_POSCHASE, STATE_POSPAIN, -1, STATE_POSSHOOT, STATE_POSFALL, kOT_PossessedCorpse },
  { 4, -1, SOUND_GURGLE, SOUND_POPAIN, SOUND_CLAW, SOUND_CLAW, 30, 4,
    STATE_IMPCHASE, STATE_IMPPAIN, STATE_IMPCLAW, STATE_IMPMISSILE, STATE_IMPFALL, kOT_ImpCorpse },
  { }
};

typedef struct
{
   char allocated;
   char mobjIndex;
   int x;
   int y;
   signed char momx;
   signed char momy;
   char sector;
   char movedir;
   char flags;
   char reactiontime;
   signed char movecount;
   signed char health;
   char infoType;
   char stateIndex;
}
mobj_t;

void __fastcall__ A_Chase(void);
void __fastcall__ A_Flinch(void);
void __fastcall__ A_Melee(void);
void __fastcall__ A_Missile(void);
void __fastcall__ A_Shoot(void);
void __fastcall__ A_Fall(void);
void __fastcall__ A_Fly(void);

// actions are global
#define ACTION_CHASE 0
#define ACTION_FLINCH 1
#define ACTION_MELEE 2
#define ACTION_SHOOT 3
#define ACTION_MISSILE 4
#define ACTION_FALL 5
#define ACTION_FLY 6

typedef struct
{
   char texture;
   char actionIndex;
}
mobjState_t;

mobjState_t states[] =
{
  { TEX_ANIMATE + 8, ACTION_CHASE },
  { 10, ACTION_FLINCH },
  { 9, ACTION_SHOOT },
  { 10, ACTION_FALL },

  { TEX_ANIMATE + 11, ACTION_CHASE },
  { 13, ACTION_FLINCH },
  { 12, ACTION_MELEE },
  { 12, ACTION_MISSILE },
  { 13, ACTION_FALL },
  
  { 0, ACTION_FLY }
};

mobj_t *actor;
mobjInfo_t *info;
mobjState_t *state;
char distanceFromPlayer;

char newChaseDirThisFrame = 0;

void __fastcall__ printAction(void)
{
   gotoxy(5,0);
   switch (state->actionIndex)
   {
   case ACTION_CHASE:
     cputs("chase. ");
     break;
   case ACTION_FLINCH:
     cputs("flinch. ");
     break;
   case ACTION_MELEE:
     cputs("melee. ");
     break;
   case ACTION_SHOOT:
     cputs("shoot. ");
     break;
   case ACTION_MISSILE:
     cputs("missile. ");
     break;
   case ACTION_FALL:
     cputs("fall. ");
     break;
 case ACTION_FLY:
     cputs("fly. ");
     break;
   }
}

void __fastcall__ callAction(void)
{
  #if 0
  printAction();
  #endif
   switch (state->actionIndex)
   {
   case ACTION_CHASE:
     A_Chase();
     break;
   case ACTION_FLINCH:
     A_Flinch();
     break;
   case ACTION_MELEE:
     A_Melee();
     break;
   case ACTION_SHOOT:
     A_Shoot();
     break;
   case ACTION_MISSILE:
     A_Missile();
     break;
   case ACTION_FALL:
     A_Fall();
     break;
   case ACTION_FLY:
     A_Fly();
     break;
   }
   #if 0
   gotoxy(0,1);
   cprintf("s %d x %d y %d. ", actor->sector, actor->x, actor->y);
   gotoxy(0,2);
   cprintf("dir %d rt %d mc %d. ", actor->movedir, actor->reactiontime, actor->movecount);
   #endif
}

char __fastcall__ getTexture(mobj_t *obj)
{
   return states[obj->stateIndex].texture;
}

char numMobj = 0;
#define MAX_MOBJ 16
#define MAX_OBJ 32

mobj_t mobjs[MAX_MOBJ];
char objForMobj[MAX_MOBJ];
char mobjForObj[MAX_OBJ];

void __fastcall__ p_enemy_resetMap(void)
{
  char i;
  for (i = 0; i < MAX_MOBJ; ++i)
  {
    mobjs[i].allocated = false;
  }
}

int allocated = 0;
char firstTime = 1;

char __fastcall__ allocMobj(char o)
{
  char i;
  mobj_t *mobj;
//  if (allocated) return -1;
//  allocated = 1;
  for (i = 0; i < MAX_MOBJ; ++i)
  {
	mobj = &mobjs[i];
    if (mobj->allocated == false)
    {
      objForMobj[i] = o;
      mobjForObj[o] = i;

      mobj->allocated = true;
      mobj->mobjIndex = i;
      mobj->x = getObjectX(o);
      mobj->y = getObjectY(o);
      mobj->momx = 0;
      mobj->momy = 0;
      mobj->sector = getObjectSector(o);
      mobj->movedir = 0;
      mobj->flags = 0;
      mobj->reactiontime = 2;
      mobj->movecount = 0;
      switch (getObjectType(o))
      {
      case 0:
        mobj->health = 20;
        mobj->infoType = 0;
        mobj->stateIndex = STATE_POSCHASE;
        break;
      case 1:
        mobj->health = 35;
        mobj->infoType = 1;
        mobj->stateIndex = STATE_IMPCHASE;
        break;
      case 2:
        mobj->health = 50;
        mobj->infoType = 0;
        mobj->stateIndex = STATE_POSCHASE;
        break;
      case 3:
        mobj->health = 100;
        mobj->infoType = 0;
        mobj->stateIndex = STATE_POSCHASE;
        break;
      case 4:
        mobj->health = 300;
        mobj->infoType = 0;
        mobj->stateIndex = STATE_POSCHASE;
        break;
      }
      return i;
    }
  }
  return -1;
}

char thinkercap;
char thinkers[MAX_MOBJ];

void __fastcall__ p_enemy_startframe(void)
{
   char i;
   for (i = 0; i < MAX_MOBJ; ++i)
   {
      mobjs[i].flags &= ~(MF_WASSEENTHISFRAME|MF_THOUGHTTHISFRAME);
   }
   thinkercap = 0;
   
   newChaseDirThisFrame = 0;
}

void __fastcall__ p_enemy_add_thinker(char o)
{
  char t = getObjectType(o);
  if (t < 5)
  {
    char i = mobjForObj[o];
    if (!(mobjs[i].flags & MF_THOUGHTTHISFRAME))
    {
      mobjs[i].flags |= MF_THOUGHTTHISFRAME;
      thinkers[thinkercap] = i;
      ++thinkercap;
    }
  }
}

void __fastcall__ p_enemy_wasseenthisframe(char o)
{
   char t = getObjectType(o);
   if (t < 5)
   {
     char i = mobjForObj[o];
     mobjs[i].flags |= MF_WASSEENTHISFRAME;
   }
}

char __fastcall__ p_enemy_get_texture(char o)
{
  char i = mobjForObj[o];
  return getTexture(&mobjs[i]);
}

void __fastcall__ P_DamageMobj(char damage);

void __fastcall__ p_enemy_damage(char o, char damage)
{
   if (getObjectType(o) < 5)
   {
     char i = mobjForObj[o];
     actor = &mobjs[i];
     info = &mobjinfo[actor->infoType];
     P_DamageMobj(damage);
   }
}

void __fastcall__ p_enemy_single_think(char mobjIndex)
{
    actor = &mobjs[mobjIndex];
    info = &mobjinfo[actor->infoType];
    state = &states[actor->stateIndex];
    distanceFromPlayer = P_ApproxDistance(playerx - actor->x, playery - actor->y);
    callAction();
}  

void __fastcall__ p_enemy_think(void)
{
  char i = 0;
  while (i < thinkercap)
  {
    char mobjIndex = thinkers[i];
    p_enemy_single_think(mobjIndex);
    ++i;
  }
  if (mobjs[MAX_MOBJ-1].allocated)
  {
    p_enemy_single_think(MAX_MOBJ-1);
  }
}

char P_Random(void);

typedef enum
{
    DI_EAST,
    DI_NORTHEAST,
    DI_NORTH,
    DI_NORTHWEST,
    DI_WEST,
    DI_SOUTHWEST,
    DI_SOUTH,
    DI_SOUTHEAST,
    DI_NODIR,
    NUMDIRS
    
} dirtype_t;


//
// P_NewChaseDir related LUT.
//
dirtype_t opposite[] =
{
  DI_WEST, DI_SOUTHWEST, DI_SOUTH, DI_SOUTHEAST,
  DI_EAST, DI_NORTHEAST, DI_NORTH, DI_NORTHWEST, DI_NODIR
};

dirtype_t diags[] =
{
    DI_NORTHWEST, DI_NORTHEAST, DI_SOUTHWEST, DI_SOUTHEAST
};



//
// ENEMY THINKING
//


//
// P_CheckSight
//
// hacked version of this for D20M
//

boolean __fastcall__ P_CheckSight(void)
{
  if (actor->sector == playerSector) return true;
  // this table will be cleared at the start of render
  // and filled in during render
  if (actor->flags & MF_WASSEENTHISFRAME) return true;
  return false;
}

void __fastcall__ S_StartSound(char sound)
{
   // just try to play it
   // will succeed or fail based on priorities
   // TODO: perhaps set a volume based on actor position?
   playSound(sound);
}

void __fastcall__ P_SetMobjState(char stateIndex)
{
  actor->stateIndex = stateIndex;
  state = &states[stateIndex];
}

void __fastcall__ P_DamageMobj(char damage)
{
	actor->health -= damage;
	if (actor->health <= 0)
	{
	    // kill actor
		actor->movecount = 2;
		P_SetMobjState(info->deathstate);
	}
	else
	{
		actor->flags |= MF_JUSTATTACKED;
		// maybe flinch, depending on threshold
		if (damage > info->painchance)
		{
		  actor->movecount = 1;
		  P_SetMobjState(info->painstate);
		}
	}
}

void __fastcall__ P_RadiusAttack(char radius)
{
   // attempt to damage the player
    if (distanceFromPlayer < radius)
    {
      damagePlayer(20);
    }
}

//
// P_CheckMeleeRange
//
boolean __fastcall__ P_CheckMeleeRange(void)
{
    if (distanceFromPlayer >= MELEERANGE)
	return false;
	
    if (! P_CheckSight() )
	return false;
							
    return true;
}

//
// P_CheckMissileRange
//
boolean __fastcall__ P_CheckMissileRange(void)
{
    char dist;

    if (! P_CheckSight() )
		return false;
	
    if (actor->reactiontime)
		return false;	// do not attack yet
		
	dist = distanceFromPlayer;
		
    if (!info->meleestate && dist >= 20)
		dist -= 20; // no melee attack, so fire more

    if (dist > 50)
		dist = 50;
		
    if ((P_Random()>>2) < dist)
		return false;

    return true;
}

#define POKE(addr,val) ((*(unsigned char *)(addr)) = val)
#define PEEK(addr) (*(unsigned char *)(addr))

//
// P_Move
// Move in the current direction,
// returns false if the move is blocked.
//

signed char __fastcall__ try_move(int trydx, int trydy)
{
  // check the edges we can cross first
  // if any of them teleport us, move
  
  char thatSector;
  char i, ni;
  signed char v1x, v1y, v2x, v2y;
  int ex, ey;
  int px, py;
  int dot;
  int height;
  int edgeLen;
  int distance;
  char edgeGlobalIndex;
  char curSector = actor->sector;
  char sectorToReturn = curSector;
  char secNumVerts = getNumVerts(curSector);
  int tx = (actor->x + trydx)/256;
  int ty = (actor->y + trydy)/256;
  
  // see which edge the new coordinate is behind
  for (i = 0; i < secNumVerts; ++i)
  {
	 ni = getNextEdge(curSector, i);
     v1x = getSectorVertexX(curSector, i);
     v1y = getSectorVertexY(curSector, i);
     v2x = getSectorVertexX(curSector, ni);
     v2y = getSectorVertexY(curSector, ni);
     ex = v2x - v1x;
     ey = v2y - v1y;
     dot = trydx*ey - trydy*ex;
     if (dot <= 0)
     {
		 px = tx - v1x;
		 py = ty - v1y;
		 edgeLen = getEdgeLen(curSector, i);
		 height = px * ey - py * ex;
		 if (height < 2*edgeLen)
		 {
			// check we're within the extents of the edge
			thatSector = getOtherSector(curSector, i);
			edgeGlobalIndex = getEdgeIndex(curSector, i);
			if (thatSector != -1)// && doorClosedAmount[edgeGlobalIndex] == 0)
			{
			   distance = px * ex + py * ey;
			   if (distance > edgeLen && distance < (edgeLen*edgeLen - edgeLen))
			   {
			   #if 0
  			   gotoxy(0,16);
			   cprintf("%d %d %d %d %d. ", curSector, distance, edgeLen, dot, height);
			   #endif
				  if (height <= 0)
				  {
				     #if 0
					 gotoxy(0,4);
					 cprintf("%d. ", thatSector);
					 #endif
					 return thatSector;
				  }
				  return curSector;
			   }
			   else
			   {
				  // hit a wall
				  sectorToReturn = -1;
			   }
			}
			else
			{
			  // hit a wall
			  sectorToReturn = -1;
			}
		 }
	  }
  }
  return sectorToReturn;
}

boolean __fastcall__ P_TryMove(fixed_t trydx, fixed_t trydy)
{
   // check the move is valid
   char nextSector = try_move(trydx, trydy);
   if (nextSector != -1)
   {
     char o = objForMobj[actor->mobjIndex];
     actor->x += trydx;
     actor->y += trydy;

     // also, copy the position to the object
     setObjectX(o, actor->x);
     setObjectY(o, actor->y);
     
     // and, update the sector!
     if (actor->sector != nextSector)
     {
         actor->sector = nextSector;
		 setObjectSector(o, nextSector);
     }
     
     return true;
   }

   return false;
}

#define MIN_SPEED 32
#define FU_45 22
signed char xspeed[8] = {MIN_SPEED,FU_45,0,-FU_45,-MIN_SPEED,-FU_45,0,FU_45};
signed char yspeed[8] = {0,FU_45,MIN_SPEED,FU_45,0,-FU_45,-MIN_SPEED,-FU_45};

boolean __fastcall__ P_Move(void)
{
    fixed_t	trydx;
    fixed_t	trydy;
    
    // warning: 'catch', 'throw', and 'try'
    // are all C++ reserved words
		
    if (actor->movedir == DI_NODIR)
	return false;

    trydx = info->speed*xspeed[actor->movedir];
    trydy = info->speed*yspeed[actor->movedir];

    return P_TryMove(trydx, trydy);
}


//
// TryWalk
// Attempts to move actor on
// in its current (obj->movedir) direction.
// If blocked by either a wall or an actor
// returns FALSE
// If move is either clear or blocked only by a door,
// returns TRUE and sets...
// If a door is in the way,
// an OpenDoor call is made to start it opening.
//
boolean __fastcall__ P_TryWalk(void)
{	
    if (!P_Move())
    {
	   return false;
    }

    actor->movecount = P_Random()&3; // was 15!
    return true;
}



#define CHASEDIST 256

void __fastcall__ P_NewChaseDir(void)
{
    fixed_t	deltax;
    fixed_t	deltay;
    
    dirtype_t	d1, d2;
    
    int		tdir;
    dirtype_t	olddir;
    
    dirtype_t	turnaround;
    
    if (newChaseDirThisFrame != 0) return;
    newChaseDirThisFrame = 1;

    olddir = actor->movedir;
    turnaround=opposite[olddir];

    deltax = playerx - actor->x;
    deltay = playery - actor->y;

    if (deltax>CHASEDIST)
	d1= DI_EAST;
    else if (deltax<-CHASEDIST)
	d1= DI_WEST;
    else
	d1=DI_NODIR;

    if (deltay<-CHASEDIST)
	d2= DI_SOUTH;
    else if (deltay>CHASEDIST)
	d2= DI_NORTH;
    else
	d2=DI_NODIR;
	
	#if 0
	gotoxy(0,12);
	cprintf("dx %d dy %d. ", deltax, deltay);
	gotoxy(0,13);
	cprintf("d1 %d d2 %d. ", d1, d2);
	#endif

    // try direct route
    if (d1 != DI_NODIR
	&& d2 != DI_NODIR)
    {
	actor->movedir = diags[((deltay<0)<<1)+(deltax>0)];
	if (actor->movedir != turnaround && P_TryWalk())
	    return;
    }

    // try other directions
    if (P_Random() > 200
	||  abs(deltay)>abs(deltax))
    {
	tdir=d1;
	d1=d2;
	d2=tdir;
    }

    if (d1==turnaround)
	d1=DI_NODIR;
    if (d2==turnaround)
	d2=DI_NODIR;
	
    if (d1!=DI_NODIR)
    {
	actor->movedir = d1;
	if (P_TryWalk())
	{
	    // either moved forward or attacked
	    return;
	}
    }

    if (d2!=DI_NODIR)
    {
	actor->movedir =d2;

	if (P_TryWalk())
	    return;
    }

    // there is no direct path to the player,
    // so pick another direction.
    if (olddir!=DI_NODIR)
    {
	actor->movedir =olddir;

	if (P_TryWalk())
	    return;
    }

    // randomly determine direction of search
    if (P_Random()&1) 	
    {
	for ( tdir=DI_EAST;
	      tdir<=DI_SOUTHEAST;
	      tdir++ )
	{
	    if (tdir!=turnaround)
	    {
		actor->movedir =tdir;
		
		if ( P_TryWalk() )
		    return;
	    }
	}
    }
    else
    {
	for ( tdir=DI_SOUTHEAST;
	      tdir != (DI_EAST-1);
	      tdir-- )
	{
	    if (tdir!=turnaround)
	    {
		actor->movedir =tdir;
		
		if ( P_TryWalk() )
		    return;
	    }
	}
    }

    if (turnaround !=  DI_NODIR)
    {
	actor->movedir =turnaround;
	if ( P_TryWalk() )
	    return;
    }

    actor->movedir = DI_NODIR;	// can not move
}


//
// ACTION ROUTINES
//


//
// A_Chase
// Actor has a melee attack,
// so it tries to close as fast as possible
//
void __fastcall__ A_Chase(void)
{
    if (actor->reactiontime)
	actor->reactiontime--;
				
    // do not attack twice in a row
    if (actor->flags & MF_JUSTATTACKED)
    {
		actor->flags &= ~MF_JUSTATTACKED;
	    P_NewChaseDir();
		return;
    }
    
    // check for melee attack
    if (info->meleestate != 0xff
		&& P_CheckMeleeRange())
    {
        actor->movecount = 0;
		P_SetMobjState(info->meleestate);
		return;
    }
    
    // check for missile attack
    if (info->shootstate != 0xff)
    {
		if (actor->movecount)
		{
			goto nomissile;
		}
		
		if (!P_CheckMissileRange())
			goto nomissile;
		
		P_SetMobjState(info->shootstate);
		actor->flags |= MF_JUSTATTACKED;
		return;
    }

    // ?
  nomissile:
    
    // chase towards player
    if (--actor->movecount < 0
		|| !P_Move())
    {
		P_NewChaseDir();
    }
    
    // make active sound
    if (info->activesound != -1
		&& P_Random() < 3)
    {
		S_StartSound(info->activesound);
    }
}

//
// A_Shoot
//
void __fastcall__ A_Shoot(void)
{
    int		damage;
    char dist = distanceFromPlayer;
	
    S_StartSound(info->missilesound);
    if (dist > 55) dist = 55;
    if ((P_Random()>>2) > dist)
    {
	    damage = ((P_Random()&3)+2)*3; // this was ((r%5)+1)*3
	    damagePlayer(damage);
	}
	actor->reactiontime = P_Random()&7;
	P_SetMobjState(info->chasestate);
}

//
// A_Missile
//
void __fastcall__ A_Missile(void)
{
	// launch a missile
	{
	  mobj_t *miss = &mobjs[MAX_MOBJ-1];
	  if (miss->allocated == false)
	  {
	    long dx = playerx - actor->x;
	    long dy = playery - actor->y;
	    int distance = sqrt(dx*dx + dy*dy)/128;
	    dx /= distance;
	    dy /= distance;

	    miss->allocated = true;
	    miss->x = actor->x;
	    miss->y = actor->y;
	    miss->momx = dx;
	    miss->momy = dy;
	    miss->sector = actor->sector;
	    miss->infoType = MOBJINFO_IMPSHOT;
	    miss->stateIndex = STATE_IMPSHOTFLY;
	    miss->mobjIndex = MAX_MOBJ-1;

#if 0
	    gotoxy(1,1);
	    cprintf("%ld %ld %d %d. \n", dx, dy, miss->momx, miss->momy);
#endif
	    objForMobj[MAX_MOBJ-1] = 31;
	    mobjForObj[31] = MAX_MOBJ-1;
	    setObjectSector(31, miss->sector);
	    setObjectX(31, miss->x);
	    setObjectY(31, miss->y);
	    setObjectType(31, kOT_ImpShot);
	  }
	}
	actor->reactiontime = P_Random()&7;
	P_SetMobjState(info->chasestate);
}

//
// A_Melee
//
void __fastcall__ A_Melee(void)
{
    if (actor->movecount == 0)
    {
		int damage = ((P_Random()&7)+1)*3;
		
		if (info->meleesound != 0xff)
			S_StartSound(info->meleesound);
		damagePlayer(damage);
		
		++actor->movecount;
    }
    else
    {
       P_SetMobjState(info->chasestate);
    }
}


void __fastcall__ A_Fall(void)
{
   if (--actor->movecount == 0)
   {
     // make the object into a static corpse
     char o = objForMobj[actor->mobjIndex];
     setObjectType(o, info->deathObjectType);
     actor->allocated = false;
   }
}

void __fastcall__ A_Flinch(void)
{
  if (--actor->movecount == 0)
  {
	P_SetMobjState(info->chasestate);
  }
}

//
// A_Fly
//

void __fastcall__ A_Fly(void)
{
   boolean die = false;
   if (distanceFromPlayer < 2)
   {
     die = true;
   }
   else
   {
	   int trydx = 4*actor->momx;
	   int trydy = 4*actor->momy;
	   if (!P_TryMove(trydx, trydy))
	   {
	      die = true;
	   }
   }
   if (die)
   {
	  char o = objForMobj[actor->mobjIndex];
	  setObjectSector(o, -1);
	  // explode
	  P_RadiusAttack(4);
	  actor->allocated = false;
   }
}
