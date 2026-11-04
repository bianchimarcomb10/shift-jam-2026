draw_set_colour(reflected ? c_white : make_colour_rgb(220, 180, 80));
draw_circle(x, y, radius, false);
draw_set_colour(reflected ? make_colour_rgb(220, 180, 80) : make_colour_rgb(120, 90, 30));
draw_circle(x, y, radius, true);
draw_circle(x, y, radius / 2, true);
