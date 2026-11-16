/// MUSICA di Cubesando, versione finale (consegnata il 16-11-2026): UN SOLO BRANO, mus_shift_into_silence (5:56).
/// E' scritto sulla scaletta fissa della partita (obj_game Create: wave_secs e seq_len), quindi deve stare al passo:
///   0:00  hai il comando della navicella (inizio di rm_game)      0:02  prima ondata
///   1:33  la nave enorme                                          1:57  l'ondata dopo la nave (checkpoint)
///   4:06  "Silence is near." (checkpoint del boss)                4:15,5 sale la sagoma della nave madre
///   4:21  il boss: il suo tema entra a 4:21,24
/// Scaletta:
///   titolo, prologo col mecha, decollo: NIENTE musica (la sirena del prologo resta: e' un effetto sonoro)
///   rm_game: il brano parte da 0:00, o dopo un game over dal punto giusto (obj_game Create, mus_t)
///   game over: sfuma in 1,5 s (obj_player). Qui andra' il suono di game over di 5 s del musicista
///   boss lungo: arrivato a 5:38,19, prima della chiusa del brano, torna a 4:21,24 (global.music_loops, obj_music)
///   boss abbattuto: il brano sfuma fino al silenzio in 10 s (MUSIC_FINALE_FADE, obj_finale).
///   (Dalla PR #59 andava avanti fino alla sua chiusa; il musicista, 16-11, lo vuole sfumare subito.)

/// VOLUMI (il musicista, 16-11: "musica troppo bassa, alzerei 4/5 dB").
/// Il file del brano e' gia' masterizzato forte (picco -1 dB): il volume si alza nel gioco, non nel file.
/// Prima: musica 0.8 x volume generale 0.4 = 0.32. Ora: 1.0 x 0.54 = 0.54, cioe' +4,5 dB.
/// Gli effetti sonori di rm_game si moltiplicano per SFX_GAIN (0.4 / 0.54), cosi' restano forti come prima.
#macro MUSIC_GAIN 1.0                         // volume della musica (era 0.8)
#macro GAME_MASTER 0.54                       // volume generale mentre c'e' la musica: dal decollo a tutto rm_game (era 0.4)
#macro SFX_GAIN 0.74                          // 0.4 / 0.54: gli effetti sonori di rm_game come prima
/// FINALE (il musicista, 16-11: "quando il boss muore cominciare a mettere il fade alla musica",
/// per arrivare prima al silenzio): alla morte del boss il brano sfuma fino al silenzio in questi millisecondi.
/// 10 s: il silenzio arriva quando le stelle si fermano, prima della poesia di Ryokan (obj_finale).
#macro MUSIC_FINALE_FADE 10000
#macro MUSIC_TRACK "mus_shift_into_silence"   // il brano della partita
#macro MUSIC_AT_TAKEOFF true   // PROVA di Chelios (16-11): il brano parte al decollo della navicella, non all'inizio di rm_game.
                               // false = come prima (parte quando hai il comando)

/// I PUNTI DI RITORNO, in secondi: [torna qui, arrivato qui, dissolvenza incrociata].
/// 5:38,19 e 4:21,24 cadono sulla stessa battuta della griglia (131 bpm): sono 168 battute, 42 misure.
/// La dissolvenza (0,15 s) finisce un attimo prima del colpo che apre il tema del boss.
/// Si puo' ascoltare la cucitura in /mnt/project-files/audio-prove/cucitura_loop_boss_finale.ogg (a 0:12).
global.music_loops = {
    mus_shift_into_silence: [261.2450, 338.1916, 0.15]
};
global.music = -1;          // il brano che suona ora (l'istanza del suono), -1 = nessuno
global.music_name = "";
global.music_fading = [];   // suoni che stanno sfumando: [istanza, quando fermarli]
global.siren = -1;          // la sirena del prologo, -1 = spenta
global.music_noloop = false;  // true = niente piu' ritorni: il brano va fino alla fine e si spegne da solo (boss abbattuto)
global.music_shift = 0;     // di quanti secondi il brano e' partito prima di rm_game (il decollo, MUSIC_AT_TAKEOFF)
global.music_t0 = 0;        // current_time dell'ultima partenza o dell'ultimo salto (subito dopo, la posizione non e' affidabile)
global.music_follow_log = [];   // quando music_follow ha dovuto correggere (current_time)
global.music_follow_off = false; // true = smette di correggere (vedi music_follow)

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
function music_jump(_offset_s, _xf_ms) {
    if (global.music == -1 || !audio_is_playing(global.music)) return;
    music_ensure();
    var old = global.music;
    global.music = audio_play_sound(asset_get_index(global.music_name), 100, false, 0, max(0, _offset_s));
    audio_sound_gain(global.music, MUSIC_GAIN, _xf_ms);
    audio_sound_gain(old, 0, _xf_ms);
    array_push(global.music_fading, [old, current_time + _xf_ms + 30]);
    global.music_t0 = current_time;
}

/// Tiene il brano al passo con la partita. _t: dove dovrebbe essere, in secondi (obj_game, mus_t).
/// Se e' avanti o indietro di piu' di mezzo secondo (il gioco ha rallentato, la finestra si e' fermata,
/// la scheda del browser era nascosta) salta al punto giusto con una dissolvenza breve.
/// Vicino alla cucitura del ritorno non fa niente: li' ci pensa obj_music.
function music_follow(_t) {
    if (global.music_follow_off) return;
    if (global.music == -1 || !audio_is_playing(global.music)) return;
    if (current_time - global.music_t0 < 1000) return;   // appena partito o saltato: aspetto che si assesti
    var pos = audio_sound_get_track_position(global.music);
    var d = pos - _t;
    var lp = global.music_loops[$ global.music_name];
    if (!is_undefined(lp)) {
        if (pos > lp[1] - 1 || _t > lp[1] - 1) return;
        var len = lp[1] - lp[0];
        if (pos >= lp[0] && _t >= lp[0]) d = ((d mod len) + len * 1.5) mod len - len * 0.5;   // lo stesso punto in due giri diversi
    }
    if (abs(d) <= 0.5) return;
    // rete di sicurezza: se deve correggere piu' di 3 volte in 20 s c'e' qualcosa che non va
    // (un computer molto lento, o la posizione letta e' sbagliata): smette, invece di far balbettare la musica
    var jl = global.music_follow_log;
    for (var i = array_length(jl) - 1; i >= 0; i--) if (current_time - jl[i] > 20000) array_delete(jl, i, 1);
    if (array_length(jl) >= 3) { global.music_follow_off = true; return; }
    array_push(jl, current_time);
    music_jump(_t, 150);
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
