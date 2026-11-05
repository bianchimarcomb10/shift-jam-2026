// guardano in alto: stanno salendo, lontano, sotto di noi
for (var i = 0; i < array_length(items); i++) {
    var it = items[i];
    draw_sprite_ext(it[0], 0, x + it[1], y + it[2], it[3], it[3], 0, tint, fade);
}
