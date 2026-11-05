/// Il cielo cambia mentre si sale: prima l'atmosfera della Terra che brucia,
/// poi la curva del pianeta che sprofonda, poi lo spazio, infine un vuoto sempre piu' scuro.
/// E' un segnaposto disegnato col codice: il grafico potra' sostituirlo con livelli di tile.
depth = 96;        // sopra lo sfondo (100), sotto le sagome (95) e le stelle (90)
alt = 0;           // "altitudine": segue il numero dell'ondata, ma senza scatti
clouds = [];
for (var i = 0; i < 9; i++) {
    clouds[i] = [random(room_width), random_range(-room_height, room_height), random_range(50, 110), random_range(2, 4)];
}
// colori del cielo (dall'alto in basso): violetto in cima, brace della Terra in fondo
sky_top = make_colour_rgb(40, 30, 80);
sky_bottom = make_colour_rgb(200, 90, 50);
