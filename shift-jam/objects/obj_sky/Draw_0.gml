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
var cloud_a = clamp(1 - (alt - 2) / 3, 0, 1) * 0.85;
if (cloud_a > 0) {
    for (var i = 0; i < array_length(clouds); i++) {
        var cl = clouds[i];
        // lo sprite ha l'origine in alto a sinistra (80 x 48): lo centro sul punto della nuvola
        draw_sprite_ext(spr_bg_clouds, cl[2], cl[0] - 40, cl[1] - 24, 1, 1, 0, c_white, cloud_a);
    }
}

// 3. LA TERRA: tolta per ora (2026-11-05). In mezzo alle nuvole non avrebbe senso vederla.
//    Lo sprite spr_bg_earth resta nel progetto, se poi si decide dove metterla.

// 4. IL VUOTO (dall'ondata 12 al boss): lo spazio si spegne verso il Silenzio
var dark = clamp((alt - 11) / 6, 0, 0.6);
if (dark > 0) {
    draw_set_alpha(dark);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, w, h, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);
