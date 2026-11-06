if (!instance_exists(ship)) exit;
// la rastrelliera carica, girata come la nave
var l = (rack == 0) ? 9 : 38;
global.draw_parts(spr_torpedo_racks, [[l, 25, 17, 15, 32, 32, 0, 0, 0]], ship.x + bx, ship.y + oy, 180, 1);

// corazzata: una cornice d'acciaio con quattro ribattini
if (armored) {
    draw_set_colour((flash > 0) ? c_white : make_colour_rgb(150, 160, 175));
    draw_rectangle(x - 10, y - 9, x + 10, y + 9, true);
    draw_rectangle(x - 11, y - 10, x + 11, y + 10, true);
    draw_set_colour(make_colour_rgb(210, 215, 225));
    draw_point(x - 10, y - 9); draw_point(x + 10, y - 9);
    draw_point(x - 10, y + 9); draw_point(x + 10, y + 9);
}

// avviso: le punte dei tre tubi si accendono di giallo prima del colpo
if (charge > 0) {
    gpu_set_blendmode(bm_add);
    draw_set_colour(make_colour_rgb(255, 200, 60));
    draw_set_alpha(0.8);
    for (var k = -1; k <= 1; k++) draw_circle(x + k * 6, y + 6, 1 + (36 - charge) / 12, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}
