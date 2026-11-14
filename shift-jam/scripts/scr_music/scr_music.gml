/// MUSICA di Cubesando (richiesta di Chelios, 2026-11-13). Due brani:
///   mus_incitante  sul titolo, poi dal decollo per tutte le ondate. Comincia con la SALITA (0 - 9 s),
///                  poi si ripete solo la seconda parte: da 9,089 s a 106,716 s (48 battute a 118 bpm).
///   mus_intenso    da quando arriva la trivella, per tutto il boss. Prima volta tutto dall'inizio,
///                  poi si ripete da 24,927 s a 57,909 s (12 battute a 87,3 bpm).
/// Scaletta:
///   titolo e frase di Linji: mus_incitante; nell'esplosione di stelle dello start sfuma fino al bianco
///   prologo col mecha: SILENZIO. Quando compare SHIFT TO STRUGGLE: la sirena (snd_siren, in loop)
///   premuto SHIFT: la sirena tace e mus_incitante riparte dall'inizio col decollo
///   la trivella: mus_incitante sfuma su "Silence is near.", mus_intenso parte quando la trivella compare
///   finale: la musica sfuma. Al game over la musica continua.
///
/// I PUNTI DI LOOP sono qui sotto, in secondi: [inizio, fine] del pezzo che si ripete.
/// Se la cucitura non ti piace, cambia questi numeri e basta.

#macro MUSIC_GAIN 0.8   // volume della musica (gli effetti sonori non cambiano)

global.music_loops = {
    mus_incitante: [9.089, 106.716],
    mus_intenso:   [24.927, 57.909]
};
global.music = -1;          // il brano che suona ora (l'istanza del suono), -1 = nessuno
global.music_name = "";
global.music_fading = [];   // suoni che stanno sfumando: [istanza, quando fermarli]
global.siren = -1;          // la sirena del prologo, -1 = spenta

/// l'oggetto persistente che fa i loop e chiude le dissolvenze (passa da una stanza all'altra)
function music_ensure() {
    if (!instance_exists(obj_music)) instance_create_depth(0, 0, 0, obj_music);
}

/// Fa partire un brano dall'inizio (o da _offset_s secondi). Quello di prima sfuma in _fade_ms
/// millisecondi (0 = si ferma di colpo) e il nuovo entra con la stessa dissolvenza.
/// Se sta gia' suonando, non lo fa ripartire.
function music_play(_name, _fade_ms = 0, _offset_s = 0) {
    if (asset_get_type(_name) != asset_sound) return false;   // il file non c'e': resta com'e'
    if (global.music_name == _name && global.music != -1 && audio_is_playing(global.music)) return true;
    music_ensure();
    var snd = asset_get_index(_name);
    music_stop(_fade_ms);
    var lp = global.music_loops[$ _name];
    if (!is_undefined(lp)) {
        audio_sound_loop_start(snd, lp[0]);
        audio_sound_loop_end(snd, lp[1]);
    }
    global.music = audio_play_sound(snd, 100, true, (_fade_ms > 0) ? 0 : MUSIC_GAIN, _offset_s);
    if (_fade_ms > 0) audio_sound_gain(global.music, MUSIC_GAIN, _fade_ms);
    global.music_name = _name;
    return true;
}

/// Ferma il brano che suona, sfumando in _fade_ms millisecondi (0 = di colpo).
/// _from: da che volume parte la dissolvenza (-1 = da quello che ha adesso).
function music_stop(_fade_ms = 0, _from = -1) {
    if (global.music != -1 && audio_is_playing(global.music)) {
        if (_from >= 0) audio_sound_gain(global.music, _from, 0);
        if (_fade_ms > 0) {
            music_ensure();
            audio_sound_gain(global.music, 0, _fade_ms);
            array_push(global.music_fading, [global.music, current_time + _fade_ms]);
        } else {
            audio_stop_sound(global.music);
        }
    }
    global.music = -1;
    global.music_name = "";
}

/// La sirena del prologo: un allarme che sale e scende, in loop finche' non la spegni.
function siren_start() {
    if (global.siren != -1 && audio_is_playing(global.siren)) return;
    global.siren = audio_play_sound(snd_siren, 50, true, 0);
    audio_sound_gain(global.siren, 0.6, 400);   // entra in mezzo secondo
}
function siren_stop(_fade_ms = 300) {
    if (global.siren == -1) return;
    music_ensure();
    audio_sound_gain(global.siren, 0, _fade_ms);
    array_push(global.music_fading, [global.siren, current_time + _fade_ms]);
    global.siren = -1;
}
