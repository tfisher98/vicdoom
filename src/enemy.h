void __fastcall__ setMobjIndex(char);
char __fastcall__ mobjAllocated(char);
void __fastcall__ setMobjAllocated(char);
char __fastcall__ mobjMovedir(void);
void __fastcall__ setMobjMovedir(char);
char __fastcall__ mobjFlags(void);
void __fastcall__ setMobjFlags(char);
void __fastcall__ removeMobjFlags(char);
void __fastcall__ addMobjFlags(char);
char __fastcall__ testMobjFlags(char);
char __fastcall__ mobjReactiontime(void);
void __fastcall__ setMobjReactiontime(char);
void __fastcall__ decMobjReactiontime(void);
signed char __fastcall__ mobjMovecount(void);
void __fastcall__ setMobjMovecount(char);
signed char __fastcall__ decMobjMovecount(void);
void __fastcall__ incMobjMovecount(void);
signed char __fastcall__ mobjHealth(void);
void __fastcall__ setMobjHealth(char);
char __fastcall__ mobjInfoType(void);
void __fastcall__ setMobjInfoType(char);
char __fastcall__ mobjStateIndex(void);
void __fastcall__ setMobjStateIndex(char);
char __fastcall__ mobjTimeout(void);
void __fastcall__ setMobjTimeout(char);

void __fastcall__ setMobjCurrentType(char);
char getMobjSpeed(void);
char getMobjPainChance(void);
char getMobjSpawnHealth(void);
char getMobjChaseState(void);
char getMobjPainState(void);
char getMobjMeleeState(void);
char getMobjShootState(void);
char getMobjDeathState(void);
char getMobjDeathSound(void);

char __fastcall__ texFrameTexture(char ot);
char __fastcall__ texFrameSolid(char ot);
char __fastcall__ texFrameWidthScale(char ot);
char __fastcall__ texFrameStartY(char ot);
char __fastcall__ texFrameHeight(char ot);
char __fastcall__ texFrameStartX(char ot);
char __fastcall__ texFrameWidth(char ot);
