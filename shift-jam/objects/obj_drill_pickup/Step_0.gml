// dove piantarsi: la testa del mecha (il cappello)
var tx = instance_exists(obj_player) ? obj_player.x : room_width / 2;
var ty = instance_exists(obj_player) ? obj_player.y - 8 : room_height * 0.7;

if (planted) {
    boom += 1;
    if (boom >= 30) instance_destroy();
    exit;
}

t += 1;
if (t <= hover) {
    // 1) compare dall'alto ENORME e scende piano, girando, scivolando sopra di te
    ph += 4;
    var kh = t / hover;
    y = lerp(-40, 210, 1 - (1 - kh) * (1 - kh));   // rallenta arrivando: alla fine si vede tutta, enorme
    x = lerp(x, tx, 0.03);
    hx = x;
    hy = y;
} else {
    // 2) PIOMBA: accelera e si rimpicciolisce, e arriva esattamente sul mecha dopo 3 s,
    //    anche se ti sposti (insegue la tua posizione fino all'ultimo)
    ph += 14;
    var kp = min(1, (t - hover) / (dur - hover));
    var e = kp * kp;   // parte piano e accelera
    x = lerp(hx, tx, e);
    y = lerp(hy, ty, e);
    sc = lerp(8, sc_end, e);
}

if (t >= dur) {
    // 3) SI PIANTA: diventa l'arma del mecha
    planted = true;
    x = tx;
    y = ty;
    global.has_drill = true;
    with (obj_player) {
        if (form == 0 && transform_timer == 0) transform_timer = 6;        // la trivella e' del mecha: la navicella si trasforma
        else if (form == 1 && transform_timer > 0) transform_timer = 0;    // stavi diventando navicella: resti mecha
        shift_flash = 12;
        invuln = max(invuln, 60);
    }
    with (obj_game) {
        drill_state = 2;
        drill_phrase = 270;   // "YOUR DRILL IS THE DRILL THAT WILL PIERCE THE HEAVENS!"
    }
    audio_play_sound(snd_explosion_big, 9, false, 0.6);
    audio_play_sound(snd_shift, 9, false, 1);
}
