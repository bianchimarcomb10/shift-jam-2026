/// guscio bianco e nero a spicchi che gira (regalo), con dentro cosa porta
var cx = round(x), cy = round(y);
var white = make_colour_rgb(240, 244, 250), black = make_colour_rgb(16, 14, 24);
var pulse = 0.5 + 0.5 * dsin(t * 6);
// alone azzurro: dentro c'e' qualcosa per il giocatore
gpu_set_blendmode(bm_add);
draw_set_colour(make_colour_rgb(40, 140, 255));
draw_set_alpha(0.12 + 0.12 * pulse);
draw_circle(cx, cy, radius + 4 + 2 * pulse, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
// il guscio: 8 spicchi bianchi e neri. Cuore = cerchio; arma = rombo
var heart = (gift == 0);
for (var i = 0; i < 8; i++) {
    var a0 = rot + i * 45, a1 = a0 + 45;
    var r0 = radius + 1, r1 = radius + 1;
    if (!heart) {
        // rombo: il raggio cambia con l'angolo (4 punte)
        r0 = (radius + 5) / (abs(dcos(a0 - rot)) + abs(dsin(a0 - rot)));
        r1 = (radius + 5) / (abs(dcos(a1 - rot)) + abs(dsin(a1 - rot)));
    }
    draw_set_colour((i mod 2 == 0) ? white : black);
    draw_triangle(cx, cy, cx + lengthdir_x(r0, a0), cy + lengthdir_y(r0, a0), cx + lengthdir_x(r1, a1), cy + lengthdir_y(r1, a1), false);
}
// il vetro scuro al centro
draw_set_colour(make_colour_rgb(10, 16, 30));
draw_circle(cx, cy, heart ? radius - 2 : radius - 3, false);
// cosa porta
if (heart) {
    // il cuore yin-yang con il bordo azzurro, come quello che cade
    draw_heart_px(cx, cy, 7.4, 0, make_colour_rgb(70, 190, 255));
    draw_heart_px(cx, cy, 6.4, 1, c_white);
} else {
    draw_set_colour(make_colour_rgb(70, 190, 255));
    draw_circle(cx, cy, radius - 3, true);
    draw_set_font(fnt_main);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(make_colour_rgb(215, 250, 255));
    draw_text(cx + 1, cy + 1, (gift == 1) ? "R" : ((gift == 2) ? "L" : "S"));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
// colpito: lampo bianco
if (flash > 0) {
    gpu_set_blendmode(bm_add);
    draw_set_colour(c_white);
    draw_set_alpha(0.6);
    draw_circle(cx, cy, radius + 2, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}
draw_set_colour(c_white);
