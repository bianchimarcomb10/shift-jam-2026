/// Esplosione: una striscia "Destruction" del pacchetto Kla'ed, disegnata un fotogramma (64x64) alla volta.
/// Questi sono i valori per le torrette (fotogrammi 4-9 della Torpedo Ship).
/// Per le navette li cambia global.enemy_boom (obj_game Create) subito dopo averla creata.
spr = spr_torpedo_boom;   // la striscia
f = 4;                    // fotogramma da cui parte
last = 10;                // quanti fotogrammi ha la striscia
sc = 0.7;                 // grandezza
rot = 0;                  // rotazione (la stessa della navetta che esplode)
depth = -5;
