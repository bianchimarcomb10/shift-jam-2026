// navetta: lo scafo dell'Inseguitore, piu' piccolo, girato verso di te
draw_sprite_ext(spr_enemy_stalker, 0, x, y - 6, 0.7, 0.7, 180, c_white, 1);
// la LASTRA: una mezzaluna di energia verde davanti alla navetta. Piu' e' rovinata, piu' trema e si spegne
var lime = make_colour_rgb(175, 235, 70);
var life = clamp(hp / 8, 0, 1);
var jit = (1 - life) * 1.5 * dsin(current_time * 1.7 + id * 40);
var cx = x, cy = y + 2;
var r0 = 13, r1 = 18;
// alone
gpu_set_blendmode(bm_add);
draw_set_alpha(0.18 + 0.12 * life);
draw_set_colour(lime);
draw_primitive_begin(pr_trianglestrip);
for (var a = 200; a <= 340; a += 10) {
    draw_vertex(cx + lengthdir_x(r0 - 3, a), cy + lengthdir_y(r0 - 3, a) * 0.7);
    draw_vertex(cx + lengthdir_x(r1 + 4, a), cy + lengthdir_y(r1 + 4, a) * 0.7 + jit);
}
draw_primitive_end();
gpu_set_blendmode(bm_normal);
// la lastra piena, con il bordo chiaro
draw_set_alpha(0.55 + 0.4 * life);
draw_set_colour((flash > 0) ? c_white : lime);
draw_primitive_begin(pr_trianglestrip);
for (var a = 200; a <= 340; a += 10) {
    draw_vertex(cx + lengthdir_x(r0, a), cy + lengthdir_y(r0, a) * 0.7);
    draw_vertex(cx + lengthdir_x(r1, a), cy + lengthdir_y(r1, a) * 0.7 + jit);
}
draw_primitive_end();
draw_set_colour((flash > 0) ? c_white : make_colour_rgb(230, 255, 170));
for (var a = 200; a < 340; a += 10) {
    draw_line(cx + lengthdir_x(r1, a), cy + lengthdir_y(r1, a) * 0.7 + jit, cx + lengthdir_x(r1, a + 10), cy + lengthdir_y(r1, a + 10) * 0.7 + jit);
}
draw_set_alpha(1);
draw_set_colour(c_white);
