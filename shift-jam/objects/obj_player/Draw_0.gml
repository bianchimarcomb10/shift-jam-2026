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

// --- VITA: quanto si e' mosso in questo fotogramma (inclina la navicella, fa camminare il mecha) ---
var mvx = x - xprevious, mvy = y - yprevious;
tilt += (clamp(mvx, -4, 4) * 4 - tilt) * 0.2;   // la navicella si inclina in virata e torna dritta piano
var bob = dsin(current_time * 0.25);            // respiro lento, sempre
var moving = (abs(mvx) + abs(mvy) > 0.1);
var walk = moving ? dsin(current_time * 0.9) : 0;   // passo del mecha

// scia del motore: scintille che si staccano e scivolano indietro
if (form == 0 && transform_timer == 0) array_push(trail, [x + random_range(-3, 3), y + 14, 14]);
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
    // navicella viva: si inclina e si stringe in virata, galleggia, la fiamma si allunga quando sale
    var sq = 1 - abs(tilt) / 60;
    var fl = 1 + clamp(-mvy, -3, 4) * 0.12 + 0.08 * dsin(current_time * 2);
    var by = y + bob * 0.6;
    draw_sprite_ext(spr_player_flame, (current_time div 80) mod 4, x, by, sq, fl, -tilt, c_white, 1);
    draw_sprite_ext(spr_player_engine, 0, x, by, sq, 1, -tilt, c_white, 1);
    draw_sprite_ext(spr_player_ship, 0, x, by, sq, 1, -tilt, c_white, 1);
} else {
    // mecha vivo: il mantello ondeggia e si apre nella falciata, le gambe fanno il passo, la testa respira
    var flare = (sweep_anim > 0) ? sweep_anim * 3 : 0;
    var sway = 4 * dsin(current_time * 0.2);
    var ex_ang = [sway - flare, flare - sway, 0, 0, 0, 0];
    var ex_dy = [bob * 0.5, bob * 0.5, walk * 1.5, -walk * 1.5, bob * 0.5, bob];
    for (var i = 0; i < array_length(parts); i++) {
        var p = parts[i];
        var hw = p[2] / 2, hh = p[3] / 2;
        var pcx = x + p[0] + hw - 24 + p[4] * m;   // centro del pezzo
        var pcy = y + p[1] + hh - 24 + (p[5] + ex_dy[i]) * m;
        var ang = (p[6] + ex_ang[i]) * m;
        // draw_sprite_general ruota attorno all'angolo in alto a sinistra: lo calcoliamo dal centro
        var dd = point_direction(0, 0, -hw, -hh) + ang;
        var dl = point_distance(0, 0, hw, hh);
        draw_sprite_general(spr_player_ship, 0, p[0], p[1], p[2], p[3],
            pcx + lengthdir_x(dl, dd), pcy + lengthdir_y(dl, dd), 1, 1, ang,
            c_white, c_white, c_white, c_white, 1);
    }
}

if (form == 1 && transform_timer == 0) {
    // la falce, tenuta a destra (solo da fermo: durante la falciata c'e' la lama che ruota)
    if (sweep_anim == 0) {
        var sx = x + 13 + walk;           // la falce dondola col passo
        var sy = y + bob * 0.5;
        draw_set_colour(c_black);
        draw_line_width(sx, sy + 10, sx, sy - 16, 3);
        draw_set_colour(c_ltgray);
        draw_line(sx, sy + 10, sx, sy - 16);
        // lama: mezzaluna che parte dalla cima e ricade verso l'esterno
        for (var pass = 0; pass < 2; pass++) {
            draw_set_colour(pass == 0 ? c_black : c_white);
            var lw = (pass == 0) ? 3 : 1;
            for (var ba = 90; ba > -20; ba -= 15) {
                var bb = max(ba - 15, -20);
                draw_line_width(sx + lengthdir_x(10, ba), sy - 11 + lengthdir_y(5, ba),
                                sx + lengthdir_x(10, bb), sy - 11 + lengthdir_y(5, bb), lw);
            }
        }
    }
    if (sweep_anim > 0) {
        // la falciata: un cerchio che svanisce e una lama che ruota
        draw_set_colour(c_white);
        draw_set_alpha(sweep_anim / 10);
        draw_circle(x, y, sweep_radius, true);
        var a = (10 - sweep_anim) * 36;
        draw_line_width(x, y, x + lengthdir_x(sweep_radius, a), y + lengthdir_y(sweep_radius, a), 3);
        draw_set_alpha(1);
    }
}
