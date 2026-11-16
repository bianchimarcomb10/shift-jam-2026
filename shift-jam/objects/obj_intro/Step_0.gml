t += 1;

switch (state) {
case 0:   // titolo: aspetta SHIFT
    if (keyboard_check_pressed(vk_shift)) {
        state = 1; t = 0;
        audio_play_sound(snd_menu, 5, false, SFX_GAIN);
    }
    break;

case 1:   // il titolo sfuma nel nero in 2/3 di secondo
    if (t >= 40) { state = 2; t = 0; }
    break;

case 2:   // la frase resta 5 secondi (compare e svanisce piano)
    if (t >= 300) { state = 3; t = 0; }
    break;

case 3:   // al posto della frase: "Press SHIFT"
    if (keyboard_check_pressed(vk_shift)) {
        state = 4; t = 0;
        audio_master_gain(1);   // volume pieno solo per questo momento
        // l'esplosione di stelle: snd_menu alzato di 12 dB (snd_star_burst), cosi' si sente forte quanto la musica
        audio_play_sound(snd_star_burst, 5, false, STAR_BURST_GAIN);
        // la musica del menu' sfuma nell'esplosione di stelle. Il volume generale e' appena salito a 1:
        // la dissolvenza parte da MUSIC_GAIN x GAME_MASTER, cosi' la musica non fa un salto
        music_stop(MUSIC_MENU_FADE, MUSIC_GAIN * GAME_MASTER);
    }
    break;

case 4:   // le stelle si accendono sempre piu' in fretta e crescono finche' riempiono tutto il cielo
    if (t == 1) {
        // griglia di quadratini da 12 px: una stella in ognuno, in un punto a caso del quadratino
        var cs = 12;
        for (var gx = 0; gx < room_width; gx += cs) {
            for (var gy = 0; gy < room_height; gy += cs) {
                array_push(cells, [gx + random(cs), gy + random(cs)]);
            }
        }
        // mescola l'ordine, cosi' le stelle si accendono sparse e non a righe
        for (var i = array_length(cells) - 1; i > 0; i--) {
            var j = irandom(i);
            var tmp = cells[i]; cells[i] = cells[j]; cells[j] = tmp;
        }
    }
    // sempre piu' stelle per fotogramma: all'inizio poche, poi una pioggia
    repeat (1 + t div 14) {
        if (next_cell < array_length(cells)) {
            var c = cells[next_cell];
            array_push(stars, [c[0], c[1], t]);
            next_cell += 1;
        }
    }
    // quando anche l'ultima stella e' cresciuta del tutto il cielo e' bianco: si va a terra
    if (next_cell >= array_length(cells) && t >= stars[array_length(stars) - 1][2] + star_grow + 20) {
        room_goto(rm_ground);   // la fase a terra parte dal bianco
    }
    break;
}
