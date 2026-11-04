if (flash > 0) {
    draw_set_alpha(flash);
    draw_set_colour(c_white);
    draw_rectangle(0, 0, room_width, room_height, false);
}
if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
}
draw_set_alpha(1);
