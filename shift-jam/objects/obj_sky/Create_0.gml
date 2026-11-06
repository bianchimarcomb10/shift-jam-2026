/// Il cielo cambia mentre si sale: prima l'atmosfera della Terra che brucia,
/// poi la curva del pianeta che sprofonda, poi lo spazio, infine un vuoto sempre piu' scuro.
/// Pianeta: Earth-Like planet di Foozle (CC0), ricolorato. Nuvole: RocketNinjaGames (CC0), ricolorate.
depth = 96;        // sopra lo sfondo (100), sotto le sagome (95) e le stelle (90)
alt = variable_global_exists("checkpoint") ? global.checkpoint : 0;   // "altitudine": segue il numero dell'ondata, senza scatti (dal checkpoint si riparte gia' in alto)
clouds = [];       // [x, y, fotogramma, velocita']
for (var i = 0; i < 9; i++) {
    clouds[i] = [random(room_width), random_range(-room_height, room_height), irandom(5), random_range(2, 4)];
}
earth_glow = 0.25; // alone arancio attorno alla Terra: 0 = niente, 0.5 = forte
// colori del cielo (dall'alto in basso): violetto in cima, brace della Terra in fondo
sky_top = make_colour_rgb(40, 30, 80);
sky_bottom = make_colour_rgb(200, 90, 50);
