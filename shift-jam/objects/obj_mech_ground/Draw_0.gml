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

// vita: il mantello ondeggia e si apre nella falciata, le gambe fanno il passo, la testa respira
var moving = (abs(x - xprevious) + abs(y - yprevious) > 0.1);
var walk = moving ? dsin(current_time * 0.9) : 0;
var bob = dsin(current_time * 0.25);
var flare = (sweep_anim > 0) ? sweep_anim * 3 : 0;
var sway = 4 * dsin(current_time * 0.2);
var ex_ang = [sway - flare, flare - sway, 0, 0, 0, 0];
var ex_dy = [bob * 0.5, bob * 0.5, walk * 1.5, -walk * 1.5, bob * 0.5, bob];

if (unfold < 1) {
    for (var i = 0; i < array_length(parts); i++) {
        var p = parts[i];
        var hw = p[2] / 2, hh = p[3] / 2;
        var pcx = (x + ox) + p[0] + hw - 24 + p[4] * m;   // centro del pezzo
        var pcy = (y + oy) + p[1] + hh - 24 + (p[5] + ex_dy[i]) * m;
        var ang = (p[6] + ex_ang[i]) * m;
        // draw_sprite_general ruota attorno all'angolo in alto a sinistra: lo calcoliamo dal centro
        var dd = point_direction(0, 0, -hw, -hh) + ang;
        var dl = point_distance(0, 0, hw, hh);
        draw_sprite_general(spr_player_ship, 0, p[0], p[1], p[2], p[3],
            pcx + lengthdir_x(dl, dd), pcy + lengthdir_y(dl, dd), 1, 1, ang,
            c_white, c_white, c_white, c_white, 1);
    }
}

if (!transformed) {
    // la falce, tenuta a destra (solo da fermo: durante la falciata c'e' la lama che ruota)
    if (sweep_anim == 0) {
        var sx = (x + ox) + 13 + walk;   // la falce dondola col passo
        draw_set_colour(c_black);
        draw_line_width(sx, (y + oy) + 10, sx, (y + oy) - 16, 3);
        draw_set_colour(c_ltgray);
        draw_line(sx, (y + oy) + 10, sx, (y + oy) - 16);
        // lama: mezzaluna che parte dalla cima e ricade verso l'esterno
        for (var pass = 0; pass < 2; pass++) {
            draw_set_colour(pass == 0 ? c_black : c_white);
            var lw = (pass == 0) ? 3 : 1;
            for (var ba = 90; ba > -20; ba -= 15) {
                var bb = max(ba - 15, -20);
                draw_line_width(sx + lengthdir_x(10, ba), (y + oy) - 11 + lengthdir_y(5, ba),
                                sx + lengthdir_x(10, bb), (y + oy) - 11 + lengthdir_y(5, bb), lw);
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
