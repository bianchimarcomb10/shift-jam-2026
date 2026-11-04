t += 1;

switch (state) {
case 0:
    if (flash > 0) flash = max(0, flash - 1 / 60);   // dissolvenza dal bianco in 1 secondo
    // --- arrivano alieni dall'alto e dai lati, sempre piu' spesso ---
    spawn_timer -= 1;
    if (spawn_timer <= 0) {
        var n = 1 + t div 600;   // ogni 10 secondi un alieno in piu' per gruppo
        if (mass) n = 6;         // ondata finale: una marea
        repeat (n) {
            var side = irandom(2);
            var sx, sy;
            if (side == 0)      { sx = random(room_width); sy = -10; }
            else if (side == 1) { sx = -10; sy = random(ground_y); }
            else                { sx = room_width + 10; sy = random(ground_y); }
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
        flash = 1;
        boom_x = obj_mech_ground.x;   // centro dell'esplosione
        boom_y = obj_mech_ground.y;
        with (obj_grunt) instance_destroy();
        obj_mech_ground.transformed = true;
        audio_play_sound(snd_explosion_big, 10, false);
        audio_play_sound(snd_shift, 9, false);
    }
    break;

case 2:
    // --- esplosione: lampo bianco che svanisce in 1 secondo ---
    flash = 1 - t / 60;
    if (t >= 60) { flash = 0; state = 3; t = 0; }
    break;

case 3:
    // --- la navicella vola via da sola; fuori dallo schermo parte lo spazio ---
    if (obj_mech_ground.y < -40) room_goto(rm_game);
    break;
}
