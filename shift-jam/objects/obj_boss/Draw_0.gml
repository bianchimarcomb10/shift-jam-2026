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
// teschio
draw_set_colour(make_colour_rgb(225, 215, 190));
draw_circle(x, y, 26, false);
draw_set_colour(c_black);
draw_circle(x - 9, y - 4, 6, false);
draw_circle(x + 9, y - 4, 6, false);
draw_triangle(x, y + 4, x - 3, y + 11, x + 3, y + 11, false);
// mani giunte, dorate: sono loro le armi
draw_set_colour(make_colour_rgb(220, 180, 80));
var hg = hands_gap / 2;
draw_rectangle(x - 8 - hg, y + 30, x - hg, y + 54, false);
draw_rectangle(x + hg, y + 30, x + 8 + hg, y + 54, false);
draw_set_alpha(1);
