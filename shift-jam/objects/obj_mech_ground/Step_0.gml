if (sweep_cooldown > 0) sweep_cooldown -= 1;
if (sweep_anim > 0) sweep_anim -= 1;
if (transformed && unfold < 1) unfold = min(1, unfold + 1 / 12);   // 12 frame per riaprirsi

var st = obj_ground.state;
var g = obj_ground;

// --- movimento in tutte le direzioni: libero nei primi 10 secondi, poi ogni alieno aggrappato rallenta ---
if (st == 0 && !g.mass) {
    var clinging = 0;
    with (obj_grunt) if (clinging_now) clinging += 1;
    var spd = mech_speed;
    if (g.t > g.free_time) spd = mech_speed * max(0, 1 - clinging / 8);   // 8 aggrappati = fermo
    var mx = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
    var my = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));
    if (mx != 0 && my != 0) { mx *= 0.707; my *= 0.707; }   // in diagonale non va piu' veloce
    x = clamp(x + mx * spd, 24, room_width - 24);
    y = clamp(y + my * spd, 40, bottom_y);
}

// --- sommerso: la marea di alieni lo schiaccia verso il fondo dello schermo ---
// cosi' la navicella, dopo l'esplosione, riparte proprio da li'
if ((st == 0 && g.mass) || st == 1) {
    y = min(bottom_y, y + 0.4 + (bottom_y - y) * 0.015);
}

// --- falciata: impossibile durante l'ondata finale ---
if (st == 0 && !g.mass && sweep_cooldown == 0 && (keyboard_check(ord("Z")) || keyboard_check(ord("J")))) {
    sweep_cooldown = 30;   // una falciata ogni mezzo secondo
    sweep_anim = 10;
    audio_play_sound(snd_scythe, 4, false);
    var kills = 0;
    with (obj_grunt) {
        if (point_distance(x, y, other.x, other.y) <= other.sweep_radius) {
            kills += 1;
            instance_destroy();
        }
    }
    if (kills > 0) audio_play_sound(snd_enemy_die, 3, false);
    // ogni alieno falciato fa scendere un po' la barra: resisti di piu', ma non per sempre
    obj_ground.bar = max(0, obj_ground.bar - kills * 0.004);
}

// --- dopo l'esplosione la navicella decolla da sola, sempre piu' veloce ---
if (st == 3) {
    vy -= 0.05;   // sale piano: attraversa lo schermo in circa 2,5 secondi
    y += vy;
}
