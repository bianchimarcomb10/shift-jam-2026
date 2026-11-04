// --- entrata lenta, senza attaccare ---
if (y < target_y) { y += 1.2; exit; }

t += 1;
bead_angle += 0.4;
x = room_width / 2 + sin(t / 90) * 60;   // ondeggia piano a destra e sinistra

// le mani si chiudono mentre carica l'attacco delle mani
hands_gap = (attack == 1) ? clamp(attack_timer / 3, 0, 12) : 12;

attack_timer -= 1;
if (attack_timer <= 0) {
    if (attack == 0) {
        // MALA: un anello di 18 proiettili lenti, partono dai grani
        for (var i = 0; i < 18; i++) {
            var a = bead_angle + i * 20;
            var b = instance_create_layer(x + lengthdir_x(70, a), y + lengthdir_y(70, a), "Instances", obj_ebullet);
            b.dir = a;
            b.spd = 1.6;
        }
    } else {
        // MANI: un ventaglio di 5 proiettili mirati al giocatore
        if (instance_exists(obj_player)) {
            var base = point_direction(x, y + 42, obj_player.x, obj_player.y);
            for (var k = -2; k <= 2; k++) {
                var b2 = instance_create_layer(x, y + 42, "Instances", obj_ebullet);
                b2.dir = base + k * 12;
                b2.spd = 3;
            }
        }
    }
    attack = 1 - attack;   // alterna i due attacchi
    attack_timer = 100;
}
