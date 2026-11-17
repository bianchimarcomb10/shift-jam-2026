/// PAUSA, AUDIO MUTO, SCOSSA DELLO SCHERMO (ultima rifinitura, Chelios 17-11).
///   P o ESC   pausa: si ferma tutto, gioco e musica insieme. Si puo' nella partita (non nel finale e non al
///             game over) e nel prologo finche' il mecha combatte (poi arrivano esplosione e decollo).
///   M         toglie e rimette l'audio, ovunque: titolo, prologo, partita, pausa.
/// Tasti e disegno della pausa li fa obj_pause, persistente: lo crea music_ensure (scr_music) quando parte il titolo.
///
/// Come funziona la pausa (obj_pause, Begin Step): si fotografa lo schermo (application_surface) e si spengono
/// tutte le istanze (instance_deactivate_all), tranne obj_game e obj_player (il cruscotto legge le loro variabili)
/// e obj_boss (la barra della vita). Quelle tre restano accese per disegnare, ma nel loro Step escono subito finche'
/// global.paused e' vero. La musica si ferma con audio_pause_all e mus_t (obj_game) non avanza: alla ripresa
/// ondate e musica sono ancora allineate. La durata del gioco non cambia.

#macro SHAKE_ON true      // false = niente scossa dello schermo
#macro SHAKE_MAX 3        // pixel al massimo: deve restare leggera, il tono e' elegiaco

global.paused = false;
global.pause_ms = 0;      // millisecondi passati in pausa dall'avvio: chi usa current_time per muovere le cose li toglie (obj_ebullet)
global.muted = false;     // M: audio tolto
global.cleared = false;   // true dopo aver visto il finale: sul titolo resta la stella (obj_intro). Solo per questa sessione
global.shake_t = 0;       // fotogrammi di scossa che restano
global.shake_len = 1;
global.shake_amp = 0;

/// il volume generale: GAME_MASTER (scr_music), oppure zero se hai premuto M.
/// Si chiama al posto di audio_master_gain(GAME_MASTER), cosi' cambiando stanza l'audio tolto resta tolto.
function master_gain_apply() {
    audio_master_gain(global.muted ? 0 : GAME_MASTER);
}

/// si puo' mettere in pausa adesso?
function game_can_pause() {
    if (room == rm_game) return instance_exists(obj_game) && !obj_game.finale && !obj_game.game_over;
    if (room == rm_ground) return instance_exists(obj_ground) && obj_ground.state == 0;
    return false;   // sul titolo no
}

/// SCOSSA DELLO SCHERMO: _px pixel al massimo (mai piu' di SHAKE_MAX), per _frames fotogrammi, e si spegne piano.
/// Solo nella partita: rm_game ha la vista 0 accesa apposta, e obj_game sposta la sua camera (screen_shake_update).
/// Una scossa piu' forte di quella in corso la sostituisce; una piu' debole non la interrompe.
function screen_shake(_px, _frames) {
    if (!SHAKE_ON) return;
    var px = min(_px, SHAKE_MAX);
    if (px * _frames >= global.shake_amp * global.shake_t) {
        global.shake_amp = px;
        global.shake_t = _frames;
        global.shake_len = _frames;
    }
}

/// ogni fotogramma, da obj_game: la camera trema attorno al suo posto e torna ferma a (0, 0)
function screen_shake_update() {
    var cam = view_camera[0];
    if (cam == -1) return;
    if (global.shake_t > 0) {
        global.shake_t -= 1;
        var a = global.shake_amp * global.shake_t / global.shake_len;
        camera_set_view_pos(cam, round(random_range(-a, a)), round(random_range(-a, a)));
    } else {
        camera_set_view_pos(cam, 0, 0);
    }
}
