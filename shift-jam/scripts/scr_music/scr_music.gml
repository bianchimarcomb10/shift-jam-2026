/// MUSICA: ogni brano si chiama per NOME. Se il file non c'e' ancora, non succede niente
/// e continua la musica di prima: il gioco funziona anche senza musiche.
/// Per aggiungere un brano: importa in GameMaker un suono (OGG) con uno di questi nomi, e basta.
///
///   mus_title   menu e frase di Linji, in loop. Continua nel prologo a terra
///   mus_ground  prologo a terra, in loop (FACOLTATIVO: se manca continua mus_title)
///               quando il mecha e' sommerso la musica sfuma: si sente solo il silenzio
///   mus_waves   le 17 ondate: un brano unico a tempo fisso (4:06, i tempi sono in obj_game)
///   mus_drill   arrivo della trivella, 15 secondi (FACOLTATIVO: se manca continua mus_waves)
///   mus_boss    il boss, in loop
///   mus_boss2   seconda fase, i Koi, in loop (FACOLTATIVO: se manca continua mus_boss)
///
/// Al game over e nel finale la musica sfuma.

/// PUNTI DI LOOP: se un file ha un'intro e poi la parte che si ripete,
/// scrivi qui i secondi [inizio, fine] del pezzo da ripetere. [0, 0] = si ripete tutto il file.
global.music_loops = {
    mus_title:  [0, 0],
    mus_ground: [0, 0],
    mus_boss:   [0, 0],
    mus_boss2:  [0, 0]
};
global.music = -1;          // il brano che suona ora (l'istanza del suono), -1 = nessuno
global.music_name = "";
global.music_fading = [];   // brani che stanno sfumando: [istanza, quando fermarli]

/// Fa partire un brano. Quello di prima sfuma in _fade_ms millisecondi (0 = si ferma di colpo)
/// e il nuovo entra con la stessa dissolvenza. _offset_s = da che secondo partire.
function music_play(_name, _loop = true, _fade_ms = 0, _offset_s = 0) {
    if (asset_get_type(_name) != asset_sound) return false;   // il file non c'e': resta la musica di prima
    if (global.music_name == _name && audio_is_playing(global.music)) return true;   // sta gia' suonando
    var snd = asset_get_index(_name);
    music_stop(_fade_ms);
    if (_loop && variable_struct_exists(global.music_loops, _name)) {
        var lp = global.music_loops[$ _name];
        if (lp[1] > lp[0]) {
            audio_sound_loop_start(snd, lp[0]);
            audio_sound_loop_end(snd, lp[1]);
        }
    }
    global.music = audio_play_sound(snd, 100, _loop, (_fade_ms > 0) ? 0 : 1, _offset_s);
    if (_fade_ms > 0) audio_sound_gain(global.music, 1, _fade_ms);
    global.music_name = _name;
    return true;
}

/// Ferma il brano che suona, sfumando in _fade_ms millisecondi (0 = di colpo).
function music_stop(_fade_ms = 0) {
    // prima si fermano davvero i brani che hanno finito di sfumare
    for (var i = array_length(global.music_fading) - 1; i >= 0; i--) {
        if (current_time >= global.music_fading[i][1]) {
            audio_stop_sound(global.music_fading[i][0]);
            array_delete(global.music_fading, i, 1);
        }
    }
    if (global.music != -1 && audio_is_playing(global.music)) {
        if (_fade_ms > 0) {
            audio_sound_gain(global.music, 0, _fade_ms);
            array_push(global.music_fading, [global.music, current_time + _fade_ms]);
        } else {
            audio_stop_sound(global.music);
        }
    }
    global.music = -1;
    global.music_name = "";
}
