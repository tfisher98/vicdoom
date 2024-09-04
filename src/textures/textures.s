.segment "TEXTURES"

.if .version=531

.include "PANEL.S"
.include "SEWERWALL.S"
.include "TECHWALL.S"
.include "TILE.S"
.include "GRATE.S"
.include "SWITCH.S"
.include "DOOR.S"
.include "DOORTRAK.S"

.include "POSWALK.S"  ;8
.include "POSATK.S"
.include "POSPAIN.S"
.include "IMP.S"      ;11
.include "IMPATK.S"
.include "IMPPAIN.S"
.include "DEMON.S"    ;14
.include "DEMONATK.S"
.include "DEMONPAIN.S"
.include "CACO.S"     ;17
.include "CACOPAIN.S"
.include "CACODEAD.S"
.include "CORPSES.S"  ;20

.include "TECHCOLUMN.S"    ;21
.include "ARMOR.S"
.include "ITEMS.S"
.include "BARRELSKULLS.S"
.include "BARXPLD.S"

.else
	
.include "src/textures/PANEL.S"
.include "src/textures/SEWERWALL.S"
.include "src/textures/TECHWALL.S"
.include "src/textures/TILE.S"
.include "src/textures/GRATE.S"
.include "src/textures/SWITCH.S"
.include "src/textures/DOOR.S"
.include "src/textures/DOORTRAK.S"

.include "src/textures/POSWALK.S"  ;8
.include "src/textures/POSATK.S"
.include "src/textures/POSPAIN.S"
.include "src/textures/IMP.S"      ;11
.include "src/textures/IMPATK.S"
.include "src/textures/IMPPAIN.S"
.include "src/textures/DEMON.S"    ;14
.include "src/textures/DEMONATK.S"
.include "src/textures/DEMONPAIN.S"
.include "src/textures/CACO.S"     ;17
.include "src/textures/CACOPAIN.S"
.include "src/textures/CACODEAD.S"
.include "src/textures/CORPSES.S"  ;20

.include "src/textures/TECHCOLUMN.S"    ;21
.include "src/textures/ARMOR.S"
.include "src/textures/ITEMS.S"
.include "src/textures/BARRELSKULLS.S"
.include "src/textures/BARXPLD.S"

.endif
