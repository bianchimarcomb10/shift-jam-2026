if (instance_exists(obj_player)) {
    var dir = point_direction(x, y, obj_player.x, obj_player.y);
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
}
if (y < 20) y += 1;   // entra nello schermo prima di inseguire

fire_timer -= 1;
if (fire_timer <= 0 && instance_exists(obj_player)) {
    var b = instance_create_layer(x, y, "Instances", obj_ebullet);
    b.dir = point_direction(x, y, obj_player.x, obj_player.y);
    b.spd = 2.4;
    fire_timer = 120;   // un colpo ogni 2 secondi
}
