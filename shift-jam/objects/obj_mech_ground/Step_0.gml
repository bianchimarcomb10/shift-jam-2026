if (sweep_cooldown > 0) sweep_cooldown -= 1;
if (sweep_anim > 0) sweep_anim -= 1;

var st = obj_ground.state;
var g = obj_ground;

// --- movimento (solo orizzontale): libero nei primi 10 secondi, poi ogni alieno aggrappato rallenta ---
if (st == 0 && !g.mass) {
    var clinging = 0;
    with (obj_grunt) if (clinging_now) clinging += 1;
    var spd = mech_speed;
    if (g.t > g.free_time) spd = mech_speed * max(0, 1 - clinging / 8);   // 8 aggrappati = fermo
    var mx = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
    // a terra il mecha non vola: si muove solo a destra e sinistra
    x = clamp(x + mx * spd, 24, room_width - 24);
}

// --- falciata: impossibile durante l'ondata finale ---
if (st == 0 && !g.mass && sweep_cooldown == 0 && (keyboard_check(ord("Z")) || keyboard_check(ord("J")))) {
    sweep_cooldown = 30;   // una falciata ogni mezzo secondo
    sweep_anim = 10;
    var kills = 0;
    with (obj_grunt) {
        if (point_distance(x, y, other.x, other.y) <= other.sweep_radius) {
            kills += 1;
            instance_destroy();
        }
    }
    // ogni alieno falciato fa scendere un po' la barra: resisti di piu', ma non per sempre
    obj_ground.bar = max(0, obj_ground.bar - kills * 0.004);
}

if (st == 3) {
    vy -= 0.15;   // accelera verso l'alto
    y += vy;
}
