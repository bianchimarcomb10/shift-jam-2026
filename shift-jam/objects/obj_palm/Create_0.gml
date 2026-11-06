/// Palmo d'oro del Custode: lento, ti insegue un poco. Lo sparo non lo ferma:
/// solo la falciata del mecha lo respinge, e respinto torna contro il boss.
/// Con bead = true e' un GRANO DELLA MALA dei Koi: piu' piccolo, toglie meno, ma ne arrivano tanti.
spd = 1.7;
radius = 10;
reflected = false;
dir = 270;
if (instance_exists(obj_player)) dir = point_direction(x, y, obj_player.x, obj_player.y);
bead = false;  // grano della mala (lo imposta obj_boss)
turn = 1.2;    // quanto gira per inseguirti (gradi per fotogramma)
dmg = 15;      // vita tolta al boss quando lo colpisce respinto
stn = 45;      // per quanto lo stordisce
