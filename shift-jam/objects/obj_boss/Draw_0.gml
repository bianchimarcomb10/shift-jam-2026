if (phase == 1) {
    // ===== NAVE MADRE: la Dreadnought, girata verso il basso e ingrandita =====
    draw_sprite_ext(spr_boss_mothership, 0, x, y, 1.5, 1.5, 180, c_white, 1);
    exit;
}

// ===== IL GUSCIO SI ROMPE =====
if (transition > 0) {
    draw_set_alpha(transition / 120);
    draw_set_colour(make_colour_rgb(85, 75, 105));
    for (var i = 0; i < array_length(debris); i++) {
        var d = debris[i];
        draw_rectangle(d[0], d[1], d[0] + d[4], d[1] + d[4] * 0.6, false);
    }
    draw_set_alpha(1);
    if (transition > 60) exit;   // per il primo secondo si vedono solo i rottami
}

// ===== I KOI DELL'ENSŌ =====
var ga = 1;
if (transition > 0) ga = (60 - transition) / 60;               // appaiono piano
if (stun > 0 && (stun div 4) mod 2 == 0) ga *= 0.4;            // lampeggiano quando sono storditi
draw_set_alpha(ga);

// mala: 108 grani; quelli scelti per la raffica brillano d'oro, quelli lanciati mancano
var bstep = 360 / 108;
var tell = (bead_t > 0 && (bead_t div 4) mod 2 == 0);
for (var j = 0; j < 108; j++) {
    if (bead_gone[j] > 0) continue;
    var a = bead_angle + j * bstep;
    var bxp = x + lengthdir_x(70, a), byp = y + lengthdir_y(70, a);
    var chosen = false;
    if (bead_t > 0) for (var q = 0; q < array_length(bead_sel); q++) if (bead_sel[q] == j) chosen = true;
    if (chosen) {
        gpu_set_blendmode(bm_add);
        draw_set_alpha(ga * (tell ? 0.6 : 0.3));
        draw_set_colour(make_colour_rgb(255, 210, 90));
        draw_circle(bxp, byp, 6, false);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(ga);
        draw_set_colour(make_colour_rgb(240, 200, 90));
        draw_circle(bxp, byp, 3, false);
    } else {
        draw_set_colour(make_colour_rgb(190, 145, 70));
        draw_circle(bxp, byp, 2, false);
    }
}

// alone della perla che pulsa
var pul = 0.5 + 0.5 * dsin(current_time * 0.36);
gpu_set_blendmode(bm_add);
draw_set_alpha(ga * (0.15 + 0.12 * pul));
draw_set_colour(make_colour_rgb(160, 150, 255));
draw_circle(x, y, 20 + 4 * pul, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(ga);

// ensō a pennello che GIRA: piu' perde vita, meno il cerchio si chiude
var hpf = clamp(hp / hp_p2, 0, 1);
var sweep = 330 * (0.35 + 0.65 * hpf);   // quanti gradi copre la pennellata
var start = 215 + enso_rot;              // da dove parte il pennello: gira sempre
var segs = 40;
var ink = make_colour_rgb(225, 215, 190);
var shake = (hp < hp_p2 / 2) ? 1 : 0;    // arrabbiato: il tratto trema
draw_set_colour(ink);
for (var s = 0; s < segs; s++) {
    var u0 = s / segs;
    var u1 = (s + 1) / segs;
    if (u0 > 0.6 && s mod 4 == 3) continue;   // pennello secco: la fine del tratto si spezza
    var r0 = 27 + 2 * sin(u0 * 7) + random_range(-shake, shake);
    var r1 = 27 + 2 * sin(u1 * 7) + random_range(-shake, shake);
    var a0 = start + sweep * u0;
    var a1 = start + sweep * u1;
    var w = 2 + 7 * power(1 - u0, 0.7);       // pieno all'inizio, sottile alla fine
    var x0 = x + lengthdir_x(r0, a0), y0 = y + lengthdir_y(r0, a0);
    var x1 = x + lengthdir_x(r1, a1), y1 = y + lengthdir_y(r1, a1);
    draw_line_width(x0, y0, x1, y1, w);
    if (u0 < 0.6) draw_circle(x1, y1, w / 2, false);   // giunture morbide dove l'inchiostro e' carico
}

// la perla: il punto debole. Lampeggia bianca quando la colpisci
var pf = (pearl_flash > 0) ? 1 : 0;
draw_set_colour(merge_colour(make_colour_rgb(60, 50, 90), c_white, pf));
draw_circle(x, y, 11, false);
draw_set_colour(merge_colour(make_colour_rgb(150, 140, 200), c_white, pf));
draw_circle(x, y, 7.5, false);
draw_set_colour(make_colour_rgb(240, 240, 255));
draw_circle(x, y, 4, false);

// le due carpe: avorio a macchie d'oro, oro a macchie d'inchiostro (questa carica e si lancia)
var glow = (lunge_t > 0 && lunge_t < 30 && (lunge_t div 4) mod 2 == 0) ? 1 : 0;
koi_draw(0, make_colour_rgb(240, 232, 215), make_colour_rgb(225, 175, 60), 0, ga);
koi_draw(1, make_colour_rgb(225, 175, 60), make_colour_rgb(14, 10, 20), glow, ga);
draw_set_alpha(1);
draw_set_colour(c_white);
