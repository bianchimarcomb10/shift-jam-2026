// guardano in alto: stanno salendo, lontano, sotto di noi
// prima l'orda (dietro), poi l'ondata vera (davanti)
for (var pass = 0; pass < 2; pass++) {
    for (var i = 0; i < array_length(items); i++) {
        var it = items[i];
        if (it[4] != pass) continue;
        var wob = dsin(t * 4 + i * 37) * 2;   // ondeggiano appena: sono vivi
        if (pass == 0) draw_sprite_ext(it[0], 0, x + it[1] + wob, y + it[2], it[3], it[3], 0, tint_horde, 0.5);
        else           draw_sprite_ext(it[0], 0, x + it[1], y + it[2] + wob, it[3], it[3], 0, tint_wave, 0.85);
    }
}
