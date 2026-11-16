/// Oggetto persistente della musica (lo crea scr_music da solo, non va messo nelle stanze).
// 1. si fermano davvero i suoni che hanno finito di sfumare
for (var i = array_length(global.music_fading) - 1; i >= 0; i--) {
    if (current_time >= global.music_fading[i][1]) {
        audio_stop_sound(global.music_fading[i][0]);
        array_delete(global.music_fading, i, 1);
    }
}
// 2. la SCALETTA dal decollo (global.music_plan in scr_music): quando un brano arriva alla fine parte quello dopo,
//    attaccato e da capo, senza spazio: dalla musica del menu' alla Ost, dalla Ost al loop del boss.
//    I loop (il boss, e il menu' sul titolo) si ripetono da soli: li fa il motore audio.
if (global.music != -1 && !global.music_noloop && !global.music_looping) {
    var k = music_plan_index(global.music_name);
    if (k >= 0 && k < array_length(global.music_plan) - 1) {
        var len = global.music_plan[k][1];
        var nx = global.music_plan[k + 1][0];
        if (audio_is_playing(global.music)) {
            global.music_end_pos = audio_sound_get_track_position(global.music);
            // manca meno di un fotogramma e mezzo alla fine: il brano dopo parte adesso e questo sfuma in 20 ms
            if (global.music_end_pos >= len - 0.025) music_jump(max(0, global.music_end_pos - len), 20, nx);
        } else if (global.music_end_pos >= len - 0.5) {
            // finito tra un fotogramma e l'altro (il gioco ha rallentato): quello dopo parte subito
            music_play(nx, 0, 0);
        }
    }
}
