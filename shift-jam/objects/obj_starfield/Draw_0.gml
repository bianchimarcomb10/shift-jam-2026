draw_set_alpha(alpha);
draw_set_colour(c_white);
for (var i = 0; i < array_length(stars); i++) {
    var s = stars[i];
    var size = (s[2] > 1) ? 1 : 0;   // le stelle piu' veloci (vicine) sono un po' piu' grandi
    draw_rectangle(s[0], s[1], s[0] + size, s[1] + size, false);
}
draw_set_alpha(1);
