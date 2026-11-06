y += spd;

// passata meta' schermo, le torrette rimaste si spengono e la nave ti passa sopra, accelerando piano
if (!retired && y > room_height * 0.45) {
    retired = true;
    with (obj_turret) {
        if (ship == other.id) {
            array_push(other.inert, [bx, oy, rack]);
            silent = true;   // nessuna esplosione: si spegne e basta
            instance_destroy();
        }
    }
}
if (retired) spd = min(spd + 0.01, 1.6);

if (y > room_height + 140) instance_destroy();
