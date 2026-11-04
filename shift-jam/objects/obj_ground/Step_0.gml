t += 1;

switch (state) {
case 0:
    // --- arrivano alieni da tutti i bordi, sempre piu' spesso ---
    spawn_timer -= 1;
    if (spawn_timer <= 0) {
        var n = 1 + t div 600;   // ogni 10 secondi un alieno in piu' per gruppo
        repeat (n) {
            var side = irandom(3);
            var sx, sy;
            if (side == 0)      { sx = random(room_width); sy = -10; }
            else if (side == 1) { sx = random(room_width); sy = room_height + 10; }
            else if (side == 2) { sx = -10; sy = random(room_height); }
            else                { sx = room_width + 10; sy = random(room_height); }
            instance_create_layer(sx, sy, "Instances", obj_grunt);
        }
        spawn_interval = max(12, spawn_interval - 1);
        spawn_timer = spawn_interval;
    }

    // --- la barra sale col tempo e molto di piu' per ogni alieno aggrappato ---
    var clinging = 0;
    with (obj_grunt) if (clinging_now) clinging += 1;
    bar += 0.0004 + clinging * 0.0015;
    if (bar >= 1) { bar = 1; state = 1; t = 0; }
    break;

case 1:
    // --- sommerso: tutto si ferma, si aspetta SHIFT ---
    if (keyboard_check_pressed(vk_shift)) {
        state = 2;
        t = 0;
        flash = 1;
        with (obj_grunt) instance_destroy();
        obj_mech_ground.transformed = true;
    }
    break;

case 2:
    // --- lampo bianco che svanisce in 1 secondo ---
    flash = 1 - t / 60;
    if (t >= 60) { flash = 0; state = 3; t = 0; }
    break;

case 3:
    // --- la navicella decolla; fuori dallo schermo parte lo shoot 'em up ---
    if (obj_mech_ground.y < -40) room_goto(rm_game);
    break;
}
