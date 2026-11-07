t += 1;
var target = (side == 1) ? 0 : 180;   // la direzione del suo lato

switch (phase) {
    case 0: // picchiata dall'alto fino all'altezza del muro
        if (y >= row_y - 8) phase = 1;
        break;
    case 1: // virata stretta verso il suo lato
        hd += clamp(angle_difference(target, hd), -15, 15);
        if (abs(angle_difference(target, hd)) < 1) { hd = target; phase = 2; y = row_y; }
        break;
    case 2: // corre verso il bordo e lascia la scia di colpi
        if (k >= array_length(slots)) phase = 3;
        break;
    case 3: // cabrata: curva verso l'alto, accelera ed esce
        hd += clamp(angle_difference(90, hd), -7, 7);
        spd = min(spd + 0.15, 7);
        break;
}
x += lengthdir_x(spd, hd);
y += lengthdir_y(spd, hd);

// la scia: ogni volta che la CODA passa sopra uno dei punti del muro, li' nasce un colpo.
// I colpi restano fermi in fila e partono tutti insieme quando le fregate sono andate via.
if (phase == 2) {
    var tail = x - side * 8;
    while (k < array_length(slots) && ((side == 1 && tail >= slots[k]) || (side == -1 && tail <= slots[k]))) {
        var b = instance_create_layer(slots[k], row_y, "Instances", obj_ebullet);
        b.dir = 270;
        b.spd = bspd;
        b.hold = max(1, total - t);
        b.wall = true;
        b.wph = abs(slots[k] - room_width / 2) * 3;   // 3 gradi di fase per pixel: un'onda ogni 120 px
        // A FRECCIA: il centro cade piu' in fretta dei bordi, il muro si piega a punta verso di te
        if (wtype == 2) b.spd = bspd * (1.35 - 0.7 * abs(slots[k] - room_width / 2) / (room_width / 2));
        // DOPPIO: sotto ogni colpo ce n'e' un secondo, che parte 40 fotogrammi dopo.
        // Finche' sono fermi in fila si sovrappongono e il muro brilla il doppio: e' l'avviso
        if (wtype == 3) {
            var b2 = instance_create_layer(slots[k], row_y, "Instances", obj_ebullet);
            b2.dir = 270;
            b2.spd = bspd;
            b2.hold = b.hold + 40;
            b2.wall = true;
            b2.wph = b.wph;
        }
        k += 1;
    }
}
if (y < -60 || x < -80 || x > room_width + 80) instance_destroy();
