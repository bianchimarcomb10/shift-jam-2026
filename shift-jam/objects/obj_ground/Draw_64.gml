/// Barra di accerchiamento, SHIFT TO STRUGGLE, esplosione a stelle, frase di Dogen, lampo.
var cx = room_width / 2;
var cy = room_height / 2;

if (state < 2) {   // dopo la trasformazione la barra non serve piu'
    var w = room_width - 40;
    draw_set_colour(c_dkgray);
    draw_rectangle(20, 16, 20 + w, 22, false);
    draw_set_colour(make_colour_rgb(200, 60, 60));
    draw_rectangle(20, 16, 20 + w * bar, 22, false);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(c_white);
if (state == 0 && t < 240) {
    // su due righe: cosi' non esce dai bordi
    draw_text(cx, room_height - 44, "WASD/ARROWS: MOVE");
    draw_text(cx, room_height - 26, "Z/SPACE: SCYTHE");
}

if (state == 1) {
    // EMERGENZA: lo schermo pulsa di rosso e la scritta, enorme, trema
    draw_set_alpha(0.15 + 0.12 * dsin(current_time * 0.6));
    draw_set_colour(make_colour_rgb(200, 0, 30));
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
    // la scala si calcola dalla larghezza vera della parola piu' lunga, cosi' resta dentro lo schermo
    var gw = display_get_gui_width();
    var sc_max = (gw - 28) / string_width("STRUGGLE");
    var sc = sc_max * (0.95 + 0.04 * dsin(current_time * 0.9));
    var sx = random_range(-3, 3);
    var sy = random_range(-3, 3);
    draw_set_colour(c_black);   // ombra, per leggerla sopra la marea di alieni
    draw_text_transformed(cx + sx + 3, cy + sy + 3, "SHIFT\nTO\nSTRUGGLE", sc, sc, random_range(-1, 1));
    if ((current_time div 150) mod 2 == 0) draw_set_colour(c_white); else draw_set_colour(make_colour_rgb(255, 40, 60));
    draw_text_transformed(cx + sx, cy + sy, "SHIFT\nTO\nSTRUGGLE", sc, sc, random_range(-1, 1));
    draw_set_colour(c_white);
}

if (state == 2) {
    // le stelle nascono come punti e crescono, finche' il bianco e' fatto solo di stelle
    for (var i = 0; i < array_length(stars); i++) {
        var k = clamp((t - stars[i][2]) / star_grow, 0, 1);
        draw_circle(stars[i][0], stars[i][1], max(0.6, star_max_r * k * k), false);
    }
}

if (state == 3) {
    // la frase compare quando la navicella e' a meta' schermo e svanisce prima dello spazio
    var a_q = clamp(min((t - 60) / 60, (360 - t) / 60), 0, 1);
    if (a_q > 0) {
        draw_set_alpha(a_q);
        draw_text(cx, cy - 20, "\"I live by letting");
        draw_text(cx, cy, "things happen.\"");
        draw_text(cx, cy + 40, "- Dogen");
        draw_set_alpha(1);
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (flash > 0) {
    draw_set_alpha(flash);
    draw_set_colour(c_white);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
}
