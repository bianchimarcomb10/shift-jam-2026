/// Barra di accerchiamento, scritta SHIFT, lampo.
var w = room_width - 40;
draw_set_colour(c_dkgray);
draw_rectangle(20, 16, 20 + w, 22, false);
draw_set_colour(make_colour_rgb(200, 60, 60));
draw_rectangle(20, 16, 20 + w * bar, 22, false);

draw_set_halign(fa_center);
draw_set_colour(c_white);
if (state == 0 && t < 240) draw_text(room_width / 2, room_height - 40, "WASD: muoviti   Z: falciata");
if (state == 1 && (current_time div 400) mod 2 == 0) {
    draw_text(room_width / 2, room_height * 0.35, "Press SHIFT to struggle");
}
draw_set_halign(fa_left);

if (flash > 0) {
    draw_set_alpha(flash);
    draw_set_colour(c_white);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
}
