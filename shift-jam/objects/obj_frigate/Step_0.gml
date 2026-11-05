t += 1;
x += side * spd;
// la scia: ogni volta che la CODA della fregata passa sopra uno dei punti del muro, li' nasce un colpo.
// I colpi restano fermi in fila e partono tutti insieme quando le fregate sono uscite.
var tail = x - side * 14;
while (k < array_length(slots) && ((side == 1 && tail >= slots[k]) || (side == -1 && tail <= slots[k]))) {
    var b = instance_create_layer(slots[k], y, "Instances", obj_ebullet);
    b.dir = 270;
    b.spd = bspd;
    b.hold = max(1, total - t);
    k += 1;
}
if (x < -60 || x > room_width + 60) instance_destroy();
