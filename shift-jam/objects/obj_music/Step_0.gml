/// Oggetto persistente della musica (lo crea scr_music da solo, non va messo nelle stanze).
// 1. si fermano davvero i suoni che hanno finito di sfumare
for (var i = array_length(global.music_fading) - 1; i >= 0; i--) {
    if (current_time >= global.music_fading[i][1]) {
        audio_stop_sound(global.music_fading[i][0]);
        array_delete(global.music_fading, i, 1);
    }
}
// 2. rete di sicurezza per i punti di loop: se la piattaforma li ignora (puo' succedere nel browser),
//    quando il brano passa la fine del pezzo da ripetere lo riporto indietro a mano
if (global.music != -1 && audio_is_playing(global.music)) {
    var lp = global.music_loops[$ global.music_name];
    if (!is_undefined(lp)) {
        var pos = audio_sound_get_track_position(global.music);
        if (pos >= lp[1] + 0.05) audio_sound_set_track_position(global.music, pos - (lp[1] - lp[0]));
    }
}
