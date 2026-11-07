/// salta fuori, poi scende piano dondolando. Se lo tocchi e ti manca una vita, te la ridà.
/// Con le vite piene non si prende: resta li' (piu' trasparente) per quando ti servira'.
t += 1;
vy = min(vy + 0.07, 0.45);
y += vy;
x0 = clamp(x0 + vx, 20, room_width - 20);
vx *= 0.97;
x = x0 + 6 * dsin(t * 3.5);
rot += 3;
life -= 1;

if (global.hp < 3 && instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 20) {
    global.hp = min(3, global.hp + 1);   // la spia sul cruscotto si riaccende da sola
    obj_player.shift_flash = 12;         // l'ensō azzurro attorno al giocatore: preso
    obj_player.heal_t = 120;             // 2 s di RIPARAZIONE: la nave brilla e il cruscotto scrive HULL REPAIRED
    audio_play_sound(snd_parry, 8, false, 0.7);   // segnaposto: il musicista fara' snd_heart
    instance_destroy();
    exit;
}
if (life <= 0 || y > room_height - HUD_H + 16) instance_destroy();   // perso
