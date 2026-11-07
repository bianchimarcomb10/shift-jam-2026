if (retreat) exit;   // tempo dell'ondata scaduto: la ritirata la fa obj_enemy (Begin Step)
if (wait > 0) { wait -= 1; exit; }   // aspetta il suo turno fuori dallo schermo, di lato

// SE NE VA: non spara piu', vira verso il bordo piu' vicino salendo, accelera e sparisce
if (leaving) {
    lspd = min(lspd + 0.08, 5);
    x += lengthdir_x(lspd, ldir);
    y += lengthdir_y(lspd, ldir);
    if (x < -40 || x > room_width + 40 || y < -40) instance_destroy();
    exit;
}
if (x > 0 && x < room_width) stay -= 1;
if (stay <= 0) {
    leaving = true;
    ldir = (x < room_width / 2) ? 150 : 30;   // in alto a sinistra o in alto a destra
    exit;
}

if (instance_exists(obj_player)) {
    var dir = point_direction(x, y, obj_player.x, obj_player.y);
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
}
if (y < 20) y += 1;   // entra nello schermo prima di inseguire

fire_timer -= 1;
if (fire_timer <= 0 && instance_exists(obj_player) && x > 0 && x < room_width) {   // spara solo quando e' sullo schermo
    var b = instance_create_layer(x, y, "Instances", obj_ebullet);
    b.dir = point_direction(x, y, obj_player.x, obj_player.y);
    b.spd = 2.4 + obj_game.wave * 0.04;
    fire_timer = max(55, 100 - obj_game.wave * 3);   // un colpo ogni 1,7 secondi
}
