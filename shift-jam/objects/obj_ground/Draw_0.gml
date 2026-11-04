/// Cielo, terreno e rovine provvisorie (solo se manca il livello "Ground"). Durante il decollo scendono via.
if (ground_layer == -1) {
    var k = clamp(scroll / 700, 0, 1);
    draw_set_colour(merge_colour(make_colour_rgb(40, 32, 28), make_colour_rgb(4, 4, 10), k));
    draw_rectangle(0, 0, room_width, room_height, false);

    draw_set_colour(make_colour_rgb(70, 58, 48));
    draw_rectangle(0, ground_y + 12 + scroll, room_width, room_height + scroll, false);

    draw_set_colour(make_colour_rgb(55, 50, 50));
    for (var i = 0; i < array_length(ruins); i++) {
        var r = ruins[i];
        draw_rectangle(r[0], r[1] + scroll, r[0] + r[2], r[1] + r[3] + scroll, false);
    }
}

// esplosione della trasformazione: anelli bianchi che si allargano
if (state >= 2 && t < 100 && state < 4) {
    var tt = (state == 2) ? t : t + 60;
    if (tt < 100) {
        draw_set_colour(c_white);
        for (var j = 0; j < 6; j++) {
            var rr = (tt - j * 8) * 4;
            if (rr > 0) {
                draw_set_alpha(max(0, 1 - rr / 320));
                draw_circle(boom_x, boom_y, rr, true);
            }
        }
        draw_set_alpha(1);
    }
}
