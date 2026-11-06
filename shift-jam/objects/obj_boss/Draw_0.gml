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
    draw_set_alpha((60 - transition) / 60);   // poi il Custode appare piano
}

// ===== IL CUSTODE =====
var blink = (stun > 0 && (stun div 4) mod 2 == 0);   // lampeggia quando e' stordito
if (blink) draw_set_alpha(0.4);

// mala: 108 grani in cerchio
draw_set_colour(make_colour_rgb(150, 110, 70));
for (var j = 0; j < 108; j++) {
    var a = bead_angle + j * (360 / 108);
    draw_circle(x + lengthdir_x(70, a), y + lengthdir_y(70, a), 2, false);
}
// ensō: un cerchio a pennello, l'unico corpo del Custode.
// piu' perde vita, meno il cerchio si chiude: la pennellata si accorcia verso il vuoto
var hpf = clamp(hp / hp_p2, 0, 1);
var sweep = 330 * (0.35 + 0.65 * hpf);   // quanti gradi copre la pennellata
var start = 215;                          // il pennello parte in basso a sinistra
var segs = 40;
var ink = make_colour_rgb(225, 215, 190);
var shake = (hp < hp_p2 / 2) ? 1 : 0;    // arrabbiato: il tratto trema
draw_set_colour(ink);
for (var s = 0; s < segs; s++) {
    var u0 = s / segs;
    var u1 = (s + 1) / segs;
    if (u0 > 0.6 && s mod 4 == 3) continue;   // pennello secco: la fine del tratto si spezza
    var r0 = 30 + 2 * sin(u0 * 7) + random_range(-shake, shake);
    var r1 = 30 + 2 * sin(u1 * 7) + random_range(-shake, shake);
    var a0 = start + sweep * u0;
    var a1 = start + sweep * u1;
    var w = 2 + 8 * power(1 - u0, 0.7);       // pieno all'inizio, sottile alla fine
    var x0 = x + lengthdir_x(r0, a0), y0 = y + lengthdir_y(r0, a0);
    var x1 = x + lengthdir_x(r1, a1), y1 = y + lengthdir_y(r1, a1);
    draw_line_width(x0, y0, x1, y1, w);
    if (u0 < 0.6) draw_circle(x1, y1, w / 2, false);   // giunture morbide dove l'inchiostro e' carico
}

// mani giunte, dorate, al centro del cerchio: sono loro le armi.
// si aprono un poco mentre caricano (hands_gap)
var hg = 1 + hands_gap / 4;
var gold = make_colour_rgb(220, 180, 80);
var gold_dark = make_colour_rgb(120, 90, 30);
for (var side = -1; side <= 1; side += 2) {
    var xi = x + side * hg;          // bordo interno: le dita
    var xo = x + side * (hg + 8);    // bordo esterno: il dorso
    draw_set_colour(gold);
    draw_triangle(xo, y + 13, xi, y + 13, xi, y - 14, false);
    draw_triangle(xo, y + 13, xo, y - 3, xi, y - 14, false);
    draw_set_colour(gold_dark);
    draw_line(xo - side * 2, y + 6, xi - side, y);   // il pollice
}
draw_set_alpha(1);
