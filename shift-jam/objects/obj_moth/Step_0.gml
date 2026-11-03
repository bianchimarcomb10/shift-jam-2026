if (instance_exists(obj_player)) {
    var target = point_direction(x, y, obj_player.x, obj_player.y);
    dir += angle_difference(target, dir) * 0.04;   // curva lenta verso il giocatore
}
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
if (y > room_height + 30 || x < -40 || x > room_width + 40) instance_destroy();
