/// Movimento, trasformazione, attacchi, colpi subiti.

// --- Movimento (WASD o frecce) ---
var mx = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var my = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));
if (mx != 0 && my != 0) { mx *= 0.7071; my *= 0.7071; }   // in diagonale non va piu' veloce
var spd = (form == 0) ? ship_speed : mech_speed;
x = clamp(x + mx * spd, 12, room_width - 12);
y = clamp(y + my * spd, 12, room_height - 12);

// --- Timer ---
if (switch_cooldown > 0) switch_cooldown -= 1;
if (fire_cooldown > 0) fire_cooldown -= 1;
if (sweep_cooldown > 0) sweep_cooldown -= 1;
if (sweep_anim > 0) sweep_anim -= 1;
if (invuln > 0) invuln -= 1;

// --- Trasformazione: 0,25 s in cui non si attacca ma si puo' essere colpiti ---
if (transform_timer > 0) {
    transform_timer -= 1;
    if (transform_timer == 0) form = 1 - form;
} else if (keyboard_check_pressed(vk_shift) && switch_cooldown == 0) {
    transform_timer = 15;   // 15 frame = 0,25 s
    switch_cooldown = 24;   // 24 frame = 0,4 s
}

// --- Attacco (Z o J, tenendo premuto) ---
var attack = keyboard_check(ord("Z")) || keyboard_check(ord("J"));
if (attack && transform_timer == 0) {
    if (form == 0 && fire_cooldown == 0) {
        // Navicella: sparo in avanti, 10 colpi al secondo
        instance_create_layer(x, y - 12, "Instances", obj_shot);
        fire_cooldown = 6;
    }
    if (form == 1 && sweep_cooldown == 0) {
        // Mecha: falciata a 360 gradi, ogni 0,5 s
        sweep_cooldown = 30;
        sweep_anim = 10;
        with (obj_enemy) {
            if (point_distance(x, y, other.x, other.y) <= other.sweep_radius + radius) {
                hp -= 3;
                if (hp <= 0) instance_destroy();
            }
        }
        // la falciata cancella i proiettili nemici nel suo raggio
        with (obj_ebullet) {
            if (point_distance(x, y, other.x, other.y) <= other.sweep_radius) instance_destroy();
        }
        // PARATA: la falciata respinge i palmi d'oro del Custode
        with (obj_palm) {
            if (!reflected && point_distance(x, y, other.x, other.y) <= other.sweep_radius + radius) {
                reflected = true;
                spd = 5;
            }
        }
    }
}

// --- Colpi subiti ---
if (invuln == 0) {
    var hr = (form == 0) ? 6 : 10;   // hitbox: navicella piccola, mecha grande
    var hit = false;
    with (obj_ebullet) {
        if (point_distance(x, y, other.x, other.y) < hr + 3) { hit = true; instance_destroy(); }
    }
    with (obj_palm) {
        if (!reflected && point_distance(x, y, other.x, other.y) < hr + radius) { hit = true; instance_destroy(); }
    }
    with (obj_enemy) {
        if (point_distance(x, y, other.x, other.y) < hr + radius) {
            hit = true;
            if (object_index == obj_moth) instance_destroy();
        }
    }
    if (hit) {
        global.hp -= 1;
        invuln = 60;   // 1 secondo di invulnerabilita'
        if (global.hp <= 0) {
            obj_game.game_over = true;
            instance_destroy();
        }
    }
}
