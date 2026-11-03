life -= 1;
if (life <= 0) {
    y -= 3;
    if (y < -40) instance_destroy();
    exit;
}
if (y < stop_y) { y += 2; exit; }

timer += 1;
if (timer mod 90 == 0) charge = 30;   // 0,5 s di avviso prima di sparare
if (charge > 0) {
    charge -= 1;
    if (charge == 0 && instance_exists(obj_player)) {
        var b = instance_create_layer(x, y + 14, "Instances", obj_ebullet);
        b.dir = point_direction(x, y, obj_player.x, obj_player.y);
    }
}
