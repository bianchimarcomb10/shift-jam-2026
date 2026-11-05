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

// 3. LA TERRA (ondate 4-10): il pianeta che brucia sotto di noi. Sale dal fondo, poi rimpicciolisce:
//    ce ne stiamo andando
if (alt > 3 && alt < 11) {
    var rise = clamp((alt - 3) / 2, 0, 1);
    var away = clamp((alt - 5) / 5, 0, 1);
    var sc = lerp(3, 0.6, away);                              // da grande a piccolo
    var ex = w / 2 + 40 * away;
    var ey = lerp(h + 100 * sc, h - 150, rise) + 40 * away;
    var ea = 1 - clamp((alt - 10), 0, 1);                     // svanisce alla fine
    // alone: l'atmosfera in fiamme
    draw_set_alpha(earth_glow * ea);
    draw_set_colour(make_colour_rgb(255, 110, 50));
    draw_circle(ex, ey, 36 * sc, false);
    // lo sprite (96 x 96, origine in alto a sinistra) ruota piano
    var fr = (current_time div 110) mod 77;
    draw_sprite_ext(spr_bg_earth, fr, ex - 48 * sc, ey - 48 * sc, sc, sc, 0, c_white, ea);
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
