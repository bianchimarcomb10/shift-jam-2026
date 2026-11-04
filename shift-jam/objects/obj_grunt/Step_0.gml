if (fling) {
    // sbalzato dall'esplosione: vola via girando su se stesso e rallenta piano
    x += fvx;
    y += fvy;
    fvx *= 0.97;
    fvy *= 0.97;
    face += spin;
    if (x < -30 || x > room_width + 30 || y < -30 || y > room_height + 30) instance_destroy();
    exit;
}
if (obj_ground.state > 1) exit;

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
