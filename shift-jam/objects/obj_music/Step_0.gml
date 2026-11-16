/// Oggetto persistente della musica (lo crea scr_music da solo, non va messo nelle stanze).
// 1. si fermano davvero i suoni che hanno finito di sfumare
for (var i = array_length(global.music_fading) - 1; i >= 0; i--) {
    if (current_time >= global.music_fading[i][1]) {
        audio_stop_sound(global.music_fading[i][0]);
        array_delete(global.music_fading, i, 1);
    }
}
// 2. i LOOP (il menu' e il boss) si ripetono da soli: li fa il motore audio (global.music_loops in scr_music).
// 3. dalla Ost al loop del boss: quando la Ost arriva alla fine parte il loop, attaccato e da capo
//    (music_where in scr_music)
if (global.music != -1 && !global.music_noloop && global.music_name == MUSIC_TRACK) {
    if (audio_is_playing(global.music)) {
        global.music_ost_pos = audio_sound_get_track_position(global.music);
        // manca meno di un fotogramma e mezzo alla fine: il loop parte adesso e la Ost sfuma in 20 ms
        if (global.music_ost_pos >= OST_LEN - 0.025) music_jump(max(0, global.music_ost_pos - OST_LEN), 20, MUSIC_BOSS);
    } else if (global.music_ost_pos >= OST_LEN - 0.5) {
        // la Ost e' finita tra un fotogramma e l'altro (il gioco ha rallentato): il loop parte subito
        music_play(MUSIC_BOSS, 0, 0);
    }
}
