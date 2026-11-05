/// Sagome dell'ondata in arrivo: salgono sullo sfondo dal basso,
/// escono dall'alto e poco dopo i nemici veri scendono da li'.
/// Davanti l'ondata vera (chiara), dietro l'orda (piccola e scura): sono troppi.
/// Non sono nemici: non si colpiscono e non colpiscono.
items = [];    // [sprite, scostamento x, scostamento y, scala, 1 = ondata vera / 0 = orda]
spd = 3.5;     // pixel per fotogramma verso l'alto
tint_wave = make_colour_rgb(150, 120, 200);
tint_horde = make_colour_rgb(80, 60, 120);
t = 0;
depth = 95;    // sotto le stelle bianche (90), sopra lo sfondo (100)
