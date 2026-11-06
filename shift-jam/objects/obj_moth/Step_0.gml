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

        case 3: // QUADRATO: un blocco rigido di falene (3x3 senza il centro) che scende dritto, lento
            // amp = verso (1 o -1): il blocco scivola appena di lato, due quadrati scivolano a specchio
            var gx, gy;
            if (n == 8) {
                // le 8 caselle del bordo di un quadrato 3x3, in giro
                var cells = [[-1, -1], [0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0]];
                gx = cells[idx][0];
                gy = cells[idx][1];
            } else {
                // altri numeri: griglia piena, riga per riga
                var cols = ceil(sqrt(n));
                gx = (idx mod cols) - (cols - 1) / 2;
                gy = (idx div cols) - (ceil(n / cols) - 1) / 2;
            }
            var bx = cx + sign(amp) * 12 * dsin(tt * 0.8);   // il centro del blocco
            var by = -70 + tt * 0.9;
            x = bx + gx * 26;
            y = by + gy * 26;
            // dall'ondata 4, a meta' discesa il quadrato si apre in una raffica: ogni falena spara verso l'esterno
            if (instance_exists(obj_game) && ((tt == 260 && obj_game.wave >= 4) || (tt == 340 && obj_game.wave >= 10))) {
                var rb = instance_create_layer(x, y, "Instances", obj_ebullet);
                rb.dir = point_direction(bx, by, x, y);
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
    if (form == 3) dir = 270;   // nel quadrato guardano tutte in basso, come soldati in fila
    else if (x != px || y != py) dir = point_direction(px, py, x, y);   // la sprite guarda dove va

    // colpo mirato (solo per alcune, e solo quando sono ben dentro lo schermo)
    if (can_shoot && y > 20 && y < room_height * 0.55 && instance_exists(obj_player)) {
        fire_timer -= 1;
        if (fire_timer <= 0) {
            var b = instance_create_layer(x, y, "Instances", obj_ebullet);
            b.dir = point_direction(x, y, obj_player.x, obj_player.y);
            b.spd = 2.2 + obj_game.wave * 0.05;
            shots -= 1;
            fire_timer = max(28, 50 - obj_game.wave * 2);
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
