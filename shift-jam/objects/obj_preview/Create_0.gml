/// Sagome dell'ondata in arrivo: salgono sullo sfondo, lontane e scure,
/// escono dall'alto e poco dopo i nemici veri scendono da li'.
/// Non sono nemici: non si colpiscono e non colpiscono.
items = [];    // [sprite, scostamento x, scostamento y, scala]
spd = 4.5;     // pixel per fotogramma verso l'alto
tint = make_colour_rgb(70, 60, 110);
fade = 0.55;
depth = 95;    // sotto le stelle bianche (90), sopra lo sfondo (100)
