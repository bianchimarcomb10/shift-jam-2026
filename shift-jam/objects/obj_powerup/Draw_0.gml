// una capsula azzurra (azzurro = roba del giocatore) con dentro il colpo dell'arma che porta
var cx = round(x), cy = round(y);
var pulse = 0.5 + 0.5 * dsin(t * 6);
gpu_set_blendmode(bm_add);
draw_set_colour(make_colour_rgb(40, 140, 255));
draw_set_alpha(0.25 + 0.2 * pulse);
draw_circle(cx, cy, 15 + 2 * pulse, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_colour(make_colour_rgb(10, 16, 30));
draw_circle(cx, cy, 11, false);
draw_set_colour(make_colour_rgb(70, 190, 255));
draw_circle(cx, cy, 11, true);
draw_circle(cx, cy, 10, true);
// il colpo dentro, che gira piano
switch (kind) {
    case 1:   // due razzi incrociati
        draw_sprite_ext(spr_rocket, (t div 4) mod 3, cx - 3, cy + 1, 1, 1, 20, c_white, 1);
        draw_sprite_ext(spr_rocket, (t div 4 + 1) mod 3, cx + 3, cy + 1, 1, 1, -20, c_white, 1);
        break;
    case 2:   // un pezzo di laser
        draw_sprite_ext(spr_zapper, (t div 3) mod 8, cx, cy, 0.8, 0.6, 0, c_white, 1);
        break;
    case 3:   // un globo
        draw_sprite_ext(spr_orb, (t div 3) mod 10, cx, cy, 0.6, 0.6, 0, c_white, 1);
        break;
}
// la lettera dell'arma, sotto
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_colour(make_colour_rgb(215, 250, 255));
draw_text(cx, cy + 15, (kind == 1) ? "R" : ((kind == 2) ? "L" : "S"));
draw_set_halign(fa_left);
draw_set_colour(c_white);
