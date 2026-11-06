/// Navicella e mecha: il mecha e' la stessa navicella ripiegata.
// scintille delle parate: una crocetta bianca che si allarga e svanisce
draw_set_colour(c_white);
for (var k = 0; k < array_length(sparks); k++) {
    var sp = sparks[k];
    var sr = 2 + (12 - sp[2]) * 0.6;
    draw_set_alpha(sp[2] / 12);
    draw_line(sp[0] - sr, sp[1], sp[0] + sr, sp[1]);
    draw_line(sp[0], sp[1] - sr, sp[0], sp[1] + sr);
}
draw_set_alpha(1);

if (invuln > 0 && (invuln div 4) mod 2 == 0) exit;   // lampeggia dopo un colpo

// --- Il mecha e' la navicella ripiegata: gli stessi pezzi, rimontati ---
// ogni pezzo: [sinistra, alto, larghezza, altezza dentro lo sprite, spostamento x, spostamento y, rotazione]
// m = 0 navicella, m = 1 mecha: i valori intermedi sono la trasformazione
var parts = [
    [9, 19, 11, 18,   2, 0,  60],   // ala sinistra -> braccio/mantello
    [29, 19, 11, 18, -2, 0, -60],   // ala destra -> braccio/mantello
    [19, 31, 5, 8,   -2, 1,   0],   // coda sinistra -> gamba
    [24, 31, 5, 8,    2, 1,   0],   // coda destra -> gamba
    [19, 19, 10, 12,  0, 0,   0],   // scafo -> busto
    [19, 10, 10, 9,   0, 3,   0]    // abitacolo -> testa
];

var m = form;
if (transform_timer > 0) {
    var tt = 1 - transform_timer / 6;      // da 0 a 1 durante i 6 frame del cambio
    m = (form == 0) ? tt : 1 - tt;
}

// --- VITA: quanto si e' mosso in questo fotogramma ---
// navicella e mecha si inclinano allo stesso modo in virata: tutto ruota attorno al centro (x, y)
var mvx = x - xprevious, mvy = y - yprevious;
tilt += (clamp(mvx, -4, 4) * 4 - tilt) * 0.2;   // si inclina in virata e torna dritto piano
var bob = dsin(current_time * 0.25);            // respiro lento, sempre
var sq = 1 - abs(tilt) / 60;                    // inclinato: si stringe come se girasse su se stesso
var rc = dcos(-tilt), rs = dsin(-tilt);         // per ruotare un punto (lx, ly) attorno a (x, y)
// punto ruotato: x + lx * rc + ly * rs , y - lx * rs + ly * rc

// scia del motore: le scintille nascono sotto il motore (che si inclina con la nave) e scivolano indietro
if (form == 0 && transform_timer == 0) {
    var tlx = random_range(-3, 3) * sq, tly = 14 + bob * 0.6;
    array_push(trail, [x + tlx * rc + tly * rs, y - tlx * rs + tly * rc, 14]);
}
gpu_set_blendmode(bm_add);
for (var q = array_length(trail) - 1; q >= 0; q--) {
    var tr = trail[q];
    tr[2] -= 1;
    tr[1] += 1.6;
    if (tr[2] <= 0) { array_delete(trail, q, 1); continue; }
    trail[q] = tr;
    draw_set_alpha(tr[2] / 14 * 0.6);
    draw_set_colour(merge_colour(make_colour_rgb(80, 160, 255), c_white, tr[2] / 14));
    draw_circle(tr[0], tr[1], 1 + tr[2] / 10, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

if (form == 0 && transform_timer == 0) {
    // navicella viva: si inclina, galleggia, la fiamma si allunga quando sale
    var fl = 1 + clamp(-mvy, -3, 4) * 0.12 + 0.08 * dsin(current_time * 2);
    var by = bob * 0.6;
    var bx0 = x + by * rs, by0 = y + by * rc;   // centro della nave, spostato dal respiro lungo il suo asse
    // la fiamma si allunga partendo dall'ugello (7 px sotto il centro), cosi' resta attaccata al motore
    var fy = 7 * (1 - fl);
    draw_sprite_ext(spr_player_flame, (current_time div 80) mod 4, bx0 + fy * rs, by0 + fy * rc, sq, fl, -tilt, c_white, 1);
    draw_sprite_ext(spr_player_engine, 0, bx0, by0, sq, 1, -tilt, c_white, 1);
    draw_sprite_ext(spr_player_ship, 0, bx0, by0, sq, 1, -tilt, c_white, 1);
} else {
    // mecha vivo: il mantello ondeggia e si apre nella falciata, tutto il corpo respira,
    // e in virata si piega come la navicella
    var flare = (sweep_anim > 0) ? sweep_anim * 3 : 0;
    var sway = 4 * dsin(current_time * 0.2);
    var ex_ang = [sway - flare, flare - sway, 0, 0, 0, 0];
    var ex_dy = [bob * 0.5, bob * 0.5, bob * 0.5, bob * 0.5, bob * 0.5, bob];
    var ms = 1 + (mech_scale - 1) * m;   // cresce mentre si ripiega: il mecha e' un po' piu' grosso
    for (var i = 0; i < array_length(parts); i++) {
        var p = parts[i];
        var hw = p[2] / 2, hh = p[3] / 2;
        // centro del pezzo, prima senza inclinazione...
        var lx = (p[0] + hw - 24 + p[4] * m) * sq * ms;
        var ly = (p[1] + hh - 24 + (p[5] + ex_dy[i]) * m) * ms;
        // ...poi ruotato attorno al centro del mecha
        var pcx = x + lx * rc + ly * rs;
        var pcy = y - lx * rs + ly * rc;
        var ang = (p[6] + ex_ang[i]) * m - tilt;
        // draw_sprite_general ruota attorno all'angolo in alto a sinistra: lo calcoliamo dal centro
        var dd = point_direction(0, 0, -hw * sq * ms, -hh * ms) + ang;
        var dl = point_distance(0, 0, hw * sq * ms, hh * ms);
        draw_sprite_general(spr_player_ship, 0, p[0], p[1], p[2], p[3],
            pcx + lengthdir_x(dl, dd), pcy + lengthdir_y(dl, dd), sq * ms, ms, ang,
            c_white, c_white, c_white, c_white, 1);
    }
}

if (form == 1 && transform_timer == 0) {
    // la falce, tenuta a destra (solo da fermo: durante la falciata c'e' la lama che ruota).
    // Anche lei si inclina col mecha: ogni punto e' ruotato attorno al centro
    if (sweep_anim == 0) {
        var ms = mech_scale;
        var fx = 13 * sq * ms;         // posizione dell'asta rispetto al centro
        var fb = bob * 0.5;
        var x1 = x + fx * rc + (10 + fb) * ms * rs,  y1 = y - fx * rs + (10 + fb) * ms * rc;    // fondo dell'asta
        var x2 = x + fx * rc + (-16 + fb) * ms * rs, y2 = y - fx * rs + (-16 + fb) * ms * rc;   // cima dell'asta
        draw_set_colour(c_black);
        draw_line_width(x1, y1, x2, y2, 3);
        draw_set_colour(make_colour_rgb(150, 170, 200));
        draw_line(x1, y1, x2, y2);
        // lama: mezzaluna AZZURRA che parte dalla cima e ricade verso l'esterno (azzurro = roba tua,
        // come i colpi parati e la scia del motore). Tre passate: alone che pulsa, contorno nero, filo acceso
        var bcol = [make_colour_rgb(40, 140, 255), c_black, make_colour_rgb(120, 235, 255)];
        var bwid = [7, 4, 2];
        for (var pass = 0; pass < 3; pass++) {
            if (pass == 0) {
                gpu_set_blendmode(bm_add);
                draw_set_alpha(0.4 + 0.15 * dsin(current_time * 0.3));
            }
            draw_set_colour(bcol[pass]);
            for (var ba = 90; ba > -20; ba -= 15) {
                var bb = max(ba - 15, -20);
                var ax = fx + lengthdir_x(11 * ms, ba), ay = (-11 + fb) * ms + lengthdir_y(5 * ms, ba);
                var cx2 = fx + lengthdir_x(11 * ms, bb), cy2 = (-11 + fb) * ms + lengthdir_y(5 * ms, bb);
                draw_line_width(x + ax * rc + ay * rs, y - ax * rs + ay * rc,
                                x + cx2 * rc + cy2 * rs, y - cx2 * rs + cy2 * rc, bwid[pass]);
            }
            if (pass == 0) {
                gpu_set_blendmode(bm_normal);
                draw_set_alpha(1);
            }
        }
    }
    if (sweep_anim > 0) {
        // la falciata: un cerchio che svanisce e una lama che ruota
        draw_set_colour(make_colour_rgb(120, 235, 255));   // dello stesso azzurro della lama
        draw_set_alpha(sweep_anim / 10);
        draw_circle(x, y, sweep_radius, true);
        var a = (10 - sweep_anim) * 36;
        draw_line_width(x, y, x + lengthdir_x(sweep_radius, a), y + lengthdir_y(sweep_radius, a), 3);
        draw_set_alpha(1);
    }
}
