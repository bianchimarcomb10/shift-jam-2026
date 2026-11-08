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

// PERCORSO FISSO: entra di lato lungo la sua corsia, in 1,5 s si ferma al suo posto (76 px dal bordo),
// poi ondeggia a otto e scende piano (al massimo 50 px). Non dipende da dove sei tu
if (t == 0) { side = (x < room_width / 2) ? 1 : -1; lane_y = y; }
t += 1;
var hx = (side == 1) ? 76 : room_width - 76;
var sx = (side == 1) ? -30 : room_width + 30;
var k = min(t / 90, 1); k = k * k * (3 - 2 * k);
var ht = max(0, t - 90);
x = lerp(sx, hx, k) + 26 * dsin(ht * 1.5) * side;
y = lane_y + min(ht * 0.12, 50) + 9 * dsin(ht * 3);

fire_timer -= 1;
if (fire_timer <= 0 && instance_exists(obj_player) && x > 0 && x < room_width) {   // spara solo quando e' sullo schermo
    if (pat == 1) {
        // CORDA: 4 colpi nella stessa direzione, uno dietro l'altro. Si evita spostandosi di lato
        global.shoot_rope(x, y, point_direction(x, y, obj_player.x, obj_player.y), 4, 2.2 + obj_game.wave * 0.03);
        fire_timer = 110;   // piu' lento: ogni corda vale quattro colpi
    } else {
        var b = instance_create_layer(x, y, "Instances", obj_ebullet);
        b.dir = point_direction(x, y, obj_player.x, obj_player.y);
        b.spd = 2.4 + obj_game.wave * 0.04;
        fire_timer = max(55, 100 - obj_game.wave * 3);   // un colpo ogni 1,7 secondi
    }
}
