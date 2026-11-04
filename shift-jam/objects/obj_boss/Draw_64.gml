// vita del Custode
var w = room_width - 40;
draw_set_colour(c_dkgray);
draw_rectangle(20, 44, 20 + w, 48, false);
draw_set_colour(make_colour_rgb(225, 215, 190));
draw_rectangle(20, 44, 20 + w * max(0, hp) / hp_max, 48, false);
