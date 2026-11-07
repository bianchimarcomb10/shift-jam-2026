/// scende piano e dondola; presa, l'arma passa alla navicella per 10 secondi
t += 1;
y += 0.9;
x = x0 + 7 * dsin(t * 3);

if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 20) {
    with (obj_player) {
        special = other.kind;
        special_t = special_total;
        special_cd = 0;
        shift_flash = 12;   // l'ensō azzurro: preso
    }
    audio_play_sound(snd_shift, 8, false, 0.8);   // segnaposto: il musicista fara' snd_powerup
    instance_destroy();
    exit;
}
if (y > room_height - HUD_H + 16) instance_destroy();   // persa: e' scesa sotto il cruscotto
