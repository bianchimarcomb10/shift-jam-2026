// vita del boss: una barra per fase
var w = room_width - 40;
var hp_frac = (phase == 1) ? (hp - hp_p2) / hp_p1 : hp / hp_p2;
draw_set_colour(c_dkgray);
draw_rectangle(20, 44, 20 + w, 48, false);
draw_set_colour((phase == 1) ? make_colour_rgb(130, 110, 170) : make_colour_rgb(225, 215, 190));
draw_rectangle(20, 44, 20 + w * clamp(hp_frac, 0, 1), 48, false);

if (hint > 0 && transition == 0) {
    draw_set_halign(fa_center);
    draw_set_colour(make_colour_rgb(220, 180, 80));
    draw_text(room_width / 2, room_height - 60, "GOLDEN BEADS: DEFLECT THEM WITH Z");
    draw_set_halign(fa_left);
}
