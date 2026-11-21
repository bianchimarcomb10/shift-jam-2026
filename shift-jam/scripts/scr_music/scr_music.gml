/// MUSICA di Cubesando, cinque brani e il suono del game over:
///   mus_intenso      (59,8 s)  "Mood Intenso", sul titolo (Chelios, 16-11 sera): parte da capo e poi gira in loop
///                              (TITLE_LOOP_START/END) finche' non si va avanti; sfuma nell'esplosione di stelle (obj_intro)
///   mus_main_menu    (15,8 s)  al decollo suona UNA volta: e' l'attacco della partita (obj_ground)
///   mus_ost_in_sync  (4:25,6)  attaccata subito alla fine della musica del menu', senza spazio (obj_music)
///   mus_boss_loop    (53,1 s)  attaccato subito alla fine della Ost, in loop finche' il boss e' vivo (29 misure a 131 bpm)
///   mus_finale       (25,2 s)  quando il boss muore; il loop del boss sfuma (obj_finale)
///   mus_game_over    (3,9 s)   quando lo scafo cede (obj_player): la musica sfuma in fretta e parte questo (21-11)
/// Il tempo della partita (obj_game, mus_t) parte dal decollo: music_where dice quale brano deve suonare e dove.
/// Scaletta:
///   titolo: mus_intenso in loop. Esplosione di stelle: la musica sfuma in 4 s mentre sale l'esplosione cinematica
///   prologo col mecha: niente musica (c'e' la sirena). Quando gli alieni ti sommergono: l'esplosione cinematica
///   decollo (il mecha e' esploso ed e' diventato navicella): mus_main_menu una volta, poi la Ost attaccata
///   game over: la musica sfuma in GAMEOVER_MUSIC_FADE e suona mus_game_over (gameover_play, obj_player).
///              Se premi SHIFT prima che finisca, sfuma in GAMEOVER_STOP_FADE mentre riparte la partita (obj_game)
///   fine della Ost (4:41,5 dal decollo): il loop del boss, attaccato (obj_music)
///   boss abbattuto: parte mus_finale e il loop del boss sfuma in 2 s (MUSIC_BOSS_FADE, obj_finale)
/// Dal decollo la Ost cade dove cadeva la stessa musica nel brano unico di stamattina (16-11): 15,8 s dopo.

/// VOLUMI (il musicista, 16-11: "musica troppo bassa, alzerei 4/5 dB").
/// I file sono gia' masterizzati forte (picco -1 dB): il volume si alza nel gioco, non nei file.
/// Prima: musica 0.8 x volume generale 0.4 = 0.32. Ora: 1.0 x 0.54 = 0.54, cioe' +4,5 dB.
/// Gli effetti sonori si moltiplicano per SFX_GAIN (0.4 / 0.54), cosi' restano forti come prima.
/// Il VOLUME GENERALE resta GAME_MASTER dal titolo alla fine del gioco (16-11 sera). Prima nel prologo era 0.4,
/// all'esplosione 0.75 e al titolo saliva a 1: ma l'esplosione cinematica dura 8 s, e ogni cambio del volume
/// generale l'avrebbe fatta saltare a meta'. Gli effetti del prologo ora passano per SFX_GAIN come quelli della
/// partita, quindi si sentono come prima.
#macro MUSIC_GAIN 1.0                         // volume della musica (era 0.8)
#macro GAME_MASTER 0.54                       // volume generale, dal titolo alla fine (era 0.4)
#macro SFX_GAIN 0.74                          // 0.4 / 0.54: gli effetti sonori come prima

/// L'ESPLOSIONE CINEMATICA (snd_explosion_cinematic, 8,3 s; Chelios, 16-11 sera: "abbastanza alto").
/// Sale per 3,3 s, poi il colpo e il boato fino a 7 s. Al volume pieno e' circa 5 dB sopra la musica del titolo.
/// Sul titolo parte da capo alla pressione di SHIFT: il colpo cade quando le stelle hanno riempito il cielo.
/// Nel prologo il colpo deve arrivare subito, quando premi SHIFT: si parte da EXPLOSION_GROUND_FROM.
#macro EXPLOSION_GAIN 1.0                     // 1.0 = il massimo
#macro EXPLOSION_GROUND_FROM 3.25             // secondi. 0 = da capo anche li', ma il colpo arriverebbe a decollo gia' iniziato

#macro MUSIC_TITLE "mus_intenso"              // il titolo: "Mood Intenso"
#macro MUSIC_MENU "mus_main_menu"             // si chiama cosi', ma ora e' l'attacco della partita al decollo
#macro MUSIC_TRACK "mus_ost_in_sync"          // la partita, dal decollo
#macro MUSIC_BOSS "mus_boss_loop"             // il loop del boss
#macro MUSIC_FINALE "mus_finale"              // il finale
#macro MENU_LEN 15.832063                     // quanto dura la musica del menu' (s)
#macro OST_LEN 265.6489                       // quanto dura la Ost (s)
#macro BOSS_LEN 53.129796                     // quanto dura un giro del loop del boss (s)
#macro MUSIC_TITLE_FADE 4000                  // la musica del titolo sfuma nell'esplosione (le stelle durano 5,3 s)
#macro MUSIC_BOSS_FADE 2000                   // alla morte del boss il loop sfuma mentre parte il finale
#macro GAMEOVER_MUSIC_FADE 300                // game over: la musica se ne va in fretta, perche' il suono di Cubesando
                                              // parte subito pieno e non si deve impastare col brano (era 1500)
#macro GAMEOVER_GAIN 1.0                      // volume del suono del game over (1 = come la musica)
#macro GAMEOVER_STOP_FADE 400                 // premi SHIFT prima che finisca: sfuma mentre riparte la partita
#macro GAMEOVER_LOCK 45                       // i primi 0,75 s dopo il game over lo SHIFT non fa ripartire (obj_game Step)

/// IL LOOP DEL TITOLO. Mood Intenso comincia quasi in silenzio (i primi 2 s) e il file finisce mentre la musica
/// va ancora: ripetere tutto il file farebbe un buco. Si ripetono invece 12 misure, da 24,93 a 57,91 s:
/// 32,98 s, il periodo con cui il brano si ripete. I due punti sono sul campione (a 44100 al secondo) dove l'onda
/// combacia, cosi' il salto non fa click. Li usa il motore audio di GameMaker (music_play).
#macro TITLE_LOOP_START (1099245 / 44100)
#macro TITLE_LOOP_END (2553720 / 44100)
#macro MUSIC_AT_TAKEOFF true   // la scaletta parte al decollo della navicella (false = quando hai il comando, inizio di rm_game)

/// I BRANI NOMINATI UNO PER UNO. Qui sotto la musica si chiama per nome, tra virgolette (MUSIC_MENU...).
/// Ma nelle Game Options e' acceso "Automatically remove unused assets when compiling": quando compila,
/// GameMaker butta via le risorse che il codice non nomina direttamente, e un nome tra virgolette non conta.
/// Per questo nella 16-NOV-J la musica non si sentiva: GameMaker l'aveva tolta dal gioco. Questa riga la tiene dentro.
/// Se aggiungi un brano, mettilo anche qui.
global.music_assets = [mus_intenso, mus_main_menu, mus_ost_in_sync, mus_boss_loop, mus_finale];

/// LA SCALETTA DAL DECOLLO (Chelios, 16-11 sera): [brano, quanto dura in secondi], uno dopo l'altro.
/// Ogni brano attacca appena finisce quello prima, senza spazio (obj_music); l'ultimo si ripete finche' serve.
global.music_plan = [
    [MUSIC_MENU, MENU_LEN],    // la musica del menu', una volta sola
    [MUSIC_TRACK, OST_LEN],    // la Ost
    [MUSIC_BOSS, BOSS_LEN]     // il loop del boss
];
/// I LOOP li fa il motore audio di GameMaker (audio_play_sound con loop acceso): ogni giro attacca preciso
/// anche se il gioco rallenta. Si ripetono il loop del boss e, sul titolo, Mood Intenso (obj_intro).
global.music = -1;          // il brano che suona ora (l'istanza del suono), -1 = nessuno
global.music_name = "";
global.music_looping = false;   // il brano che suona si ripete da solo (loop del motore audio)?
global.music_fading = [];   // suoni che stanno sfumando: [istanza, quando fermarli]
global.siren = -1;          // la sirena del prologo, -1 = spenta
global.gameover_snd = -1;   // il suono del game over che sta suonando, -1 = nessuno
global.amb_wind = -1;       // vento del prologo (ambience_start), -1 = spento
global.amb_swarm = -1;      // sciame del prologo
global.amb_swarm_g = 0;     // quanto e' forte lo sciame adesso (0..1), segue piano gli alieni
global.amb_beat_next = 0;   // fotogrammi al prossimo battito
global.music_noloop = false;  // true = niente piu' passaggio al brano dopo (boss abbattuto)
global.music_shift = 0;     // di quanti secondi la scaletta e' partita prima di rm_game (il decollo, MUSIC_AT_TAKEOFF)
global.music_t0 = 0;        // current_time dell'ultima partenza o dell'ultimo salto (subito dopo, la posizione non e' affidabile)
global.music_follow_log = [];   // quando music_follow ha dovuto correggere (current_time)
global.music_follow_off = false; // true = smette di correggere (vedi music_follow)
global.music_end_pos = 0;   // l'ultimo punto letto del brano che suona (obj_music: per attaccare quello dopo)

/// Quale brano deve suonare, e dove, quando sono passati _t secondi dal decollo: [nome, secondi].
/// Segue global.music_plan: la musica del menu', la Ost, poi il loop del boss che ricomincia finche' serve.
function music_where(_t) {
    _t = max(0, _t);
    var n = array_length(global.music_plan);
    for (var i = 0; i < n - 1; i++) {
        var len = global.music_plan[i][1];
        if (_t < len) return [global.music_plan[i][0], _t];
        _t -= len;
    }
    return [global.music_plan[n - 1][0], _t mod global.music_plan[n - 1][1]];
}

/// Dove sta il brano _name nella scaletta (global.music_plan); -1 = non c'e' (il finale)
function music_plan_index(_name) {
    for (var i = 0; i < array_length(global.music_plan); i++) if (global.music_plan[i][0] == _name) return i;
    return -1;
}

/// true se _t (secondi dal decollo) e' a meno di 1 s da un attacco tra due brani della scaletta
function music_near_seam(_t) {
    var s = 0;
    for (var i = 0; i < array_length(global.music_plan) - 1; i++) {
        s += global.music_plan[i][1];
        if (abs(_t - s) < 1) return true;
    }
    return false;
}

/// l'oggetto persistente che attacca un brano della scaletta a quello prima e chiude le dissolvenze (passa da una stanza all'altra)
function music_ensure() {
    if (!instance_exists(obj_music)) instance_create_depth(0, 0, 0, obj_music);
    if (!instance_exists(obj_pause)) instance_create_depth(0, 0, 0, obj_pause);   // pausa (P/ESC) e audio muto (M), scr_pause
}

/// Fa partire un brano da _offset_s secondi. Quello di prima sfuma in _fade_ms millisecondi
/// (0 = si ferma di colpo) e il nuovo entra con la stessa dissolvenza.
/// Se sta gia' suonando, non lo fa ripartire.
/// _loop: si ripete da solo? Se non lo dici: si' il loop del boss, no tutti gli altri
/// (il titolo lo chiede per Mood Intenso, che gira tra TITLE_LOOP_START e TITLE_LOOP_END).
function music_play(_name, _fade_ms = 0, _offset_s = 0, _loop = undefined) {
    if (asset_get_type(_name) != asset_sound) {   // il brano non c'e' nel gioco: lo dice nella finestra Output
        show_debug_message("MUSICA: manca " + string(_name) + " (vedi global.music_assets in scr_music)");
        return false;
    }
    if (is_undefined(_loop)) _loop = (_name == MUSIC_BOSS);
    global.music_noloop = false;   // un brano che (ri)parte torna a fare i passaggi
    if (global.music_name == _name && global.music != -1 && audio_is_playing(global.music)) return true;
    music_ensure();
    var snd = asset_get_index(_name);
    if (_name == MUSIC_TITLE) {
        // il loop del titolo: suona da capo fino a TITLE_LOOP_END, poi riparte sempre da TITLE_LOOP_START
        audio_sound_loop_start(snd, TITLE_LOOP_START);
        audio_sound_loop_end(snd, TITLE_LOOP_END);
    }
    music_stop(_fade_ms);
    global.music = audio_play_sound(snd, 100, _loop, (_fade_ms > 0) ? 0 : MUSIC_GAIN, max(0, _offset_s));
    if (_fade_ms > 0) audio_sound_gain(global.music, MUSIC_GAIN, _fade_ms);
    global.music_name = _name;
    global.music_looping = _loop;
    global.music_t0 = current_time;
    global.music_end_pos = 0;
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
    global.music_looping = false;
}

/// Porta il brano che suona a _offset_s secondi con una dissolvenza incrociata di _xf_ms millisecondi:
/// parte una seconda copia dal punto nuovo mentre quella di prima sfuma.
/// Con _name passa a un altro brano nello stesso modo (il brano dopo nella scaletta, obj_music).
function music_jump(_offset_s, _xf_ms, _name = global.music_name) {
    if (global.music == -1 || !audio_is_playing(global.music)) return;
    if (asset_get_type(_name) != asset_sound) return;
    music_ensure();
    var lp = (_name == global.music_name) ? global.music_looping : (_name == MUSIC_BOSS);
    var old = global.music;
    global.music_name = _name;
    global.music_looping = lp;
    global.music = audio_play_sound(asset_get_index(_name), 100, lp, 0, max(0, _offset_s));
    audio_sound_gain(global.music, MUSIC_GAIN, _xf_ms);
    audio_sound_gain(old, 0, _xf_ms);
    array_push(global.music_fading, [old, current_time + _xf_ms + 30]);
    global.music_t0 = current_time;
    global.music_end_pos = 0;
}

/// Tiene la musica al passo con la partita. _t: secondi dal decollo (obj_game, mus_t); music_where dice cosa e dove.
/// Se il brano e' finito o si e' perso (la scheda del browser era nascosta a lungo) riparte dal punto giusto.
/// Se e' avanti o indietro di piu' di mezzo secondo (il gioco ha rallentato, la finestra si e' fermata)
/// salta al punto giusto con una dissolvenza breve.
/// Vicino alle cuciture (fine di un brano della scaletta, attacco di un giro del loop) non fa niente:
/// li' ci pensano obj_music e il motore audio.
function music_follow(_t) {
    if (music_near_seam(_t)) return;                         // il passaggio da un brano a quello dopo: obj_music
    var w = music_where(_t);
    if (global.music == -1 || !audio_is_playing(global.music)) { music_play(w[0], 300, w[1]); return; }
    if (global.music_name != w[0]) { music_play(w[0], 300, w[1]); return; }
    if (global.music_follow_off) return;
    if (current_time - global.music_t0 < 1000) return;   // appena partito o saltato: aspetto che si assesti
    var pos = audio_sound_get_track_position(global.music);
    var d = pos - w[1];
    var k = music_plan_index(global.music_name);
    if (global.music_looping && k >= 0) {
        var len = global.music_plan[k][1];
        if (pos > len - 1 || w[1] > len - 1 || pos < 1 || w[1] < 1) return;   // vicino all'attacco del giro
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
    audio_sound_gain(global.siren, 0.6 * SFX_GAIN, 400);   // entra in mezzo secondo (SFX_GAIN: forte come prima)
}
/// IL GAME OVER (Cubesando, 21-11): mus_game_over, 3,9 s, una volta sola. Lo chiama obj_player quando lo scafo cede,
/// subito dopo music_stop(GAMEOVER_MUSIC_FADE). Il file finisce nel silenzio: dopo resta solo SHIFT TO STRUGGLE.
function gameover_play() {
    gameover_stop(0);
    global.gameover_snd = audio_play_sound(mus_game_over, 10, false, GAMEOVER_GAIN * MUSIC_GAIN);
}

/// ferma il suono del game over, sfumando in _fade_ms (0 = di colpo). Da obj_game, quando premi SHIFT per ripartire
function gameover_stop(_fade_ms = GAMEOVER_STOP_FADE) {
    if (global.gameover_snd == -1) return;
    if (audio_is_playing(global.gameover_snd)) {
        if (_fade_ms > 0) {
            music_ensure();
            audio_sound_gain(global.gameover_snd, 0, _fade_ms);
            array_push(global.music_fading, [global.gameover_snd, current_time + _fade_ms]);
        } else {
            audio_stop_sound(global.gameover_snd);
        }
    }
    global.gameover_snd = -1;
}

function siren_stop(_fade_ms = 300) {
    if (global.siren == -1) return;
    music_ensure();
    audio_sound_gain(global.siren, 0, _fade_ms);
    array_push(global.music_fading, [global.siren, current_time + _fade_ms]);
    global.siren = -1;
}

/// I SUONI DELL'ACCERCHIAMENTO nel prologo (Chelios, 16-11 notte: "e' troppo silenzioso... no musica").
/// Tre strati generati da tools/prologue_sounds.py, nessun file di terzi:
///   snd_wind       il vento tra le rovine, basso, per tutto il prologo (entra in 2 s dal bianco)
///   snd_swarm      lo sciame: chele, zampette, ronzio. Il volume segue quanti alieni ci sono e quanti
///                  sono aggrappati al mecha: con 60 e' al massimo
///   snd_heartbeat  un battito cupo che parte quando l'accerchiamento (obj_ground.bar) arriva a BEAT_FROM
///                  e accelera fino a uno ogni 0,42 s; continua sotto la sirena
/// Alla pressione di SHIFT si spengono tutti in 60 ms, come la sirena: resta l'esplosione.
/// Bozza ascoltata da Chelios: https://claude.ai/artifact/AwLpHnu8fvn3d582E9pkRj
#macro WIND_GAIN 0.31        // il vento (sotto GAME_MASTER: circa -34 LUFS, un fondo)
#macro SWARM_GAIN 0.85       // lo sciame al massimo
#macro SWARM_FULL 60         // alieni (piu' quelli aggrappati) per lo sciame al massimo
#macro BEAT_GAIN 0.83        // il battito piu' forte (all'inizio e' al 55%)
#macro BEAT_FROM 0.15        // l'accerchiamento a cui parte il battito (circa 5 s dopo l'inizio)

/// obj_ground Create: parte il vento, lo sciame e' pronto ma muto
function ambience_start() {
    ambience_stop(0);
    music_ensure();
    global.amb_wind = audio_play_sound(snd_wind, 40, true, 0);
    audio_sound_gain(global.amb_wind, WIND_GAIN, 2000);
    global.amb_swarm = audio_play_sound(snd_swarm, 40, true, 0);
    global.amb_swarm_g = 0;
    global.amb_beat_next = 0;
}

/// obj_ground Step, finche' non premi SHIFT: _aliens = alieni sullo schermo (piu' gli aggrappati),
/// _bar = l'accerchiamento (0..1)
function ambience_update(_aliens, _bar) {
    var target = power(clamp(_aliens / SWARM_FULL, 0, 1), 0.7);
    global.amb_swarm_g = lerp(global.amb_swarm_g, target, 0.03);   // segue piano: niente scatti
    if (global.amb_swarm != -1) audio_sound_gain(global.amb_swarm, SWARM_GAIN * global.amb_swarm_g, 0);
    if (_bar >= BEAT_FROM) {
        var u = clamp((_bar - BEAT_FROM) / (1 - BEAT_FROM), 0, 1);
        global.amb_beat_next -= 1;
        if (global.amb_beat_next <= 0) {
            audio_play_sound(snd_heartbeat, 45, false, BEAT_GAIN * (0.55 + 0.45 * u));
            global.amb_beat_next = round(60 * lerp(1.1, 0.42, u));   // da un battito ogni 1,1 s a uno ogni 0,42
        }
    }
}

/// alla pressione di SHIFT (e all'inizio, per sicurezza): tutto tace
function ambience_stop(_fade_ms = 60) {
    var l = [global.amb_wind, global.amb_swarm];
    for (var i = 0; i < 2; i++) {
        if (l[i] == -1) continue;
        if (_fade_ms > 0 && audio_is_playing(l[i])) {
            music_ensure();
            audio_sound_gain(l[i], 0, _fade_ms);
            array_push(global.music_fading, [l[i], current_time + _fade_ms]);
        } else audio_stop_sound(l[i]);
    }
    audio_stop_sound(snd_heartbeat);
    global.amb_wind = -1;
    global.amb_swarm = -1;
}
