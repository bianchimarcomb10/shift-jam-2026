// --- entrata lenta, senza attaccare ---
if (y < target_y) { y += 1.2; exit; }
t += 1;

// --- passaggio di fase: il guscio della nave madre si rompe ---
if (phase == 1 && hp <= hp_p2) {
    phase = 2;
    audio_play_sound(snd_explosion_big, 10, false);   // il guscio salta via
    music_play("mus_boss2", true, 1500);   // seconda musica per i Koi (se il file c'e')
    hp = hp_p2;
    radius = 28;
    hp_prev = hp;
    koi_reset();   // le carpe appaiono gia' intere attorno alla perla
    transition = 120;
    attack = 0;
    attack_timer = 120;
    hint = 360;
    with (obj_ebullet) instance_destroy();
    debris = [];
    for (var i = 0; i < 24; i++) {
        var da = random(360);
        var ds = random_range(1, 4);
        debris[i] = [x + random_range(-60, 60), y + random_range(-20, 20), lengthdir_x(ds, da), lengthdir_y(ds, da), random_range(4, 12)];
    }
}
if (transition > 0) {
    transition -= 1;
    hp = hp_p2;   // invulnerabile mentre si rivela
    for (var i2 = 0; i2 < array_length(debris); i2++) {
        debris[i2][0] += debris[i2][2];
        debris[i2][1] += debris[i2][3];
    }
    exit;
}
if (hint > 0) hint -= 1;
if (stun > 0) { stun -= 1; exit; }

if (phase == 1) {
    // ===== FASE 1: NAVE MADRE =====
    x = room_width / 2 + sin(t / 120) * 50;
    attack_timer -= 1;
    if (attack_timer <= 0) {
        if (attack == 0) {
            // cannoni laterali: raffica mirata da sinistra e da destra
            if (instance_exists(obj_player)) {
                for (var c = -1; c <= 1; c += 2) {
                    var cx = x + c * 40;   // ai lati della prua
                    var cy = y + 60;
                    var base = point_direction(cx, cy, obj_player.x, obj_player.y);
                    for (var k = -1; k <= 1; k++) {
                        var b1 = instance_create_layer(cx, cy, "Instances", obj_ebullet);
                        b1.dir = base + k * 8;
                        b1.spd = 2.8;
                    }
                }
            }
        } else if (attack == 1) {
            // hangar: lancia uno sciame di Falene
            repeat (5) instance_create_layer(x + random_range(-30, 30), y + 30, "Instances", obj_moth);
        } else {
            // ventaglio verso il basso
            for (var k2 = -4; k2 <= 4; k2++) {
                var b2 = instance_create_layer(x, y + 70, "Instances", obj_ebullet);
                b2.dir = 270 + k2 * 14;
                b2.spd = 2.2;
            }
        }
        attack = (attack + 1) mod 3;
        attack_timer = 80;
    }
} else {
    // ===== FASE 2: I KOI DELL'ENSŌ =====
    bead_angle += 0.4;
    enso_rot += 1.2;                          // l'ensō gira
    x = room_width / 2 + sin(t / 80) * 70;
    var angry = (hp < hp_p2 / 2);             // sotto meta' vita: piu' veloce e piu' fitto
    if (hp < hp_prev) pearl_flash = 4;        // colpito: la perla lampeggia
    hp_prev = hp;
    if (pearl_flash > 0) pearl_flash -= 1;
    for (var j = 0; j < 108; j++) if (bead_gone[j] > 0) bead_gone[j] -= 1;   // i grani lanciati ricrescono

    // dove mira l'affondo: il giocatore (o il fondo dello schermo se non c'e')
    var ptx = room_width / 2, pty = room_height - 80;
    if (instance_exists(obj_player)) { ptx = obj_player.x; pty = obj_player.y; }

    // --- le carpe nuotano in cerchio; la carpa d'oro (la seconda) a volte si lancia ---
    if (lunge_t > 0) lunge_t += 1;
    for (var k = 0; k < 2; k++) {
        koi_ang[k] += angry ? 1.9 : 1.4;
        var hx = x + lengthdir_x(koi_orb, koi_ang[k]);
        var hy = y + lengthdir_y(koi_orb * 0.92, koi_ang[k]);
        if (k == 1 && lunge_t > 0) {
            if (lunge_t == 30) {
                // fine dell'avviso: prende la mira su dove sei adesso
                l_x0 = hx; l_y0 = hy;
                l_tx = ptx; l_ty = min(pty, room_height - 40);
            }
            if (lunge_t > 30 && lunge_t <= 70) {
                // andata: scende verso il punto mirato
                var u = (lunge_t - 30) / 40; u = u * u * (3 - 2 * u);
                var cx = l_x0, cy = l_y0 + 100;
                hx = sqr(1 - u) * l_x0 + 2 * (1 - u) * u * cx + u * u * l_tx;
                hy = sqr(1 - u) * l_y0 + 2 * (1 - u) * u * cy + u * u * l_ty;
            } else if (lunge_t > 70) {
                // ritorno: curva larga e rientra nel giro
                var u2 = (lunge_t - 70) / 50; u2 = u2 * u2 * (3 - 2 * u2);
                var cx2 = lerp(l_tx, hx, 0.5) + ((l_tx < x) ? -60 : 60), cy2 = l_ty - 40;
                hx = sqr(1 - u2) * l_tx + 2 * (1 - u2) * u2 * cx2 + u2 * u2 * hx;
                hy = sqr(1 - u2) * l_ty + 2 * (1 - u2) * u2 * cy2 + u2 * u2 * hy;
            }
        }
        array_push(koi_hx[k], hx);
        array_push(koi_hy[k], hy);
        if (array_length(koi_hx[k]) > 100) { array_delete(koi_hx[k], 0, 1); array_delete(koi_hy[k], 0, 1); }
        koi_sample(k);
    }
    if (lunge_t >= 120) lunge_t = 0;

    // --- SPIRALE: le carpe perdono squame (colpi magenta normali, si parano) ---
    if (spiral_t > 0) {
        spiral_t -= 1;
        if (spiral_t mod (angry ? 4 : 6) == 0) {
            for (var k2 = 0; k2 < 2; k2++) {
                var sx = koi_bx[k2][6], sy = koi_by[k2][6];
                var b = instance_create_layer(sx, sy, "Instances", obj_ebullet);
                b.dir = point_direction(x, y, sx, sy) - 25;   // verso fuori, un po' di traverso: si avvolge
                b.spd = 1.8;
            }
        }
    }

    // --- GRANI DELLA MALA: brillano d'oro, poi partono verso di te. Si parano e tornano contro il boss ---
    if (bead_t > 0) {
        bead_t -= 1;
        if (bead_t == 0) {
            for (var q = 0; q < array_length(bead_sel); q++) {
                var bj = bead_sel[q];
                var ba = bead_angle + bj * (360 / 108);
                var p = instance_create_layer(x + lengthdir_x(70, ba), y + lengthdir_y(70, ba), "Instances", obj_palm);
                p.bead = true;
                p.radius = 6;
                p.spd = 1.9;
                p.turn = 1.0;
                p.dmg = 5;       // respinto toglie meno di un palmo...
                p.stn = 12;      // ...e stordisce poco, ma ne arrivano tanti
                p.dir = ba;      // parte verso fuori, poi ti insegue piano
                bead_gone[bj] = 300;
            }
            audio_play_sound(snd_shift, 6, false, 0.4);
        }
    }

    attack_timer -= 1;
    if (attack_timer <= 0) {
        var next_timer = angry ? 70 : 100;
        if (attack == 0) {
            spiral_t = 72;
        } else if (attack == 2) {
            lunge_t = 1;          // 30 fotogrammi di avviso d'oro, poi l'affondo
            next_timer = 135;     // aspetta che la carpa sia tornata
        } else {
            // sceglie i grani dalla parte del giocatore, uno ogni tre
            var n = angry ? 7 : 5;
            var bstep = 360 / 108;
            var j0 = round(angle_difference(point_direction(x, y, ptx, pty), bead_angle) / bstep);
            bead_sel = [];
            for (var q2 = 0; q2 < n; q2++) {
                var jj = ((j0 + (q2 - (n - 1) / 2) * 3) mod 108 + 108) mod 108;
                if (bead_gone[jj] == 0) array_push(bead_sel, jj);
            }
            bead_t = 30;
        }
        attack = (attack + 1) mod 4;
        attack_timer = next_timer;
    }
}
