draw_set_colour(make_colour_rgb(150, 90, 200));
draw_rectangle(x - 6, y - 14, x + 6, y + 14, false);
draw_set_colour((charge > 0) ? c_white : c_dkgray);   // l'occhio si accende prima del colpo
draw_circle(x, y + 6, 3, false);
