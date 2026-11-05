t += 1;
x += side * spd;
// posa un colpo ogni volta che passa sopra uno dei punti del muro;
// i colpi restano fermi in fila e partono tutti insieme quando le fregate sono uscite
while (k < array_length(slots) && ((side == 1 && x >= slots[k]) || (side == -1 && x <= slots[k]))) {
    var b = instance_create_layer(slots[k], y + 8, "Instances", obj_ebullet);
    b.dir = 270;
    b.spd = bspd;
    b.hold = max(1, total - t);
    k += 1;
}
if (x < -60 || x > room_width + 60) instance_destroy();
