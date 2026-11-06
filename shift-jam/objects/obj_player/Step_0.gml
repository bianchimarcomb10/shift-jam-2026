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
if (shift_flash > 0) shift_flash -= 1;

// --- Trasformazione: 0,25 s in cui non si attacca ma si puo' essere colpiti ---
if (transform_timer > 0) {
    transform_timer -= 1;
    if (transform_timer == 0) form = 1 - form;
} else if (keyboard_check_pressed(vk_shift) && switch_cooldown == 0) {
    // TRIVELLA carica: da mecha a navicella parte, cresce e vola contro il nemico
    if (form == 1 && global.has_drill && drill_charge >= 3) {
        instance_create_layer(x + 10 * mech_scale, y - 2 * mech_scale, "Instances", obj_drill_shot);
        drill_charge = 0;
    }
    shift_flash = 12;       // l'ensō azzurro del cambio (lo disegna draw_pilgrim)
    transform_timer = 6;    // 6 frame = 0,1 s: cambiare forma deve essere un riflesso, non una scelta lenta
    audio_play_sound(snd_shift, 5, false, 0.5);
    switch_cooldown = 12;   // 12 frame = 0,2 s
}

// --- Attacco (Z o J, tenendo premuto) ---
var attack = keyboard_check(ord("Z")) || keyboard_check(ord("J"));
if (attack && transform_timer == 0) {
    if (form == 0 && fire_cooldown == 0) {
        // Navicella: sparo in avanti, 10 colpi al secondo
        instance_create_layer(x, y - 12, "Instances", obj_shot);
        audio_play_sound(snd_shot, 1, false, 0.15);   // lo sparo e' continuo: molto basso
        fire_cooldown = 7;   // era 6: circa 8,5 colpi al secondo invece di 10
    }
    if (form == 1 && sweep_cooldown == 0) {
        // Mecha: falciata a 360 gradi, ogni 0,5 s.
        // Con la TRIVELLA invece colpisce e para solo DAVANTI (un cono verso l'alto), ma arriva un po' piu' lontano
        var front = global.has_drill;
        var reach = front ? sweep_radius + 16 : sweep_radius;
        var preach = front ? parry_radius + 8 : parry_radius;
        sweep_cooldown = 30;
        sweep_anim = 10;
        audio_play_sound(snd_scythe, 4, false, 0.5);
        var killed = false;
        with (obj_enemy) {
            if (object_index == obj_turret && armored) continue;   // la corazza non si taglia: va colpita coi colpi parati
            if (front && abs(angle_difference(point_direction(other.x, other.y, x, y), 90)) > 50) continue;   // trivella: solo davanti
            if (point_distance(x, y, other.x, other.y) <= reach + radius) {
                hp -= 3;
                if (hp <= 0) { killed = true; global.enemy_boom(id); instance_destroy(); }
            }
        }
        if (killed) audio_play_sound(snd_enemy_die, 3, false, 0.6);
        // PARATA: la falciata annulla tutti i proiettili nemici nel suo raggio, con una scintilla
        // e i colpi parati tornano indietro contro i nemici (al massimo 12 per falciata)
        var parried = 0;
        with (obj_ebullet) {
            if (front && abs(angle_difference(point_direction(other.x, other.y, x, y), 90)) > 55) continue;   // trivella: solo davanti
            if (point_distance(x, y, other.x, other.y) <= preach) {
                array_push(other.sparks, [x, y, 12]);
                if (parried < 12) {
                    // il colpo torna indietro: parte spinto via dal mecha (a ventaglio), poi curva verso un nemico
                    var r = instance_create_layer(x, y, "Instances", obj_shot);
                    r.parried = true;
                    r.hd = point_direction(other.x, other.y, x, y) + random_range(-25, 25);
                    r.v = random_range(2, 3.5);
                }
                if (wall) global.parry_learned = true;   // ha parato un muro: l'avviso non serve piu'
                parried += 1;
                instance_destroy();
            }
        }
        if (parried > 0) audio_play_sound(snd_parry, 7, false, 0.5);
        // PARATA: la falciata respinge i palmi d'oro del Custode
        with (obj_palm) {
            if (front && abs(angle_difference(point_direction(other.x, other.y, x, y), 90)) > 55) continue;
            if (!reflected && point_distance(x, y, other.x, other.y) <= reach + radius) {
                parried += 1;   // conta anche lui per la carica della trivella
                reflected = true;
                spd = 5;
                audio_play_sound(snd_parry, 8, false, 0.5);
            }
        }
        // TRIVELLA: ogni colpo rimandato al mittente carica; a 3 e' pronta (alone azzurro + avviso)
        if (front && parried > 0 && drill_charge < 3) {
            drill_charge = min(3, drill_charge + parried);
            if (drill_charge >= 3) audio_play_sound(snd_shift, 9, false, 0.9);
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
    with (obj_laser) {
        // il RAGGIO della nave laser: non si para, si schiva
        if (beam_w > 3 && other.y > y + 20 && abs(other.x - x) < beam_w + hr) hit = true;
    }
    with (obj_bigship) {
        // la NAVE ENORME e' fisica: scafo e torrette spente fanno male se ci vai addosso (le ali no)
        if (touches(other.x, other.y, hr)) hit = true;
    }
    with (obj_boss) {
        // i KOI sono fisici: fanno male se ci vai addosso, e soprattutto nell'affondo della carpa d'oro
        if (koi_touch(other.x, other.y, hr)) hit = true;
    }
    with (obj_enemy) {
        if (point_distance(x, y, other.x, other.y) < hr + radius) {
            hit = true;
            if (object_index == obj_moth) { global.enemy_boom(id); instance_destroy(); }
        }
    }
    if (hit) {
        drill_charge = 0;   // colpito: la serie di parate si interrompe
        global.hp -= 1;
        invuln = 60;   // 1 secondo di invulnerabilita'
        audio_play_sound(snd_hurt, 9, false);
        if (global.hp <= 0) {
            obj_game.game_over = true;
            instance_destroy();
        }
    }
}

// le scintille delle parate si spengono in 12 fotogrammi
for (var k = array_length(sparks) - 1; k >= 0; k--) {
    var sk = sparks[k];
    sk[@ 2] -= 1;
    if (sk[2] <= 0) array_delete(sparks, k, 1);
}
