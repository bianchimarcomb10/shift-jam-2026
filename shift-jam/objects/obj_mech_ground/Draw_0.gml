var ox = 0;
var oy = 0;
if (obj_ground.state == 1 || obj_ground.mass) {   // sommerso: il mecha trema
    ox = irandom_range(-2, 2);
    oy = irandom_range(-2, 2);
}

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

// m = 1 mecha; dopo SHIFT scende a 0 mentre si apre in navicella
var m = 1 - unfold;

// vita: il mantello ondeggia e si apre nella falciata, tutto il corpo respira,
// e in virata si piega come la navicella (stessa formula di obj_player)
tilt += (clamp(x - xprevious, -4, 4) * 4 - tilt) * 0.2;
var bob = dsin(current_time * 0.25);
var sq = 1 - abs(tilt) / 60;
var rc = dcos(-tilt), rs = dsin(-tilt);   // punto ruotato: cx + lx * rc + ly * rs , cy - lx * rs + ly * rc
var cx = x + ox, cy = y + oy;
var flare = (sweep_anim > 0) ? sweep_anim * 3 : 0;
var sway = 4 * dsin(current_time * 0.2);
var ex_ang = [sway - flare, flare - sway, 0, 0, 0, 0];
var ex_dy = [bob * 0.5, bob * 0.5, bob * 0.5, bob * 0.5, bob * 0.5, bob];

if (unfold < 1) {
    for (var i = 0; i < array_length(parts); i++) {
        var p = parts[i];
        var hw = p[2] / 2, hh = p[3] / 2;
        var lx = (p[0] + hw - 24 + p[4] * m) * sq;           // centro del pezzo, senza inclinazione
        var ly = p[1] + hh - 24 + (p[5] + ex_dy[i]) * m;
        var pcx = cx + lx * rc + ly * rs;                      // ruotato attorno al centro del mecha
        var pcy = cy - lx * rs + ly * rc;
        var ang = (p[6] + ex_ang[i]) * m - tilt;
        // draw_sprite_general ruota attorno all'angolo in alto a sinistra: lo calcoliamo dal centro
        var dd = point_direction(0, 0, -hw * sq, -hh) + ang;
        var dl = point_distance(0, 0, hw * sq, hh);
        draw_sprite_general(spr_player_ship, 0, p[0], p[1], p[2], p[3],
            pcx + lengthdir_x(dl, dd), pcy + lengthdir_y(dl, dd), sq, 1, ang,
            c_white, c_white, c_white, c_white, 1);
    }
}

if (!transformed) {
    // la falce, tenuta a destra (solo da fermo: durante la falciata c'e' la lama che ruota).
    // Anche lei si inclina col mecha
    if (sweep_anim == 0) {
        var fx = 13 * sq;
        var fb = bob * 0.5;
        var x1 = cx + fx * rc + (10 + fb) * rs,  y1 = cy - fx * rs + (10 + fb) * rc;    // fondo dell'asta
        var x2 = cx + fx * rc + (-16 + fb) * rs, y2 = cy - fx * rs + (-16 + fb) * rc;   // cima dell'asta
        draw_set_colour(c_black);
        draw_line_width(x1, y1, x2, y2, 3);
        draw_set_colour(c_ltgray);
        draw_line(x1, y1, x2, y2);
        // lama: mezzaluna che parte dalla cima e ricade verso l'esterno
        for (var pass = 0; pass < 2; pass++) {
            draw_set_colour(pass == 0 ? c_black : c_white);
            var lw = (pass == 0) ? 3 : 1;
            for (var ba = 90; ba > -20; ba -= 15) {
                var bb = max(ba - 15, -20);
                var ax = fx + lengthdir_x(10, ba), ay = -11 + fb + lengthdir_y(5, ba);
                var cx2 = fx + lengthdir_x(10, bb), cy2 = -11 + fb + lengthdir_y(5, bb);
                draw_line_width(cx + ax * rc + ay * rs, cy - ax * rs + ay * rc,
                                cx + cx2 * rc + cy2 * rs, cy - cx2 * rs + cy2 * rc, lw);
            }
        }
    }
    if (sweep_anim > 0) {
        draw_set_colour(c_white);
        draw_set_alpha(sweep_anim / 10);
        draw_circle(x, y, sweep_radius, true);
        var a = (10 - sweep_anim) * 36;
        draw_line_width(x, y, x + lengthdir_x(sweep_radius, a), y + lengthdir_y(sweep_radius, a), 3);
        draw_set_alpha(1);
    }
} else if (unfold >= 1) {
    draw_sprite(spr_player_flame, (current_time div 80) mod 4, x, y);
    draw_sprite(spr_player_engine, 0, x, y);
    draw_sprite(spr_player_ship, 0, x, y);
}
