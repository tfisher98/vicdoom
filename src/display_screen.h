void __fastcall__ eraseMessage(void);
void __fastcall__ meltScreen(char health);
void __fastcall__ clearScreen(void);
void __fastcall__ setupBitmap(char color);
void __fastcall__ clearMenuArea(void);
void __fastcall__ drawBorders(char c);

void __fastcall__ setTextColor(char c);
void __fastcall__ print3DigitNumToScreen(char i, int addr);
void __fastcall__ print2DigitNumToScreen(char i, int addr);
void __fastcall__ printCentered(char *str, char y);

void __fastcall__ colorFace(char godMode);
void drawFace(void);
void updateFace(void);
