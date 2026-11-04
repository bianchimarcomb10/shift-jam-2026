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

// resta una stella per qualche secondo, poi buio e si torna al titolo
if (t > 1320) fade = min(1, (t - 1320) / 120);
if (t > 1500) room_goto(rm_title);
