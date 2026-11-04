if (obj_ground.state != 0) exit;   // quando il mecha e' sommerso, tutto si ferma

var m = obj_mech_ground;
face = point_direction(x, y, m.x, m.y);   // guarda sempre il mecha
if (point_distance(x, y, m.x, m.y) > cling_dist) {
    var dir = point_direction(x, y, m.x, m.y);
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
    clinging_now = false;
} else {
    clinging_now = true;
}
