// rombo rosso scuro; il nucleo si accende nell'ultimo mezzo secondo prima del colpo
draw_set_colour(make_colour_rgb(140, 40, 50));
draw_triangle(x, y - 11, x - 9, y, x + 9, y, false);
draw_triangle(x, y + 11, x - 9, y, x + 9, y, false);
draw_set_colour((fire_timer < 30) ? c_white : make_colour_rgb(80, 20, 30));
draw_circle(x, y, 3, false);
