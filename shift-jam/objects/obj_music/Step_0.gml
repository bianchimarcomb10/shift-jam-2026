/// Oggetto persistente della musica (lo crea scr_music da solo, non va messo nelle stanze).
// 1. si fermano davvero i suoni che hanno finito di sfumare
for (var i = array_length(global.music_fading) - 1; i >= 0; i--) {
    if (current_time >= global.music_fading[i][1]) {
        audio_stop_sound(global.music_fading[i][0]);
        array_delete(global.music_fading, i, 1);
    }
}
// 2. i RITORNI (global.music_loops in scr_music): quando il brano arriva alla fine del pezzo che si ripete,
//    riparte una copia dal punto di ritorno e le due si incrociano per pochi centesimi di secondo
if (global.music != -1 && !global.music_noloop && audio_is_playing(global.music)) {
    var lp = global.music_loops[$ global.music_name];
    if (!is_undefined(lp)) {
        var pos = audio_sound_get_track_position(global.music);
        if (pos >= lp[1] - lp[2]) music_jump(pos - (lp[1] - lp[0]), lp[2] * 1000);
    }
}
