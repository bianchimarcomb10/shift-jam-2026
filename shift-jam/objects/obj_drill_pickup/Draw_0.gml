// colonna di luce dal cielo
gpu_set_blendmode(bm_add);
draw_set_alpha(0.10 + 0.05 * dsin(current_time * 0.4));
draw_set_colour(make_colour_rgb(60, 150, 255));
draw_rectangle(x - 14, 0, x + 14, y, false);
draw_set_alpha(0.12);
draw_rectangle(x - 5, 0, x + 5, y, false);
// scintille che cadono intorno
for (var k = 0; k < 6; k++) {
    var sy = (current_time * 0.08 + k * 37) mod max(1, y);
    draw_set_alpha(0.6);
    draw_circle(x + 18 * dsin(k * 60 + current_time * 0.1), sy, 1, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_colour(c_white);
// la trivella, grande e carica (la base sotto il centro, cosi' il centro dell'oggetto e' a meta' trivella)
global.draw_drill(x, y + 15, 1.5, ph, 1);
