if (life < 120 && (life div 6) mod 2 == 0) exit;   // sta per svanire: lampeggia
var cx = round(x), cy = round(y);
var full = (global.hp >= 3);   // vite piene: non si prende, e si vede piu' tenue
// alone azzurro che pulsa
if (!full) {
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.35 + 0.15 * dsin(t * 6));
    draw_heart_px(cx, cy, 13, 0, make_colour_rgb(40, 140, 255));
    gpu_set_blendmode(bm_normal);
}
draw_set_alpha(full ? 0.4 : 1);
// bordo azzurro, poi lo yin-yang dentro
draw_heart_px(cx, cy, 11.6, 0, make_colour_rgb(70, 190, 255));
draw_heart_px(cx, cy, 10.5, 1, c_white);
draw_set_alpha(1);
draw_set_colour(c_white);
