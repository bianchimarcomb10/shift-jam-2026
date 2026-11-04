life -= 1;
if (life <= 0) {
    y -= 3;
    if (y < -40) instance_destroy();
    exit;
}
if (y < stop_y) { y += 2; exit; }

timer += 1;
if (timer mod 75 == 0) charge = 30;   // un colpo ogni 1,25 s (era 1,5)   // 0,5 s di avviso prima di sparare
if (charge > 0) {
    charge -= 1;
    if (charge == 0 && instance_exists(obj_player)) {
        var aim = point_direction(x, y, obj_player.x, obj_player.y);
        // dall'ondata 4 le Lance sparano a ventaglio (3 colpi), prima un colpo solo
        var spread = (obj_game.wave >= 4) ? 1 : 0;
        for (var s = -spread; s <= spread; s++) {
            var b = instance_create_layer(x, y + 14, "Instances", obj_ebullet);
            b.dir = aim + s * 14;
        }
    }
}
