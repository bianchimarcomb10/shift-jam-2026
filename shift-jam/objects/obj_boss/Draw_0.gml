// mala: 108 grani in cerchio
draw_set_colour(make_colour_rgb(150, 110, 70));
for (var i = 0; i < 108; i++) {
    var a = bead_angle + i * (360 / 108);
    draw_circle(x + lengthdir_x(70, a), y + lengthdir_y(70, a), 2, false);
}

// teschio
draw_set_colour(make_colour_rgb(225, 215, 190));
draw_circle(x, y, 26, false);
draw_set_colour(c_black);
draw_circle(x - 9, y - 4, 6, false);
draw_circle(x + 9, y - 4, 6, false);
draw_triangle(x, y + 4, x - 3, y + 11, x + 3, y + 11, false);

// mani giunte (si separano e si chiudono)
draw_set_colour(make_colour_rgb(200, 180, 150));
var hg = hands_gap / 2;
draw_rectangle(x - 8 - hg, y + 30, x - hg, y + 54, false);
draw_rectangle(x + hg, y + 30, x + 8 + hg, y + 54, false);
