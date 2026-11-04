t += 1;

switch (state) {
case 0:
    if (flash > 0) flash = max(0, flash - 1 / 60);   // dissolvenza dal bianco in 1 secondo
    // --- arrivano alieni da tutti e quattro i bordi, sempre piu' spesso ---
    spawn_timer -= 1;
    if (spawn_timer <= 0) {
        var n = 1 + t div 600;   // ogni 10 secondi un alieno in piu' per gruppo
        if (mass) n = 6;         // ondata finale: una marea
        repeat (n) {
            var side = irandom(3);
            var sx, sy;
            if (side == 0)      { sx = random(room_width); sy = -10; }
            else if (side == 1) { sx = -10; sy = random(room_height); }
            else if (side == 2) { sx = room_width + 10; sy = random(room_height); }
            else                { sx = random(room_width); sy = room_height + 10; }
            instance_create_layer(sx, sy, "Instances", obj_grunt);
        }
        if (mass) spawn_timer = 4;
        else {
            spawn_interval = max(12, spawn_interval - 1);
            spawn_timer = spawn_interval;
        }
    }

    var clinging = 0;
    with (obj_grunt) if (clinging_now) clinging += 1;

    if (!mass) {
        // la barra sale col tempo e per ogni alieno aggrappato, ma prima dell'ondata si ferma all'85%
        bar = min(0.85, bar + 0.0003 + clinging * 0.0008);
        // l'ondata finale parte a 25 secondi, o prima se la barra e' gia' all'85% (ma mai prima dei 15)
        if (t >= mass_time || (bar >= 0.85 && t >= 900)) mass = true;
    } else {
        // durante l'ondata la barra si riempie in circa 3 secondi
        bar += 0.006;
        if (bar >= 1) { bar = 1; state = 1; t = 0; }
    }
    break;

case 1:
    // --- sommerso: tutto si ferma, si aspetta SHIFT ---
    if (keyboard_check_pressed(vk_shift)) {
        state = 2;
        t = 0;
        flash = 0.8;   // lampo breve: deve lasciar vedere gli alieni sbalzati via
        boom_x = obj_mech_ground.x;   // centro dell'esplosione
        boom_y = obj_mech_ground.y;
        // l'esplosione scaglia via tutti gli alieni, lontano dal mecha
        with (obj_grunt) {
            fling = true;
            var fd = point_direction(other.boom_x, other.boom_y, x, y) + random_range(-15, 15);
            var fs = random_range(5, 10);
            fvx = lengthdir_x(fs, fd);
            fvy = lengthdir_y(fs, fd);
            spin = random_range(-20, 20);
        }
        obj_mech_ground.transformed = true;
        audio_play_sound(snd_explosion_big, 10, false);
        audio_play_sound(snd_shift, 9, false);
    }
    break;

case 2:
    // --- esplosione: lampo che svanisce in mezzo secondo, gli alieni volano via ---
    flash = max(0, 0.8 - t / 30);
    if (t >= 70) { flash = 0; state = 3; t = 0; }
    break;

case 3:
    // --- la navicella vola via da sola; fuori dallo schermo parte lo spazio ---
    // il terreno scende sempre piu' in fretta: si capisce che la navicella sta salendo
    scroll += min(6, 0.5 + scroll * 0.03);
    if (ground_layer != -1) layer_y(ground_layer, scroll);
    if (obj_mech_ground.y < -40) room_goto(rm_game);
    break;
}
