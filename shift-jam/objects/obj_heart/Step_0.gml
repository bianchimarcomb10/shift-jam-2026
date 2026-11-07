/// scende piano, dondola, gira; se la navicella (o il mecha) lo tocca ridà una vita
t += 1;
y += 0.8;
x = x0 + 6 * dsin(t * 3.5);
rot += 3;

if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 18) {
    global.hp = min(3, global.hp + 1);   // la spia sul cruscotto si riaccende da sola
    obj_player.shift_flash = 12;         // l'ensō azzurro attorno al giocatore: preso
    audio_play_sound(snd_parry, 8, false, 0.7);   // segnaposto: il musicista fara' snd_heart
    instance_destroy();
    exit;
}
if (y > room_height - HUD_H + 16) instance_destroy();   // perso: e' sceso sotto il cruscotto
