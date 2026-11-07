/// Torretta della nave enorme: una rastrelliera di 3 tubi lanciasiluri. E' un nemico vero (figlio di obj_enemy).
/// Normale: si distrugge con lo sparo della navicella.
/// Corazzata (cornice grigia): lo sparo ci rimbalza e la falciata non la scalfisce.
/// La feriscono solo i suoi stessi colpi PARATI dal mecha, che tornano indietro.
ship = noone;    // la nave a cui e' agganciata (la impostano obj_bigship)
bx = 0;          // x della sua sbarra rispetto al centro della nave
oy = 0;          // fila
rack = 0;        // 0 o 1: quale meta' della sbarra
armored = false;
hp = 10;
radius = 9;
timer = 60;      // conto alla rovescia fino al prossimo colpo (piu' corto quando le altre torrette sono state distrutte)
charge = 0;      // > 0 mentre le punte dei tubi si accendono (avviso)
flash = 0;       // > 0 subito dopo un colpo rimbalzato sulla corazza
silent = false;  // true se sparisce senza esplodere (nave passata)

// RITIRATA: quando il tempo dell'ondata scade se ne va (la muove la Begin Step di obj_enemy)
retreat = false;
rspd = 0;
rdir = 90;
