/// NAVE LASER (il Bomber del pacchetto Kla'ed, grande il doppio).
/// Scende, si ferma in alto, carica e spara un RAGGIO CONTINUO rosso che attraversa tutto lo schermo.
/// Il raggio NON si para: si schiva. Brucia anche i tuoi colpi, quindi la nave si colpisce solo
/// DAI LATI (i due motori), o col mecha da vicino. Dopo due raffiche smette e se ne va.
hp = 14;
radius = 28;
sc = 2;              // grandezza: il doppio dello sprite
state = 0;           // 0 entra, 1 mira, 2 carica, 3 spara, 4 si spegne, 5 se ne va
t = 0;               // fotogrammi passati nello stato attuale
cycles = 0;          // raffiche gia' sparate
stop_y = 80;         // dove si ferma (lo cambia obj_game)
wait = 0;            // fotogrammi di attesa fuori schermo prima di entrare (lo cambia obj_game)
offs = 0;            // di quanto sta di lato rispetto a te quando mira (due navi laser = una gabbia)
open = 0;            // quanto sono aperti i motori laterali: si aprono mentre carica e spara
beam_w = 0;          // mezza larghezza del raggio (0 = spento)
flash = 0;           // lampo bianco quando viene colpita
last_hp = hp;
lspd = 0;            // velocita' di fuga

// RITIRATA: quando il tempo dell'ondata scade se ne va (la muove la Begin Step di obj_enemy)
retreat = false;
rspd = 0;
rdir = 90;
