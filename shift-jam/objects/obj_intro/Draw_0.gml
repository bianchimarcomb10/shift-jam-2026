var cx = room_width / 2;
var cy = room_height / 2;
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(c_white);

switch (state) {
case 0:
case 1:
    var a_title = (state == 1) ? 1 - t / 40 : 1;
    draw_set_alpha(a_title);
    draw_text_transformed(cx, cy - 60, game_title, 3, 3, 0);
    if (state == 1 || (current_time div 500) mod 2 == 0) draw_text(cx, cy + 80, "Press SHIFT to continue");
    // la VERSIONE, in piccolo nell'angolo: serve a capire quale zip e' installato
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_set_colour(make_colour_rgb(90, 96, 130));
    draw_text(room_width - 6, room_height - 6, "BUILD " + BUILD);
    draw_set_colour(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    break;

case 2:
    var a_quote = clamp(min(t / 60, (300 - t) / 60), 0, 1);   // 1 s per comparire, 1 s per svanire
    draw_set_alpha(a_quote);
    draw_text(cx, cy - 20, "\"If you meet a buddha,");
    draw_text(cx, cy, "kill the buddha.\"");
    draw_text(cx, cy + 40, "- Linji Yixuan");
    break;

case 3:
    draw_set_alpha(min(1, t / 30));
    draw_text(cx, cy, "Press SHIFT");
    break;

case 4:
    // nessuna dissolvenza: ogni stella nasce come un punto e cresce,
    // e il bianco finale e' fatto solo di stelle che si toccano
    for (var i = 0; i < array_length(stars); i++) {
        var k = clamp((t - stars[i][2]) / star_grow, 0, 1);
        var r = max(0.6, star_max_r * k * k);   // cresce piano e poi in fretta
        draw_circle(stars[i][0], stars[i][1], r, false);
    }
    break;
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
