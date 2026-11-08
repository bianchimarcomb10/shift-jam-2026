if (!reflected) {
    // insegue il giocatore, ma gira lentamente
    if (instance_exists(obj_player)) {
        var target = point_direction(x, y, obj_player.x, obj_player.y);
        dir += clamp(angle_difference(target, dir), -turn, turn);
    }
} else if (instance_exists(obj_boss)) {
    // respinto: vola dritto contro il Custode
    var bs = instance_nearest(x, y, obj_boss);
    dir = point_direction(x, y, bs.x, bs.y);
    if (point_distance(x, y, bs.x, bs.y) < bs.radius + radius) {
        bs.hp -= dmg;    // molto piu' di un colpo normale
        if (instance_exists(obj_player)) obj_player.drill_add(sid);   // anche un grano respinto a segno carica la trivella (una volta per falciata)
        bs.stun = max(bs.stun, stn);   // e lo stordisce (un palmo 3/4 di secondo, un grano poco)
        if (bs.hp <= 0) with (bs) instance_destroy();
        instance_destroy();
        exit;
    }
}
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
if (y < -40 || y > room_height + 40 || x < -40 || x > room_width + 40) instance_destroy();
