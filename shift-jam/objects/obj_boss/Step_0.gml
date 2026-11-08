// --- entrata lenta, senza attaccare ---
if (y < target_y) { y += 1.2; exit; }
t += 1;

// --- passaggio di fase: il guscio della nave madre si rompe ---
if (phase == 1 && hp <= hp_p2) {
    phase = 2;
    audio_play_sound(snd_explosion_big, 10, false);   // il guscio salta via
    hp = hp_p2;
    radius = 28;
    hp_prev = hp;
    koi_reset();   // le carpe appaiono gia' intere attorno alla perla
    transition = 120;
    attack = 0;
    attack_timer = 120;
    hint = 360;
    gift_t = 300;   // i regali continuano (poi a tempo con le gru)
    crane_t = 90;   // il primo stormo di gru arriva 1,5 s dopo che i Koi si sono rivelati
    with (obj_shield) { global.enemy_boom(id); instance_destroy(); }   // gli scudi saltano col guscio
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

// --- REGALI: un proiettile bianco e nero, lento, verso di te. Spaccalo prima che ti tocchi:
// a rombo lascia un'arma (R, L, S a turno), rotondo lascia il cuore. Arma e cuore si alternano.
// Fase 1: mezzo secondo dopo ogni hangar (cosi' resta dietro alle Falene); fase 2: ogni 10 secondi, quando le gru se ne vanno ---
if (gift_t > 0) {
    gift_t -= 1;
    if (gift_t == 0) {
        var gy = (phase == 1) ? y + 70 : y;
        var gp = instance_create_layer(x, gy, "Instances", obj_gift);
        gp.gift = (gift_n mod 2 == 1) ? 0 : 1 + (gift_n div 2) mod 3;
        var gtx = instance_exists(obj_player) ? obj_player.x : room_width / 2;
        gp.dir = point_direction(x, gy, gtx, room_height - HUD_H - 40);
        gift_n += 1;
    }
}

if (phase == 1) {
    // ===== FASE 1: NAVE MADRE =====
    // Gli attacchi lunghi (raffiche, anelli, spirale) continuano mentre parte il successivo: si intrecciano.
    x = room_width / 2 + sin(t / 120) * 50;
    var angry1 = (hp < hp_p2 + hp_p1 / 2);   // sotto meta' guscio: piu' veloce, e i cannoni laterali tirano corde
    var ptx1 = room_width / 2, pty1 = room_height - 80;
    if (instance_exists(obj_player)) { ptx1 = obj_player.x; pty1 = obj_player.y; }

    // SCUDI: le navette con la lastra verde stanno su un arco fra te e la nave madre e si prendono i tuoi colpi.
    // Un posto rimasto vuoto si riempie dopo 4 s: dall'hangar esce una navetta nuova (sotto meta' guscio sono 5)
    // Quando apre l'hangar, gli scudi si spostano sui fianchi per 2,5 s: escono le Falene e il regalo,
    // e per un momento la nave madre e' scoperta
    shield_n = angry1 ? 5 : 4;
    if (shield_open > 0) shield_open -= 1;
    for (var sl = 0; sl < shield_n; sl++) {
        var taken = false;
        with (obj_shield) if (slot == sl) taken = true;
        if (taken) { shield_cd[sl] = 240; continue; }
        shield_cd[sl] -= 1;
        if (shield_cd[sl] <= 0) {
            var sh = instance_create_layer(x + (sl - (shield_n - 1) / 2) * 32, y + 40, "Instances", obj_shield);   // esce da sotto lo scafo
            sh.slot = sl;
            shield_cd[sl] = 240;
        }
    }

    // CANNONI: raffiche mirate a 5 colpi da sinistra e da destra, una ogni 10 fotogrammi
    if (volley_t > 0) {
        volley_t -= 1;
        if (volley_t mod 10 == 0) {
            for (var c = -1; c <= 1; c += 2) {
                var cx = x + c * 40, cy = y + 60;   // ai lati della prua
                var base = point_direction(cx, cy, ptx1, pty1);
                for (var k = -2; k <= 2; k++) global.shoot(cx, cy, base + k * 9, 2.8);
            }
        }
    }
    // SIPARIO: due ventagli verso il basso; il secondo, sfalsato di mezzo passo, chiude i buchi del primo
    if (fan_t > 0) {
        fan_t -= 1;
        if (fan_t == 30 || fan_t == 0) {
            var off = (fan_t == 0) ? 8 : 0;
            for (var k2 = -5; k2 <= 5; k2++) global.shoot(x, y + 70, 270 + k2 * 16 + off, (fan_t == 0) ? 2.5 : 2.0);
        }
    }
    // ANELLI dalla prua, sfalsati di mezzo passo: i buchi si spostano, bisogna leggerli
    if (ring_t > 0) {
        ring_t -= 1;
        if (ring_t mod 14 == 0) {
            global.shoot_ring(x, y + 50, 16, angry1 ? 1.8 : 1.6, (ring_n mod 2) * 11.25);
            ring_n += 1;
        }
    }
    // SPIRALE: tre bracci che girano dalla prua
    if (spin_t > 0) {
        spin_t -= 1;
        if (spin_t mod 6 == 0) {
            for (var a3 = 0; a3 < 3; a3++) global.shoot(x, y + 50, spin_a + a3 * 120, 1.9);
            spin_a += angry1 ? 13 : 11;
        }
    }
    // sotto meta' guscio: corde mirate dai cannoni laterali, alternate
    if (angry1) {
        rope_t -= 1;
        if (rope_t <= 0) {
            var rc = ((t div 90) mod 2 == 0) ? -1 : 1;
            global.shoot_rope(x + rc * 40, y + 60, point_direction(x + rc * 40, y + 60, ptx1, pty1), 4, 2.4);
            rope_t = 110;
        }
    }

    attack_timer -= 1;
    if (attack == 1 && attack_timer == 30) shield_open = 150;   // mezzo secondo prima dell'hangar gli scudi si scostano (e' l'avviso)
    if (attack_timer <= 0) {
        if (attack == 0) {
            volley_t = 30;                      // 3 raffiche
        } else if (attack == 1) {
            // hangar: uno sciame di Falene, e intanto una corda dalla prua
            var nm = angry1 ? 7 : 5;
            for (var q = 0; q < nm; q++) {
                var oq = q - (nm - 1) / 2;   // sempre lo stesso ventaglio, le falene vanno dritte
                var mq = instance_create_layer(x + oq * 24, y + 40 + abs(oq) * 6, "Instances", obj_moth);
                mq.dir = 270 + oq * 14;
                mq.spd = 2.2;
                mq.home_time = 0;
            }
            global.shoot_rope(x, y + 70, point_direction(x, y + 70, ptx1, pty1), 5, 2.2);
            gift_t = 30;   // dietro alle Falene parte un regalo
        } else if (attack == 2) {
            fan_t = 30;
        } else if (attack == 3) {
            ring_t = 42;                        // 3 anelli
            ring_n = 0;
        } else {
            spin_t = 90;
            spin_a = 90;   // parte sempre dallo stesso punto
        }
        attack = (attack + 1) mod 5;
        attack_timer = angry1 ? 70 : 85;
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

    // GRU DI CARTA: ogni 10 s uno stormo d'oro arriva dai due lati e fa muro sotto i Koi.
    // Arrivano in fila indiana, la piu' vicina al centro davanti (cosi' non si incrociano); sotto meta' vita sono 8 invece di 6
    if (crane_hint > 0 && hint == 0) crane_hint -= 1;   // parte dopo l'avviso sui grani d'oro
    crane_t -= 1;
    if (crane_t <= 0) {
        var cn = angry ? 8 : 6, half = cn div 2;
        for (var c2 = 0; c2 < cn; c2++) {
            var sd = (c2 < half) ? 1 : -1;
            var back = ((sd == 1) ? (half - 1 - c2) : (c2 - half)) * 28;   // le altre in fila dietro, fuori schermo
            var cr = instance_create_layer((sd == 1) ? -24 - back : room_width + 24 + back, y + 30, "Instances", obj_crane);
            cr.slot = c2;
            cr.side = sd;
        }
        crane_t = 600;
        if (crane_hint < 0) crane_hint = 300;   // la prima volta: l'avviso sul cruscotto
        gift_t = 500;   // il regalo parte quando le gru se ne sono andate (cosi' non ci passa in mezzo)
    }

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
    // la carpa d'oro arriva in fondo all'affondo e scoppia in un anello di squame
    if (lunge_t == 70) global.shoot_ring(koi_bx[1][0], koi_by[1][0], angry ? 18 : 14, 1.6, 0);
    if (lunge_t >= 120) lunge_t = 0;

    // --- SPIRALE: le carpe perdono squame (colpi magenta normali, si parano) ---
    if (spiral_t > 0) {
        spiral_t -= 1;
        if (spiral_t mod 4 == 0) {
            for (var k2 = 0; k2 < 2; k2++) {
                var sx = koi_bx[k2][6], sy = koi_by[k2][6];
                var b = instance_create_layer(sx, sy, "Instances", obj_ebullet);
                b.dir = point_direction(x, y, sx, sy) - 25;   // verso fuori, un po' di traverso: si avvolge
                b.spd = 1.8;
            }
        }
    }

    // --- PETALI: dalla perla due spirali che girano in versi opposti; si incrociano e fanno una rete ---
    if (petal_t > 0) {
        petal_t -= 1;
        if (petal_t mod (angry ? 6 : 7) == 0) {
            var ps = angry ? 1.7 : 1.5;
            global.shoot(x, y, petal_a, ps);
            global.shoot(x, y, petal_a + 180, ps);
            global.shoot(x, y, -petal_a + 90, ps);
            global.shoot(x, y, -petal_a + 270, ps);
            petal_a += 9;
        }
    }
    // --- la perla ti tira una corda ogni tanto: stare fermi non basta ---
    pearl_t -= 1;
    if (pearl_t <= 0) {
        global.shoot_rope(x, y, point_direction(x, y, ptx, pty), 3, 2.3);
        pearl_t = angry ? 60 : 90;
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
        var next_timer = angry ? 65 : 90;
        if (attack == 0) {
            spiral_t = 90;
        } else if (attack == 2) {
            lunge_t = 1;          // 30 fotogrammi di avviso d'oro, poi l'affondo
            next_timer = 135;     // aspetta che la carpa sia tornata
        } else if (attack == 3) {
            petal_t = 110;
            petal_a = 0;
        } else {
            // sceglie i grani dalla parte del giocatore, uno ogni tre
            var n = angry ? 9 : 7;
            var bstep = 360 / 108;
            var j0 = round(angle_difference(point_direction(x, y, ptx, pty), bead_angle) / bstep);
            bead_sel = [];
            for (var q2 = 0; q2 < n; q2++) {
                var jj = ((j0 + (q2 - (n - 1) / 2) * 3) mod 108 + 108) mod 108;
                if (bead_gone[jj] == 0) array_push(bead_sel, jj);
            }
            bead_t = 30;
        }
        attack = (attack + 1) mod 5;   // spirale, grani, affondo, petali, grani
        attack_timer = next_timer;
    }
}
