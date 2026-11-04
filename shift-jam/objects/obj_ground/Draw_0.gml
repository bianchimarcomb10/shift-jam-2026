/// Terreno e rovine provvisorie.
draw_set_colour(make_colour_rgb(70, 58, 48));
draw_rectangle(0, ground_y + 12, room_width, room_height, false);

draw_set_colour(make_colour_rgb(55, 50, 50));
for (var i = 0; i < array_length(ruins); i++) {
    var r = ruins[i];
    draw_rectangle(r[0], r[1], r[0] + r[2], r[1] + r[3], false);
}
