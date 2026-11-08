if (hp < last_hp) flash = 4;
last_hp = hp;
if (flash > 0) flash -= 1;
if (retreat) exit;   // tempo dell'ondata scaduto: la ritirata la fa obj_enemy (Begin Step)
if (wait > 0) { wait -= 1; x = -100; y = -100; exit; }   // aspetta fuori schermo
if (t == 0) x = (side == 1) ? -20 : room_width + 20;
t += 1;

// attraversa lo schermo in circa 7 secondi, ondeggiando poco (niente schivate: Chelios le trovava goffe)
x += side * 1.0;
y = base_y + 20 * dsin(t * 3);

if ((side == 1 && x > room_width + 30) || (side == -1 && x < -30)) instance_destroy();   // scappata: niente arma
