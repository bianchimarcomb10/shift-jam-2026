var st = max(1, sc);
var H = 20 * st;   // altezza della trivella: la base e' H sopra la punta

if (planted) {
    // l'impatto: lampo bianco su tutto lo schermo e un anello azzurro che si allarga dal mecha
    var a = 1 - boom / 30;
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.55 * max(0, 1 - boom / 12));
    draw_set_colour(c_white);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(a);
    draw_set_colour(make_colour_rgb(110, 210, 255));
    var r = 10 + boom * 7;
    for (var w = 0; w < 3; w++) draw_circle(x, y, r + w, true);
    draw_set_alpha(a * 0.5);
    draw_circle(x, y, r * 0.6, true);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    exit;
}

gpu_set_blendmode(bm_add);
if (t <= hover) {
    // mentre scende piano: una colonna di luce dal cielo
    draw_set_alpha(0.10 + 0.05 * dsin(current_time * 0.4));
    draw_set_colour(make_colour_rgb(60, 150, 255));
    draw_rectangle(x - 14, 0, x + 14, y, false);
    draw_set_alpha(0.12);
    draw_rectangle(x - 5, 0, x + 5, y, false);
} else {
    // mentre piomba: scie dietro la trivella, sempre piu' lunghe
    var k = (t - hover) / (dur - hover);
    draw_set_colour(make_colour_rgb(120, 200, 255));
    for (var s = 0; s < 7; s++) {
        var sx = x + (s - 3) * 2.2 * st;
        var len = (40 + 60 * k) * (1 - abs(s - 3) / 4);
        draw_set_alpha(0.35 * k);
        draw_line_width(sx, y - H - len, sx, y - H * 0.5, max(1, st * 0.6));
    }
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_colour(c_white);
// la trivella, punta in basso: (x, y) e' la punta, la base sta H sopra
global.draw_drill(x, y - H, sc, ph, min(1, 2 / sc), -1);   // enorme, l'alone e' piu' tenue
