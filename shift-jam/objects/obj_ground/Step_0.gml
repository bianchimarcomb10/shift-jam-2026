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
        with (obj_grunt) instance_destroy();
        // il mecha diventa la navicella: da qui la comandi tu, senza cambiare stanza
        var px = obj_mech_ground.x;
        var py = obj_mech_ground.y;
        instance_destroy(obj_mech_ground);
        var sf = instance_create_layer(0, 0, "Instances", obj_starfield);
        sf.alpha = 0;   // le stelle compaiono piano piano mentre sali
        instance_create_layer(px, py, "Instances", obj_player);
        instance_create_layer(0, 0, "Instances", obj_game);   // da qui partono le ondate dello shoot 'em up
    }
    break;

case 2:
    // --- lampo bianco che svanisce in mezzo secondo (la navicella si muove gia') ---
    flash = 1 - t / 30;
    scroll += 2;
    if (t >= 30) { flash = 0; state = 3; t = 0; }
    break;

case 3:
    // --- volo: il terreno scende e sparisce, il cielo si scurisce, arrivano le stelle ---
    if (scroll < room_height + 200) scroll += 3;
    if (instance_exists(obj_starfield)) obj_starfield.alpha = min(1, obj_starfield.alpha + 0.008);
    break;
}
