void __fastcall__ waitForRaster(char count);
void __fastcall__ read_data_file(char *name, unsigned int addr, int maxSize);
void __fastcall__ load_data_file(char *fname);
void __fastcall__ load_bank(char bank);
void __fastcall__ load_file(char *fname, char fnamelen);
void __fastcall__ clear_keyboard_buffer(void);
void __fastcall__ scan_keyboard(void);
char __fastcall__ get_key_count(void);
char __fastcall__ get_key_pressed(void);
void install_nmi_handler(void);

void __fastcall__ playMusic(char *name);

char __fastcall__ readInput(void);
char __fastcall__ getControlKeys(void);

// SADWJLIK

#define KEY_S 0x01
#define KEY_A 0x02
#define KEY_D 0x04
#define KEY_W 0x08
#define KEY_J 0x10
#define KEY_L 0x20
#define KEY_I 0x40
#define KEY_K 0x80

#define KEY_FORWARD   KEY_W
#define KEY_MOVELEFT  KEY_A
#define KEY_BACK      KEY_S
#define KEY_MOVERIGHT KEY_D

#define KEY_FIRE      KEY_I
#define KEY_TURNLEFT  KEY_J
#define KEY_USE       KEY_K
#define KEY_TURNRIGHT KEY_L

#define KEY_CTRL   0x40
#define KEY_ESC    0x80 // ??0x80 on c128 for back arrow ?? 0x01 on VIC
#define KEY_RETURN 0x01 // 0x80 on VIC

