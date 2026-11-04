if (phase == 1) {
    // ===== NAVE MADRE =====
    draw_set_colour(make_colour_rgb(70, 60, 90));
    draw_rectangle(x - 80, y - 26, x + 80, y + 26, false);
    draw_triangle(x - 80, y - 26, x - 100, y, x - 80, y + 26, false);
    draw_triangle(x + 80, y - 26, x + 100, y, x + 80, y + 26, false);
    draw_set_colour(make_colour_rgb(100, 90, 125));
    draw_rectangle(x - 60, y - 40, x + 60, y - 26, false);
    // cannoni laterali
    draw_set_colour(c_dkgray);
    draw_rectangle(x - 64, y + 20, x - 56, y + 34, false);
    draw_rectangle(x + 56, y + 20, x + 64, y + 34, false);
    // hangar
    draw_set_colour(c_black);
    draw_rectangle(x - 18, y + 14, x + 18, y + 26, false);
    // nel centro pulsa qualcosa di chiaro: e' cio' che sta dentro
    draw_set_colour(make_colour_rgb(225, 215, 190));
    draw_circle(x, y - 4, 6 + sin(t / 10), false);
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
