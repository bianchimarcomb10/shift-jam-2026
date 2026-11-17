/// Begin Step: prima di tutti gli altri, cosi' la pausa ferma anche questo fotogramma.

// M: audio si' / no, ovunque (anche in pausa)
if (keyboard_check_pressed(ord("M"))) {
    global.muted = !global.muted;
    master_gain_apply();   // scr_pause
    mute_msg = 90;         // 1,5 s di scritta in alto
}
if (mute_msg > 0) mute_msg -= 1;

if (!keyboard_check_pressed(ord("P")) && !keyboard_check_pressed(vk_escape)) exit;

if (!global.paused) {
    if (!game_can_pause()) exit;   // titolo, finale, game over, esplosione e decollo del prologo: no
    global.paused = true;
    pause_t0 = current_time;
    // la fotografia: lo schermo come era al fotogramma prima (il cruscotto no: quello lo ridisegna obj_game)
    if (sprite_exists(pause_spr)) sprite_delete(pause_spr);
    pause_spr = -1;
    if (surface_exists(application_surface)) {
        pause_spr = sprite_create_from_surface(application_surface, 0, 0,
            surface_get_width(application_surface), surface_get_height(application_surface), false, false, 0, 0);
    }
    // lo sfondo di stelle scorre da solo (layer_vspeed, obj_starfield): si ferma anche lui
    pause_layers = [];
    var ls = layer_get_all();
    for (var i = 0; i < array_length(ls); i++) {
        var hs = layer_get_hspeed(ls[i]), vs = layer_get_vspeed(ls[i]);
        if (hs != 0 || vs != 0) {
            array_push(pause_layers, [ls[i], hs, vs]);
            layer_hspeed(ls[i], 0);
            layer_vspeed(ls[i], 0);
        }
    }
    audio_pause_all();             // musica, sirena, vento, effetti: tutto fermo dove si trova
    instance_deactivate_all(true); // tutti fermi tranne questo...
    instance_activate_object(obj_game);     // ...e quelli che servono al cruscotto e alla barra del boss:
    instance_activate_object(obj_player);   // nel loro Step escono subito finche' global.paused e' vero
    instance_activate_object(obj_boss);
    audio_play_sound(snd_pause, 5, false, SFX_GAIN);
} else {
    global.paused = false;
    var dt = current_time - pause_t0;
    global.pause_ms += dt;
    instance_activate_all();
    // le dissolvenze in corso e il controllo della musica contano col current_time (scr_music):
    // si spostano avanti di quanto e' durata la pausa, cosi' riprendono da dove erano
    for (var i = 0; i < array_length(global.music_fading); i++) {
        var f = global.music_fading[i];
        f[@ 1] += dt;
    }
    global.music_t0 += dt;
    for (var i = 0; i < array_length(pause_layers); i++) {
        layer_hspeed(pause_layers[i][0], pause_layers[i][1]);
        layer_vspeed(pause_layers[i][0], pause_layers[i][2]);
    }
    pause_layers = [];
    if (sprite_exists(pause_spr)) sprite_delete(pause_spr);
    pause_spr = -1;
    audio_resume_all();
    audio_play_sound(snd_resume, 5, false, SFX_GAIN);
}
