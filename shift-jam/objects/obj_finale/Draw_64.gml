if (flash > 0) {
    draw_set_alpha(flash);
    draw_set_colour(c_white);
    draw_rectangle(0, 0, room_width, room_height, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var cx = room_width / 2;
var cy = room_height / 2 + 60;   // sotto il punto dove la navicella sparisce

// poesia di Ryokan: compare in 1 s, resta, svanisce in 1 s
var a_poem = clamp(min((t - 600) / 60, (1200 - t) / 60), 0, 1);
if (a_poem > 0) {
    draw_set_alpha(a_poem);
    draw_text(cx, cy - 48, "\"You must rise above");
    draw_text(cx, cy - 32, "The gloomy clouds");
    draw_text(cx, cy - 16, "Covering the mountaintop");
    draw_text(cx, cy,      "Otherwise, how will you");
    draw_text(cx, cy + 16, "Ever see the brightness?\"");
    draw_text(cx, cy + 48, "- Ryokan Taigu");
}

// poi il nome dell'autore
var a_cred = clamp((t - 1230) / 60, 0, 1);
if (a_cred > 0) {
    draw_set_alpha(a_cred);
    draw_text(cx, cy - 8, "A game by Marco Bianchi");
    draw_text(cx, cy + 12, "(Chelios)");
}
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
}
draw_set_alpha(1);
