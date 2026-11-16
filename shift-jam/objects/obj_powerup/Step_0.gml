/// scende piano e dondola; se le sei vicino ti viene incontro (calamita). Presa, l'arma passa alla navicella
t += 1;
var pull = false;
if (instance_exists(obj_player)) {
    var pd = point_distance(x, y, obj_player.x, obj_player.y);
    if (pd < 110) {
        // calamita: piu' sei vicino, piu' veloce arriva
        var ps = lerp(4.5, 1.5, pd / 110);
        x += lengthdir_x(min(ps, pd), point_direction(x, y, obj_player.x, obj_player.y));
        y += lengthdir_y(min(ps, pd), point_direction(x, y, obj_player.x, obj_player.y));
        x0 = x;
        pull = true;
    }
}
if (!pull) {
    y += 0.9;
    x = x0 + 7 * dsin(t * 3);
}

if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 30) {
    with (obj_player) {
        // come in Metal Slug: la stessa arma somma le munizioni, un'arma diversa sostituisce quella che hai
        if (special == other.kind) special_ammo += special_max[other.kind];
        else { special = other.kind; special_ammo = special_max[other.kind]; special_cd = 0; }
        special_full = special_ammo;
        shift_flash = 12;   // l'ensō azzurro: preso
    }
    audio_play_sound(snd_shift, 8, false, 0.8 * SFX_GAIN);   // segnaposto: il musicista fara' snd_powerup
    instance_destroy();
    exit;
}
if (y > room_height - HUD_H + 16) instance_destroy();   // persa: e' scesa sotto il cruscotto
