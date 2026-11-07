if (hp < last_hp) flash = 4;
last_hp = hp;
if (flash > 0) flash -= 1;
if (retreat) exit;   // tempo dell'ondata scaduto: la ritirata la fa obj_enemy (Begin Step)
if (wait > 0) { wait -= 1; x = -100; y = -100; exit; }   // aspetta fuori schermo
if (t == 0) x = (side == 1) ? -20 : room_width + 20;
t += 1;

// attraversa lo schermo in circa 5 secondi, ondeggiando
x += side * 1.4 + dash_v;
y = base_y + 34 * dsin(t * 3);
dash_v *= 0.88;
if (dash_cd > 0) dash_cd -= 1;

// SCHIVA: un colpo della navicella le sta arrivando dritto addosso -> scarta di lato
if (dash_cd == 0 && x > 10 && x < room_width - 10) {
    var me = id;
    var threat = 0;
    with (obj_shot) {
        if (!parried && kind == 0 && abs(x - me.x) < 14 && y > me.y && y < me.y + 110) threat = (me.x >= x) ? 1 : -1;
    }
    if (threat != 0) {
        if (x < 40) threat = 1;                     // contro il bordo scarta verso il centro
        if (x > room_width - 40) threat = -1;
        dash_v = 5.5 * threat;
        dash_cd = 50;
    }
}

if ((side == 1 && x > room_width + 30) || (side == -1 && x < -30)) instance_destroy();   // scappata: niente arma
