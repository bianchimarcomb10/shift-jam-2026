y += spd;

// HANGAR: dalla prua escono tre Falene alla volta, a V, che ti vengono addosso (e ti costringono a cambiare forma)
if (!retired && y > 20) {
    launch_timer -= 1;
    if (launch_timer <= 0) {
        launch_timer = 170;
        var hx = x + launch_side * 18, hy = y + 44;   // la prua: la nave e' girata, il muso e' in basso
        var aim = instance_exists(obj_player) ? point_direction(hx, hy, obj_player.x, obj_player.y) : 270;
        for (var k = -1; k <= 1; k++) {
            var m = instance_create_layer(hx + k * 16, hy - abs(k) * 12, "Instances", obj_moth);
            m.dir = aim;
            m.spd = 2.6;
            m.home_time = 60;
        }
        launch_side *= -1;
    }
}

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
