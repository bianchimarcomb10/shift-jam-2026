if (y < -50) exit;
// il dono che porta: una luce azzurra che pulsa al centro (azzurro = roba del giocatore)
var pulse = 0.5 + 0.5 * dsin(current_time * 0.5);
gpu_set_blendmode(bm_add);
draw_set_colour(make_colour_rgb(70, 190, 255));
draw_set_alpha(0.25 + 0.25 * pulse);
draw_circle(x, y, 13 + 3 * pulse, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
// la nave guarda dove vola (la sprite guarda in alto, 90 gradi)
var ang = point_direction(0, 0, side * 1.0, y - yprevious) - 90;
draw_sprite_ext(spr_enemy_carrier, 0, x, y, 1, 1, ang, c_white, 1);
if (flash > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(spr_enemy_carrier, 0, x, y, 1, 1, ang, c_white, 1);
    gpu_set_blendmode(bm_normal);
}
// il nucleo
draw_set_colour(make_colour_rgb(215, 250, 255));
draw_circle(x, y, 2 + pulse, false);
draw_set_colour(c_white);
