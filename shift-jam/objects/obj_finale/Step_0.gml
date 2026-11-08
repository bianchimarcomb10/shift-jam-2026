t += 1;
flash = max(0, flash - 1 / 45);

// le stelle rallentano fino a fermarsi: alla fine la navicella e' un punto immobile tra punti immobili
if (instance_exists(obj_starfield)) obj_starfield.speed_mult = max(0, 1 - t / 600);

// 2 secondi di immobilita', poi 15 secondi di salita
if (t > 120) {
    var k = clamp((t - 120) / 900, 0, 1);
    var e = k * k * (3 - 2 * k);              // parte piano, accelera, rallenta alla fine
    ship_y = lerp(start_y, 170, e);
    ship_x = lerp(start_x, room_width / 2 + 40, e);
    scale = 1 - e;
}

// mentre la navicella si confonde tra le stelle: la poesia di Ryokan (da 10 a 20 s),
// poi "A game by..." con la musica (da 20,5 a 25,5 s), il grazie ai playtester (da 26,5 s);
// infine buio (da 32 s) e si torna al titolo (35 s)
if (t > 1920) fade = min(1, (t - 1920) / 120);
if (t > 2100) room_goto(rm_title);
