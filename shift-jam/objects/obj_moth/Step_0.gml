if (form > 0) {
    // ---- IN FORMAZIONE: la posizione e' calcolata dal disegno, non dalla velocita' ----
    t += 1;
    var tt = t - delay;
    if (tt < 0) { x = -100; y = -100; exit; }   // aspetta il suo turno fuori dallo schermo

    var px = x, py = y;
    switch (form) {
        case 1: // SERPENTE: una fila che scende ondeggiando
            x = cx + amp * dsin(tt * 2);
            y = -20 + tt * 1.7;
            break;

        case 2: // V: scende compatta, si ferma, poi le falene picchiano una alla volta
            var off = idx - (n - 1) / 2;
            x = cx + off * 24;
            y = min(-20 + tt * 1.3, 150) - abs(off) * 20;
            if (tt > 170 + idx * 22) {
                form = 0;   // rompe la formazione
                spd = 3.3;
                dir = (instance_exists(obj_player)) ? point_direction(x, y, obj_player.x, obj_player.y) : 270;
                exit;
            }
            break;

        case 3: // ANELLO: un cerchio che ruota e respira mentre scende
            var a = idx * 360 / n + tt * 1.2;
            var r = 52 + 14 * dsin(tt * 2.5);
            x = cx + lengthdir_x(r, a);
            y = -70 + tt * 0.9 + lengthdir_y(r, a);
            // dall'ondata 6, a meta' discesa l'anello si apre in una raffica a raggiera
            if (tt == 260 && instance_exists(obj_game) && obj_game.wave >= 6) {
                var rb = instance_create_layer(x, y, "Instances", obj_ebullet);
                rb.dir = a;
                rb.spd = 1.8;
            }
            break;

        case 4: // TENAGLIA: due archi che entrano dai lati e si incrociano
            var k = min(tt / 240, 1);
            x = (side == 1) ? (-20 + tt * 1.6) : (room_width + 20 - tt * 1.6);
            y = 30 + 260 * dsin(k * 180) + ((side == 1) ? 0 : 40);
            break;

        case 5: // CORRIDOIO LATERALE: attraversa lo schermo da un lato all'altro,
                // sotto la fascia dove stanno le Lance, ondeggiando appena
            x = (side == 1) ? (-20 + tt * 1.8) : (room_width + 20 - tt * 1.8);
            y = base_y + 26 * dsin(tt * 3);
            break;
    }
    if (x != px || y != py) dir = point_direction(px, py, x, y);   // la sprite guarda dove va

    // colpo mirato (solo per alcune, e solo quando sono ben dentro lo schermo)
    if (can_shoot && y > 20 && y < room_height * 0.55 && instance_exists(obj_player)) {
        fire_timer -= 1;
        if (fire_timer <= 0) {
            var b = instance_create_layer(x, y, "Instances", obj_ebullet);
            b.dir = point_direction(x, y, obj_player.x, obj_player.y);
            b.spd = 2.2;
            shots -= 1;
            fire_timer = 50;
            if (shots <= 0) can_shoot = false;
        }
    }
} else {
    // ---- LIBERA: curva verso il giocatore, ma solo per poco e solo finche' gli sta sopra.
    // Poi tira dritto ed esce dallo schermo (prima poteva girargli intorno per sempre).
    if (home_time > 0) home_time -= 1;
    if (home_time > 0 && instance_exists(obj_player) && y < obj_player.y - 30) {
        var target = point_direction(x, y, obj_player.x, obj_player.y);
        dir += angle_difference(target, dir) * 0.05;
    }
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
}
if (y > room_height + 30 || x < -40 || x > room_width + 40) {
    if (!(form > 0 && t - delay < 0)) instance_destroy();   // chi aspetta fuori non va distrutto
}
