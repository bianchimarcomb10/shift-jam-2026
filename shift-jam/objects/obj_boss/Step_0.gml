// --- entrata lenta, senza attaccare ---
if (y < target_y) { y += 1.2; exit; }
t += 1;

// --- passaggio di fase: il guscio della nave madre si rompe ---
if (phase == 1 && hp <= hp_p2) {
    phase = 2;
    hp = hp_p2;
    radius = 28;
    transition = 120;
    attack = 0;
    attack_timer = 120;
    hint = 360;
    with (obj_ebullet) instance_destroy();
    debris = [];
    for (var i = 0; i < 24; i++) {
        var da = random(360);
        var ds = random_range(1, 4);
        debris[i] = [x + random_range(-60, 60), y + random_range(-20, 20), lengthdir_x(ds, da), lengthdir_y(ds, da), random_range(4, 12)];
    }
}
if (transition > 0) {
    transition -= 1;
    hp = hp_p2;   // invulnerabile mentre si rivela
    for (var i2 = 0; i2 < array_length(debris); i2++) {
        debris[i2][0] += debris[i2][2];
        debris[i2][1] += debris[i2][3];
    }
    exit;
}
if (hint > 0) hint -= 1;
if (stun > 0) { stun -= 1; exit; }

if (phase == 1) {
    // ===== FASE 1: NAVE MADRE =====
    x = room_width / 2 + sin(t / 120) * 50;
    attack_timer -= 1;
    if (attack_timer <= 0) {
        if (attack == 0) {
            // cannoni laterali: raffica mirata da sinistra e da destra
            if (instance_exists(obj_player)) {
                for (var c = -1; c <= 1; c += 2) {
                    var cx = x + c * 60;
                    var cy = y + 30;
                    var base = point_direction(cx, cy, obj_player.x, obj_player.y);
                    for (var k = -1; k <= 1; k++) {
                        var b1 = instance_create_layer(cx, cy, "Instances", obj_ebullet);
                        b1.dir = base + k * 8;
                        b1.spd = 2.8;
                    }
                }
            }
        } else if (attack == 1) {
            // hangar: lancia uno sciame di Falene
            repeat (5) instance_create_layer(x + random_range(-30, 30), y + 30, "Instances", obj_moth);
        } else {
            // ventaglio verso il basso
            for (var k2 = -4; k2 <= 4; k2++) {
                var b2 = instance_create_layer(x, y + 30, "Instances", obj_ebullet);
                b2.dir = 270 + k2 * 14;
                b2.spd = 2.2;
            }
        }
        attack = (attack + 1) mod 3;
        attack_timer = 80;
    }
} else {
    // ===== FASE 2: IL CUSTODE =====
    bead_angle += 0.6;
    x = room_width / 2 + sin(t / 80) * 70;
    var angry = (hp < hp_p2 / 2);   // sotto meta' vita attacca piu' spesso e piu' forte
    // le mani si aprono e si chiudono mentre caricano
    hands_gap = (attack == 1 || attack == 3) ? clamp(attack_timer / 3, 0, 14) : 14;

    attack_timer -= 1;
    if (attack_timer <= 0) {
        if (attack == 0) {
            // MALA: anello di proiettili che partono dai grani
            var n = angry ? 27 : 18;
            for (var i3 = 0; i3 < n; i3++) {
                var a = bead_angle + i3 * (360 / n);
                var b3 = instance_create_layer(x + lengthdir_x(70, a), y + lengthdir_y(70, a), "Instances", obj_ebullet);
                b3.dir = a;
                b3.spd = 1.6;
            }
        } else if (attack == 2) {
            // ventaglio mirato
            if (instance_exists(obj_player)) {
                var base2 = point_direction(x, y + 42, obj_player.x, obj_player.y);
                var m = angry ? 3 : 2;
                for (var k3 = -m; k3 <= m; k3++) {
                    var b4 = instance_create_layer(x, y + 42, "Instances", obj_ebullet);
                    b4.dir = base2 + k3 * 12;
                    b4.spd = 3;
                }
            }
        } else {
            // MANI: palmi d'oro. Non si distruggono: si respingono con la falciata del mecha
            instance_create_layer(x - 14, y + 44, "Instances", obj_palm);
            if (angry) instance_create_layer(x + 14, y + 44, "Instances", obj_palm);
        }
        attack = (attack + 1) mod 4;
        attack_timer = angry ? 60 : 85;
    }
}
