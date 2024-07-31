#define POKE(addr,val) ((*(unsigned char *)(addr)) = val)
#define PEEK(addr) (*(unsigned char *)(addr))

void __fastcall__ playMusic(char *name);

char __fastcall__ keyCardColor(char card);
void __fastcall__ resetKeyCard(void);
void __fastcall__ addKeyCard(char cardMask);
char __fastcall__ haveKeyCard(char card);


void __fastcall__ setObjForMobj(char obj, char mobj);
char __fastcall__ objForMobj(char mobj);
char __fastcall__ mobjForObj(char obj);

