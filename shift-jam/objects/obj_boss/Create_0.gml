/// Boss in due fasi.
/// Fase 1: la nave madre da guerra degli alieni. Fase 2: perso il guscio, resta il Custode.
/// E' figlio di obj_enemy: colpi, falciata e contatto funzionano come con gli altri nemici.
phase = 1;
hp_p2 = 150;              // vita del Custode
hp_p1 = 220;              // vita della nave madre
hp = hp_p1 + hp_p2;       // un solo contatore: quando scende a hp_p2 il guscio si rompe
radius = 56;              // la nave madre e' grande
target_y = 140;           // dove si ferma dopo l'entrata
t = 0;
attack = 0;
attack_timer = 90;
transition = 0;           // > 0 mentre il guscio esplode e si rivela il Custode
debris = [];
bead_angle = 0;           // rotazione della mala
hands_gap = 14;           // distanza tra le mani: si chiudono prima del colpo
stun = 0;                 // il Custode resta stordito quando un palmo respinto lo colpisce
hint = 0;                 // per quanto mostrare il suggerimento sulla parata
