t += 1;

switch (state) {
case 0:
    if (flash > 0) flash = max(0, flash - 1 / 60);   // dissolvenza dal bianco in 1 secondo
    // --- arrivano alieni da tutti e quattro i bordi, sempre piu' spesso ---
    spawn_timer -= 1;
    if (spawn_timer <= 0) {
        var n = 1 + t div 120;   // ogni 2 secondi un alieno in piu' per gruppo (prima ogni 3: ora sono circa il doppio)
        if (mass) n = 8;         // ondata finale: una marea
        repeat (n) {
            var side = irandom(3);
            var sx, sy;
            if (side == 0)      { sx = random(room_width); sy = -10; }
            else if (side == 1) { sx = -10; sy = random(room_height); }
            else if (side == 2) { sx = room_width + 10; sy = random(room_height); }
            else                { sx = random(room_width); sy = room_height + 10; }
            instance_create_layer(sx, sy, "Instances", obj_grunt);
        }
        if (mass) spawn_timer = 3;
        else {
            spawn_interval = max(10, spawn_interval - 1);
            spawn_timer = spawn_interval;
        }
    }

    var clinging = 0;
    with (obj_grunt) if (clinging_now) clinging += 1;

    if (!mass) {
        // l'accerchiamento (non si vede piu': la barra in alto e' stata tolta) sale col tempo e per ogni alieno
        // aggrappato, ma prima dell'ondata si ferma all'85%
        bar = min(0.85, bar + 0.0005 + clinging * 0.0012);
        // l'ondata finale parte a 8 secondi, o prima se la barra e' gia' all'85% (ma mai prima dei 5)
        if (t >= mass_time || (bar >= 0.85 && t >= 300)) mass = true;
    } else {
        // durante l'ondata la barra si riempie in poco piu' di un secondo
        bar += 0.012;
        if (bar >= 1) { bar = 1; state = 1; t = 0; siren_start(); }   // SHIFT TO STRUGGLE: suona la sirena
    }
    break;

case 1:
    // --- sommerso: tutto si ferma, si aspetta SHIFT ---
    if (keyboard_check_pressed(vk_shift)) {
        state = 2;
        t = 0;
        flash = 0;
        boom_x = obj_mech_ground.x;   // centro dell'esplosione
        boom_y = obj_mech_ground.y;
        obj_mech_ground.transformed = true;
        siren_stop(60);                  // la sirena tace di colpo...
        audio_master_gain(0.75);         // ...e l'esplosione si sente forte (poi GAME_MASTER al decollo, scr_music)
        audio_play_sound(snd_explosion_big, 10, false);
        audio_play_sound(snd_shift, 9, false);
        // niente musica nel decollo: il brano parte quando hai il comando della navicella (rm_game)
    }
    break;

case 2:
    // --- esplosione a stelle, come all'inizio: ogni alieno scoppia in una stella bianca,
    //     poi le stelle si accendono dal mecha verso i bordi finche' riempiono lo schermo ---
    if (t == 1) {
        with (obj_grunt) {
            array_push(other.stars, [x, y, 1]);
            instance_destroy();
        }
        var cs = 12;
        for (var gx = 0; gx < room_width; gx += cs) {
            for (var gy = 0; gy < room_height; gy += cs) {
                var px = gx + random(cs);
                var py = gy + random(cs);
                array_push(cells, [px, py, point_distance(px, py, boom_x, boom_y) + random(90)]);
            }
        }
        array_sort(cells, function(_a, _b) { return _a[2] - _b[2]; });   // prima le piu' vicine al mecha
    }
    repeat (2 + t div 2) {
        if (next_cell < array_length(cells)) {
            var c = cells[next_cell];
            array_push(stars, [c[0], c[1], t]);
            next_cell += 1;
        }
    }
    // schermo tutto bianco: si toglie il velo e la navicella vola via
    if (next_cell >= array_length(cells) && t >= stars[array_length(stars) - 1][2] + star_grow + 10) {
        stars = [];
        flash = 1;
        state = 3;
        t = 0;
        // PROVA: il brano parte qui, quando il mecha e' diventato navicella e vola via (MUSIC_AT_TAKEOFF in scr_music)
        audio_master_gain(GAME_MASTER);   // l'esplosione e' finita da un pezzo: il volume di quando c'e' la musica (scr_music)
        if (MUSIC_AT_TAKEOFF) { music_play(MUSIC_TRACK, 0, 0); global.music_shift = -current_time; }
    }
    break;

case 3:
    // --- la navicella vola via da sola; fuori dallo schermo parte lo spazio ---
    // il terreno scende sempre piu' in fretta: si capisce che la navicella sta salendo
    if (flash > 0) flash = max(0, flash - 1 / 50);   // il bianco svanisce in poco meno di un secondo
    scroll += min(6, 0.5 + scroll * 0.03);
    if (ground_layer != -1) layer_y(ground_layer, ground_base + scroll);
    // si resta finche' la frase di Dogen non e' svanita (6 secondi: non si accorcia)
    if (t >= 360 && obj_mech_ground.y < -40) room_goto(rm_game);
    break;
}
