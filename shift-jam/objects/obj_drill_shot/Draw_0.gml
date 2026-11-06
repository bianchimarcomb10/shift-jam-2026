// scia di luce sotto la trivella
gpu_set_blendmode(bm_add);
draw_set_alpha(0.35);
draw_set_colour(make_colour_rgb(60, 150, 255));
draw_rectangle(x - 4 * sc, y, x + 4 * sc, y + 30 + v * 4, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_colour(c_white);
global.draw_drill(x, y, sc, ph, 1);
