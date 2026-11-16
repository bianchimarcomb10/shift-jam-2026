/// MUSICA di Cubesando, i quattro brani (consegnati il 16-11-2026, sera: MUSIC.zip):
///   mus_main_menu    (15,8 s)  il menu' principale, in loop; sfuma nell'esplosione di stelle (obj_intro)
///   mus_ost_in_sync  (4:25,6)  dal decollo della navicella (obj_ground), come il brano di prima
///   mus_boss_loop              attaccato subito alla fine della Ost, in loop finche' il boss e' vivo.
///                              NON C'E' ANCORA (non era nello zip): finche' manca, dopo la Ost suona il pezzo del boss
///                              del brano di prima (mus_shift_into_silence), che e' la stessa musica (vedi music_where)
///   mus_finale       (25,2 s)  quando il boss muore; il loop del boss sfuma (obj_finale)
/// La Ost e' il brano di prima senza i primi 15,832 s (diventati la musica del menu'): Ost a 0:00 = vecchio brano a 0:15,832.
/// Il tempo della partita (obj_game, mus_t) parte dal decollo: music_where dice quale brano deve suonare e dove.
/// Scaletta:
///   titolo: mus_main_menu in loop. Esplosione di stelle: sfuma in 4 s
///   prologo col mecha: niente musica (c'e' la sirena). Decollo: parte la Ost
///   game over: sfuma in 1,5 s (obj_player). Qui andra' il suono di game over di 5 s del musicista
///   fine della Ost (4:25,6 dal decollo): il loop del boss, attaccato (obj_music)
///   boss abbattuto: parte mus_finale e il loop del boss sfuma in 2 s (MUSIC_BOSS_FADE, obj_finale)

/// VOLUMI (il musicista, 16-11: "musica troppo bassa, alzerei 4/5 dB").
/// I file sono gia' masterizzati forte (picco -1 dB): il volume si alza nel gioco, non nei file.
/// Prima: musica 0.8 x volume generale 0.4 = 0.32. Ora: 1.0 x 0.54 = 0.54, cioe' +4,5 dB.
/// Gli effetti sonori si moltiplicano per SFX_GAIN (0.4 / 0.54), cosi' restano forti come prima.
#macro MUSIC_GAIN 1.0                         // volume della musica (era 0.8)
#macro GAME_MASTER 0.54                       // volume generale quando c'e' la musica: titolo, e dal decollo a tutto rm_game (era 0.4)
#macro SFX_GAIN 0.74                          // 0.4 / 0.54: gli effetti sonori come prima

#macro MUSIC_MENU "mus_main_menu"             // il menu' principale
#macro MUSIC_TRACK "mus_ost_in_sync"          // la partita, dal decollo
#macro MUSIC_BOSS "mus_boss_loop"             // il loop del boss (quando arriva il file: sounds/mus_boss_loop)
#macro MUSIC_FINALE "mus_finale"              // il finale
#macro OST_LEN 265.6489                       // quanto dura la Ost (s): qui comincia il loop del boss
#macro OST_FROM 15.832                        // la Ost a 0:00 e' il brano di prima a 0:15,832
#macro MUSIC_MENU_FADE 4000                   // la musica del menu' sfuma nell'esplosione di stelle (dura 5,3 s)
#macro MUSIC_BOSS_FADE 2000                   // alla morte del boss il loop sfuma mentre parte il finale
#macro MUSIC_AT_TAKEOFF true   // la Ost parte al decollo della navicella (false = quando hai il comando, inizio di rm_game)

/// I LOOP, in secondi: [torna qui, arrivato qui, dissolvenza incrociata]. Li fa obj_music.
/// Il menu' ricomincia da capo. mus_boss_loop: quando arriva il file, aggiungere qui [0, la sua durata, 0.02].
/// mus_shift_into_silence (solo finche' manca il loop del boss): 5:38,19 torna a 4:21,24, stessa battuta (131 bpm).
global.music_loops = {
    mus_main_menu: [0, 15.8320, 0.02],
    mus_shift_into_silence: [261.2450, 338.1916, 0.15]
};
global.music = -1;          // il brano che suona ora (l'istanza del suono), -1 = nessuno
global.music_name = "";
global.music_fading = [];   // suoni che stanno sfumando: [istanza, quando fermarli]
global.siren = -1;          // la sirena del prologo, -1 = spenta
global.music_noloop = false;  // true = niente piu' ritorni ne' passaggi al brano dopo (boss abbattuto)
global.music_shift = 0;     // di quanti secondi la Ost e' partita prima di rm_game (il decollo, MUSIC_AT_TAKEOFF)
global.music_t0 = 0;        // current_time dell'ultima partenza o dell'ultimo salto (subito dopo, la posizione non e' affidabile)
global.music_follow_log = [];   // quando music_follow ha dovuto correggere (current_time)
global.music_follow_off = false; // true = smette di correggere (vedi music_follow)

/// Quale brano deve suonare, e dove, quando sono passati _t secondi dal decollo: [nome, secondi].
/// Prima la Ost; dalla sua fine il loop del boss, che ricomincia finche' serve.
function music_where(_t) {
    _t = max(0, _t);
    if (_t < OST_LEN) return [MUSIC_TRACK, _t];
    var b = _t - OST_LEN;
    var lp;
    if (asset_get_type(MUSIC_BOSS) == asset_sound) {
        lp = global.music_loops[$ MUSIC_BOSS];
        if (!is_undefined(lp) && b >= lp[1]) b = lp[0] + (b - lp[0]) mod (lp[1] - lp[0]);
        return [MUSIC_BOSS, b];
    }
    // manca il loop del boss: il brano di prima dal punto dove finisce la Ost (4:41,48), col suo ritorno 5:38 -> 4:21
    var p = b + OST_LEN + OST_FROM;
    lp = global.music_loops.mus_shift_into_silence;
    if (p >= lp[1]) p = lp[0] + (p - lp[0]) mod (lp[1] - lp[0]);
    return ["mus_shift_into_silence", p];
}

/// l'oggetto persistente che fa i ritorni e chiude le dissolvenze (passa da una stanza all'altra)
function music_ensure() {
    if (!instance_exists(obj_music)) instance_create_depth(0, 0, 0, obj_music);
}

/// Fa partire un brano da _offset_s secondi. Quello di prima sfuma in _fade_ms millisecondi
/// (0 = si ferma di colpo) e il nuovo entra con la stessa dissolvenza.
/// Se sta gia' suonando, non lo fa ripartire.
/// Niente loop del motore audio: i ritorni li fa obj_music, con la dissolvenza incrociata.
function music_play(_name, _fade_ms = 0, _offset_s = 0) {
    if (asset_get_type(_name) != asset_sound) return false;   // il file non c'e': resta com'e'
    global.music_noloop = false;   // un brano che (ri)parte torna a fare i ritorni
    if (global.music_name == _name && global.music != -1 && audio_is_playing(global.music)) return true;
    music_ensure();
    var snd = asset_get_index(_name);
    music_stop(_fade_ms);
    global.music = audio_play_sound(snd, 100, false, (_fade_ms > 0) ? 0 : MUSIC_GAIN, max(0, _offset_s));
    if (_fade_ms > 0) audio_sound_gain(global.music, MUSIC_GAIN, _fade_ms);
    global.music_name = _name;
    global.music_t0 = current_time;
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

/// Porta il brano che suona a _offset_s secondi con una dissolvenza incrociata di _xf_ms millisecondi:
/// parte una seconda copia dal punto nuovo mentre quella di prima sfuma.
/// Con _name passa a un altro brano nello stesso modo (dalla Ost al loop del boss, obj_music).
function music_jump(_offset_s, _xf_ms, _name = global.music_name) {
    if (global.music == -1 || !audio_is_playing(global.music)) return;
    if (asset_get_type(_name) != asset_sound) return;
    music_ensure();
    var old = global.music;
    global.music_name = _name;
    global.music = audio_play_sound(asset_get_index(_name), 100, false, 0, max(0, _offset_s));
    audio_sound_gain(global.music, MUSIC_GAIN, _xf_ms);
    audio_sound_gain(old, 0, _xf_ms);
    array_push(global.music_fading, [old, current_time + _xf_ms + 30]);
    global.music_t0 = current_time;
}

/// Tiene la musica al passo con la partita. _t: secondi dal decollo (obj_game, mus_t); music_where dice cosa e dove.
/// Se il brano e' finito o si e' perso (la scheda del browser era nascosta a lungo) riparte dal punto giusto.
/// Se e' avanti o indietro di piu' di mezzo secondo (il gioco ha rallentato, la finestra si e' fermata)
/// salta al punto giusto con una dissolvenza breve.
/// Vicino alle cuciture (fine della Ost, ritorni dei loop) non fa niente: li' ci pensa obj_music.
function music_follow(_t) {
    var w = music_where(_t);
    if (global.music == -1 || !audio_is_playing(global.music)) { music_play(w[0], 300, w[1]); return; }
    if (abs(_t - OST_LEN) < 1) return;                       // il passaggio dalla Ost al loop del boss
    if (global.music_name != w[0]) { music_play(w[0], 300, w[1]); return; }
    if (global.music_follow_off) return;
    if (current_time - global.music_t0 < 1000) return;   // appena partito o saltato: aspetto che si assesti
    var pos = audio_sound_get_track_position(global.music);
    var d = pos - w[1];
    var lp = global.music_loops[$ global.music_name];
    if (!is_undefined(lp)) {
        if (pos > lp[1] - 1 || w[1] > lp[1] - 1 || pos < lp[0] + 1 || w[1] < lp[0] + 1) return;
        var len = lp[1] - lp[0];
        d = ((d mod len) + len * 1.5) mod len - len * 0.5;   // lo stesso punto in due giri diversi
    }
    if (abs(d) <= 0.5) return;
    // rete di sicurezza: se deve correggere piu' di 3 volte in 20 s c'e' qualcosa che non va
    // (un computer molto lento, o la posizione letta e' sbagliata): smette, invece di far balbettare la musica
    var jl = global.music_follow_log;
    for (var i = array_length(jl) - 1; i >= 0; i--) if (current_time - jl[i] > 20000) array_delete(jl, i, 1);
    if (array_length(jl) >= 3) { global.music_follow_off = true; return; }
    array_push(jl, current_time);
    music_jump(w[1], 150);
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
