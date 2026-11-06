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

var ms = 1 + (mech_scale - 1) * m;   // il mecha e' un po' piu' grosso; torna normale aprendosi in navicella
if (unfold < 1) {
    for (var i = 0; i < array_length(parts); i++) {
        var p = parts[i];
        var hw = p[2] / 2, hh = p[3] / 2;
        var lx = (p[0] + hw - 24 + p[4] * m) * sq * ms;      // centro del pezzo, senza inclinazione
        var ly = (p[1] + hh - 24 + (p[5] + ex_dy[i]) * m) * ms;
        var pcx = cx + lx * rc + ly * rs;                      // ruotato attorno al centro del mecha
        var pcy = cy - lx * rs + ly * rc;
        var ang = (p[6] + ex_ang[i]) * m - tilt;
        // draw_sprite_general ruota attorno all'angolo in alto a sinistra: lo calcoliamo dal centro
        var dd = point_direction(0, 0, -hw * sq * ms, -hh * ms) + ang;
        var dl = point_distance(0, 0, hw * sq * ms, hh * ms);
        draw_sprite_general(spr_player_ship, 0, p[0], p[1], p[2], p[3],
            pcx + lengthdir_x(dl, dd), pcy + lengthdir_y(dl, dd), sq * ms, ms, ang,
            c_white, c_white, c_white, c_white, 1);
    }
}

if (!transformed) {
    // la falce, tenuta a destra (solo da fermo: durante la falciata c'e' la lama che ruota).
    // Anche lei si inclina col mecha
    if (sweep_anim == 0) {
        var fx = 13 * sq * ms;         // posizione dell'asta rispetto al centro
        var fb = bob * 0.5;
        var x1 = cx + fx * rc + (10 + fb) * ms * rs,  y1 = cy - fx * rs + (10 + fb) * ms * rc;    // fondo dell'asta
        var x2 = cx + fx * rc + (-16 + fb) * ms * rs, y2 = cy - fx * rs + (-16 + fb) * ms * rc;   // cima dell'asta
        draw_set_colour(c_black);
        draw_line_width(x1, y1, x2, y2, 3);
        draw_set_colour(make_colour_rgb(150, 170, 200));
        draw_line(x1, y1, x2, y2);
        // lama: mezzaluna AZZURRA piena e chiusa (azzurro = roba tua, come i colpi parati e la scia del motore).
        // Bordo esterno ad arco; quello interno si avvicina e torna a toccarlo alle due punte.
        var oxs = [], oys = [], ixs = [], iys = [];
        var bcy = (-11 + fb) * ms;   // centro della curva della lama
        for (var ba = 90; ba >= -30; ba -= 10) {
            var ax = fx + lengthdir_x(11 * ms, ba), ay = bcy + lengthdir_y(6 * ms, ba);
            var th = 1 - 0.5 * dsin((90 - ba) * 1.5);   // spessore: zero alle punte, massimo a meta'
            var bx2 = fx + (ax - fx) * th, by2 = bcy + (ay - bcy) * th;
            array_push(oxs, cx + ax * rc + ay * rs);   array_push(oys, cy - ax * rs + ay * rc);
            array_push(ixs, cx + bx2 * rc + by2 * rs); array_push(iys, cy - bx2 * rs + by2 * rc);
        }
        var nb = array_length(oxs);
        // alone che pulsa
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.4 + 0.15 * dsin(current_time * 0.3));
        draw_set_colour(make_colour_rgb(40, 140, 255));
        for (var k = 0; k < nb - 1; k++) draw_line_width(oxs[k], oys[k], oxs[k + 1], oys[k + 1], 6);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        // corpo pieno
        draw_set_colour(make_colour_rgb(70, 190, 255));
        draw_primitive_begin(pr_trianglestrip);
        for (var k = 0; k < nb; k++) {
            draw_vertex(oxs[k], oys[k]);
            draw_vertex(ixs[k], iys[k]);
        }
        draw_primitive_end();
        // contorno chiaro, chiuso: arco esterno e arco interno si uniscono alle punte
        draw_set_colour(make_colour_rgb(215, 250, 255));
        for (var k = 0; k < nb - 1; k++) {
            draw_line_width(oxs[k], oys[k], oxs[k + 1], oys[k + 1], 1.5);
            draw_line_width(ixs[k], iys[k], ixs[k + 1], iys[k + 1], 1.5);
        }
    }
    if (sweep_anim > 0) {
        draw_set_colour(make_colour_rgb(120, 235, 255));   // dello stesso azzurro della lama
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
