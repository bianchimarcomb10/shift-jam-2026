if (instance_exists(obj_game)) {
    var target = obj_game.wave;
    if (obj_game.boss_preview) target = obj_game.boss_wave + 2;
    alt += (target - alt) * 0.004;   // sale piano verso l'ondata attuale
}
// le nuvole sfrecciano verso il basso: stiamo salendo in fretta
for (var i = 0; i < array_length(clouds); i++) {
    var cl = clouds[i];
    cl[@ 1] += cl[3];
    if (cl[1] - cl[2] > room_height) {
        cl[@ 1] = -cl[2] - random(200);
        cl[@ 0] = random(room_width);
    }
}
// le stelle compaiono solo quando l'atmosfera si dirada
if (instance_exists(obj_starfield)) obj_starfield.alpha = clamp((alt - 2) / 4, 0, 1);
