enum EObjType
{
   kOT_Possessed,
   kOT_Imp,
   kOT_Demon,
   kOT_Cacodemon,
   kOT_Baron,
   kOT_GreenArmor,
   kOT_BlueArmor,
   kOT_Bullets,
   kOT_Medkit,
   kOT_RedKeycard,
   kOT_GreenKeycard,
   kOT_BlueKeycard,
   kOT_Barrel,
   kOT_Pillar,
   kOT_Skullpile,
   kOT_Acid,
   kOT_Chainsaw,
   kOT_Shotgun,
   kOT_Chaingun,
   kOT_PossessedCorpse,
   kOT_PossessedCorpseWithAmmo,
   kOT_ImpCorpse,
   kOT_DemonCorpse,
   kOT_CacodemonCorpse,
   kOT_BaronCorpse,
   kOT_ImpShot,
   kOT_ExplodingBarrel
};

// types used for typeAtCenterOfView
#define TYPE_DOOR 1
#define TYPE_OBJECT 2
#define TYPE_SWITCH 3

#define EDGE_TYPE_MASK 0xC0
#define EDGE_PROP_MASK 0x38
#define EDGE_TEX_MASK  0x07
#define EDGE_TYPE_SHIFT 6
#define EDGE_PROP_SHIFT 3

#define EDGE_TYPE_NORMAL 0
#define EDGE_TYPE_DOOR (1<<6)
#define EDGE_TYPE_JAMB (2<<6)
#define EDGE_TYPE_SWITCH (3<<6)

#define SWITCH_TYPE_ENDLEVEL 0
#define SWITCH_TYPE_OPENDOOR 1
#define SWITCH_TYPE_REMOVEDOOR 2
#define SWITCH_TYPE_OPENDOORP 3

#define DOOR_TYPE_SHOT 4
#define DOOR_TYPE_ONEWAY 6

char __fastcall__ getScreenX(char i);
int __fastcall__ getTransformedX(char i);
int __fastcall__ getTransformedY(char i);

char __fastcall__ getNumObjects(void);
char __fastcall__ getObjectSector(char o);
int __fastcall__ getObjectX(char o);
int __fastcall__ getObjectY(char o);
char __fastcall__ getObjectType(char o);
void __fastcall__ setObjectX(char o, int x);
void __fastcall__ setObjectY(char o, int y);
void __fastcall__ setObjectSector(char o, char sectorIndex);
void __fastcall__ setObjectType(char o, char type);

char __fastcall__ getNumVerts(char sec);
char __fastcall__ getEdgeIndex(char sec, char i);
char __fastcall__ getEdgeSector(char i);
char __fastcall__ getOtherSector(char i, char sec);
void __fastcall__ setEdgeTexture(char i, char texture);
char __fastcall__ getEdgeLen(char i);
char __fastcall__ getEdgeTexture(char i);
char __fastcall__ getNextEdge(char sec, char i);

void __fastcall__ resetDoorClosedAmounts(void);
char __fastcall__ isEdgeDoor(char i);
char __fastcall__ isEdgeSwitch(char i);
char __fastcall__ isDoorClosed(char i);
void __fastcall__ basicOpenDoor(char i);
void __fastcall__ basicCloseDoor(char i);

char __fastcall__ getNumSectors(void);
char __fastcall__ getVertexIndex(char sec, char i);
signed char __fastcall__ getVertexX(char i);
signed char __fastcall__ getVertexY(char i);

int __fastcall__ getPlayerSpawnX(void);
int __fastcall__ getPlayerSpawnY(void);
char __fastcall__ getPlayerSpawnAngle(void);
char __fastcall__ getPlayerSpawnSector(void);

void __fastcall__ addObjectsToSectors(void);
void __fastcall__ addObjectToSector(char sec, char i);
void __fastcall__ removeObjectFromSector(char i);
char __fastcall__ getFirstObjectInSector(char sec);
char __fastcall__ getNextObjectInSector(char i);

char * __fastcall__ getMapName(void);

char __fastcall__ getNumEnemies(void);
char __fastcall__ getNumItems(void);
char __fastcall__ getNumSecrets(void);
char __fastcall__ getParTime(void);

void __fastcall__ resetSectorsVisited(void);
void __fastcall__ setSectorVisited(int i);
char __fastcall__ getNumVisitedSecrets(void);

char __fastcall__ isPickup(char ot);
