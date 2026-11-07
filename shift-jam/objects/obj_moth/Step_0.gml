if (retreat) exit;   // tempo dell'ondata scaduto: la ritirata la fa obj_enemy (Begin Step)
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

        case 3: // FORMAZIONE AEREA: una squadriglia rigida, come le flotte vere.
                // Il capo vola davanti; gli altri tengono il loro posto dietro di lui.
                // La squadriglia scende serpeggiando e, quando vira, si piega TUTTA INSIEME attorno al capo.
                // amp = verso (1 o -1): due squadriglie serpeggiano a specchio
            var sg = sign(amp);
            // i posti: [di lato, dietro], in "passi" (22 px di lato, 18 nello scaglione; 20 px dietro)
            var slots;
            if (shape == 1)      slots = [[0, 0], [-1, 1], [1, 1], [-2, 2], [0, 2], [2, 2], [-1, 3], [1, 3], [0, 4]];            // ROMBO
            else if (shape == 2) slots = [[0, 0], [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]];                     // SCAGLIONE
            else                 slots = [[0, 0], [-1, 1], [1, 1], [-2, 2], [0, 2], [2, 2], [-3, 3], [-1, 3], [1, 3], [3, 3]]; // CUNEO
            var sl = slots[min(idx, array_length(slots) - 1)];
            var lat = sl[0];
            if (shape == 2) lat *= sg;   // lo scaglione si apre verso l'esterno: due scaglioni a specchio fanno una V grande
            var step_x = (shape == 2) ? 18 : 22;
            // il capo: scende serpeggiando. La direzione della squadriglia e' quella in cui si muove il capo
            var lx = cx + sg * 32 * dsin(tt * 0.7);
            var ly = -40 + tt * 1.0;
            var hd = point_direction(0, 0, sg * 32 * dcos(tt * 0.7) * 0.7 * pi / 180, 1.0);
            var fh = 270 + angle_difference(hd, 270) * 0.6;   // la squadriglia si piega un po' meno del capo: resta leggibile
            // ogni falena: dal capo, "lat" passi di lato e "sl[1]" passi dietro, girati con la squadriglia
            x = lx + lengthdir_x(lat * step_x, fh - 90) + lengthdir_x(sl[1] * 20, fh + 180);
            y = ly + lengthdir_y(lat * step_x, fh - 90) + lengthdir_y(sl[1] * 20, fh + 180);
            dir = hd;   // guardano tutte dove va la squadriglia
            // dall'ondata 4, a meta' discesa la squadriglia fa fuoco tutta insieme, a ventaglio in avanti
            if (instance_exists(obj_game) && ((tt == 260 && obj_game.wave >= 4) || (tt == 340 && obj_game.wave >= 10))) {
                var rb = instance_create_layer(x, y, "Instances", obj_ebullet);
                rb.dir = hd - lat * 8;
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

        case 6: // CROCE: due file entrano dagli angoli in alto, si incrociano a X al centro
                // ed escono dai lati opposti, sempre sopra di te
            x = (side == 1) ? (-20 + tt * 1.6) : (room_width + 20 - tt * 1.6);
            y = -20 + tt * 1.25;
            break;

        case 7: // RUOTA: le falene in cerchio scendono, si fermano e girano (amp = verso).
                // Ogni secondo sparano tutte insieme verso l'esterno: un anello che nasce gia' girato,
                // cosi' i varchi si spostano a ogni anello. Ogni falena abbattuta e' un varco in piu'.
                // Dopo 4 anelli il cerchio si apre come un fiore e le falene volano via
            var arrive = 140, hold = 240;
            var rr = 44;
            if (tt > arrive + hold) rr += (tt - arrive - hold) * 2.5;
            var a = idx * 360 / n + tt * 1.2 * sign(amp);
            x = cx + lengthdir_x(rr, a);
            y = min(-50 + tt * 1.5, 160) + lengthdir_y(rr, a);
            if (tt > arrive && tt <= arrive + hold && (tt - arrive) mod 60 == 0) global.shoot(x, y, a, 1.6);
            break;

        case 8: // RISALITA: entra DA SOTTO, lungo il bordo (side 1 sinistra, -1 destra), sale,
                // in alto curva verso il centro e attraversa lo schermo di lato.
                // Ti chiude il bordo: devi stare verso il centro. Prima che esca, una freccia verde (Draw)
            var ex = (side == 1) ? 24 : room_width - 24;
            var ty = (side == 1) ? 200 : 260;                 // dove inizia la curva: le due file non si incrociano
            var dist = tt * 2.2;                               // strada fatta
            var climb = (room_height - HUD_H + 20) - ty;       // la salita lungo il bordo
            var arc = 60 * pi / 2;                             // un quarto di cerchio di raggio 60
            if (dist < climb) {
                x = ex;
                y = room_height - HUD_H + 20 - dist;
            } else if (dist < climb + arc) {
                var ang = 180 - (dist - climb) / arc * 90;     // da 180 a 90 gradi: dal bordo verso l'alto
                x = ex + side * (60 + lengthdir_x(60, ang));
                y = ty + lengthdir_y(60, ang);
            } else {
                x = ex + side * (60 + (dist - climb - arc));
                y = ty - 60;
            }
            break;
    }
    if (form != 3 && (x != px || y != py)) dir = point_direction(px, py, x, y);   // la sprite guarda dove va

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
if (y > room_height + 30 || x < -40 || x > room_width + 40 || (form == 7 && t - delay > 380 && y < -40)) {   // la ruota aperta esce anche in alto
    if (!(form > 0 && t - delay < 0)) instance_destroy();   // chi aspetta fuori non va distrutto
}
