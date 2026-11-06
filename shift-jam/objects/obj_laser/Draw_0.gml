if (wait > 0) exit;
var nose = y + 12 * sc;   // la prua: la nave e' girata, il muso e' in basso

// --- AVVISO mentre carica: una linea rossa sottile che lampeggia sempre piu' in fretta,
// e la luce che si raccoglie nella prua
if (state == 2) {
    var k = t / 60;   // da 0 a 1
    var blink = (current_time div max(40, round(160 - k * 120))) mod 2;
    draw_set_colour(make_colour_rgb(255, 40, 40));
    draw_set_alpha(0.25 + 0.5 * blink);
    draw_line_width(x, nose, x, room_height, 1 + k * 2);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.8);
    for (var i = 0; i < 6; i++) {
        var a = i * 60 + current_time * 0.3;
        var r = 26 * (1 - frac(current_time / 400 + i / 6));   // le scintille cadono verso la prua
        draw_circle(x + lengthdir_x(r, a), nose + lengthdir_y(r, a), 1.5, false);
    }
    draw_set_alpha(0.4 + 0.4 * k);
    draw_circle(x, nose, 3 + k * 6, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

// --- IL RAGGIO: pulsa, scorre verso il basso, brucia
if (beam_w > 0) {
    var pulse = 0.5 + 0.5 * dsin(current_time * 1.2);
    var w = beam_w * (0.85 + 0.25 * pulse);
    // alone largo rosso scuro che respira
    gpu_set_blendmode(bm_add);
    draw_set_colour(make_colour_rgb(200, 20, 20));
    draw_set_alpha(0.25 + 0.15 * pulse);
    draw_rectangle(x - w * 2.2, nose, x + w * 2.2, room_height, false);
    draw_set_alpha(0.35);
    draw_rectangle(x - w * 1.4, nose, x + w * 1.4, room_height, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    // il corpo: la striscia "Ray" del pacchetto (4 fotogrammi da 18x38, ricolorata rossa) ripetuta in verticale
    var fr = (current_time div 45) mod 4;
    var sx = w / 8;   // un fotogramma e' largo 18 px: lo allargo quanto il raggio
    var o = (38 - (current_time * 0.6) mod 38) mod 38;   // scorrimento verso il basso
    if (38 - o > 0) draw_sprite_general(spr_laser_ray, 0, fr * 18, o, 18, 38 - o, x - 9 * sx, nose, sx, 1, 0, c_white, c_white, c_white, c_white, 1);
    for (var yy = nose + 38 - o; yy < room_height; yy += 38) {
        draw_sprite_general(spr_laser_ray, 0, fr * 18, 0, 18, 38, x - 9 * sx, yy, sx, 1, 0, c_white, c_white, c_white, c_white, 1);
    }
    // nucleo bianco
    draw_set_colour(c_white);
    draw_rectangle(x - w * 0.25, nose, x + w * 0.25, room_height, false);
    // bocca di fuoco e scintille lungo il raggio
    gpu_set_blendmode(bm_add);
    draw_set_colour(make_colour_rgb(255, 60, 40));
    draw_set_alpha(0.6);
    draw_circle(x, nose, w * 1.6 + 3 * pulse, false);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(255, 120, 90));
    for (var s = 0; s < 8; s++) {
        var sy = nose + ((current_time * 0.5 + s * 83) mod (room_height - nose));
        var sxo = ((s mod 2 == 0) ? -1 : 1) * (w + 2 + 3 * dsin(current_time + s * 40));
        draw_circle(x + sxo, sy, 1, false);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_colour(c_white);
    draw_circle(x, nose, w * 0.8, false);
}

// --- LA NAVE: fiammelle dei motori in coda, poi i pezzi (due motori laterali che si aprono, scafo al centro)
global.draw_frame(spr_laser_engine, (current_time div 70) mod 10, x, y, 180, sc);
var jit = (state == 3) ? random_range(-0.3, 0.3) : 0;   // sparando, i motori tremano
if (flash > 0) gpu_set_fog(true, c_white, 0, 0);   // colpita: tutta bianca per un attimo
global.draw_parts(spr_enemy_laser, [
    [17, 20, 7, 27, 20, 33, 0, -open - jit, 0],   // motore sinistro
    [40, 20, 7, 27, 43, 33, 0,  open + jit, 0],   // motore destro
    [24, 20, 16, 27, 32, 32, 0, 0, 0]             // scafo
], x, y, 180, sc);
if (flash > 0) gpu_set_fog(false, c_white, 0, 0);
draw_set_alpha(1);
draw_set_colour(c_white);
