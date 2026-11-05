draw_set_circle_precision(64);   // cerchi grandi senza spigoli
var w = room_width;
var h = room_height;

// 1. ATMOSFERA (ondate 1-6): cielo a fasce, si dirada tra l'ondata 3 e la 7
var air = clamp(1 - (alt - 3) / 4, 0, 1);
if (air > 0) {
    var bands = 16;   // fasce nette, non una sfumatura: resta pixel art
    for (var b = 0; b < bands; b++) {
        draw_set_colour(merge_colour(sky_top, sky_bottom, b / (bands - 1)));
        draw_set_alpha(air);
        draw_rectangle(0, h * b / bands, w, h * (b + 1) / bands, false);
    }
}

// 2. NUVOLE (ondate 1-5): sempre meno, sempre piu' trasparenti
var cloud_a = clamp(1 - (alt - 2) / 3, 0, 1) * 0.55;
if (cloud_a > 0) {
    for (var i = 0; i < array_length(clouds); i++) {
        var cl = clouds[i];
        var r = cl[2];
        draw_set_alpha(cloud_a);
        draw_set_colour(make_colour_rgb(230, 170, 150));
        draw_ellipse(cl[0] - r, cl[1] - r * 0.3, cl[0] + r, cl[1] + r * 0.3, false);
        draw_set_colour(make_colour_rgb(250, 210, 190));
        draw_ellipse(cl[0] - r * 0.6, cl[1] - r * 0.45, cl[0] + r * 0.4, cl[1] + r * 0.1, false);
    }
}

// 3. LA TERRA (ondate 4-9): la curva del pianeta sotto di noi, che brucia e sprofonda
if (alt > 3 && alt < 10) {
    var R = 900;
    var rise = clamp((alt - 3) / 2, 0, 1);                 // compare da sotto
    var sink = clamp((alt - 6) / 4, 0, 1);                 // poi si allontana
    var top_y = h - 140 * rise + 260 * sink;               // dove sta il bordo del pianeta
    draw_set_alpha(clamp(rise - sink * 0.5, 0, 1));
    draw_set_colour(make_colour_rgb(255, 110, 60));        // bagliore: l'atmosfera in fiamme
    draw_circle(w / 2, top_y + R - 6, R + 6, false);
    draw_set_colour(make_colour_rgb(30, 40, 70));          // il lato in ombra
    draw_circle(w / 2, top_y + R, R, false);
    draw_set_colour(make_colour_rgb(255, 150, 70));        // incendi sulla superficie
    for (var f = 0; f < 7; f++) {
        var fx = w * (f + 0.5) / 7 + dsin(f * 71) * 20;
        draw_circle(fx, top_y + 14 + (f mod 3) * 10, 2, false);
    }
}

// 4. IL VUOTO (dall'ondata 12 al boss): lo spazio si spegne verso il Silenzio
var dark = clamp((alt - 11) / 6, 0, 0.6);
if (dark > 0) {
    draw_set_alpha(dark);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, w, h, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);
