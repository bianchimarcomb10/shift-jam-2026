/// Ondate alternate: sciami di Falene (da falciare) e Lance (da colpire da lontano).
if (finale) exit;   // durante il finale non succede piu' niente

if (game_over) {
    if (keyboard_check_pressed(vk_shift)) room_goto(rm_game);   // si riprova dallo spazio, senza rifare il prologo
    exit;
}

if (boss_spawned) exit;

// finite le ondate, quando lo schermo e' libero arriva il Custode
if (wave >= boss_wave) {
    if (instance_number(obj_enemy) == 0) {
        boss_spawned = true;
        instance_create_layer(room_width / 2, -90, "Instances", obj_boss);
    }
    exit;
}

spawn_timer -= 1;
if (spawn_timer <= 0) {
    wave += 1;
    var kind = wave mod 4;
    if (kind == 1) {
        // Sciame di Falene: arrivano in fila dall'alto e puntano il giocatore
        var n = 8 + wave;
        for (var i = 0; i < n; i++) {
            instance_create_layer(random_range(20, room_width - 20), -20 - i * 14, "Instances", obj_moth);
        }
    } else if (kind == 2) {
        // Lance: si fermano in alto e sparano dopo un avviso
        repeat (2 + wave div 3) {
            instance_create_layer(random_range(40, room_width - 40), -30, "Instances", obj_spear);
        }
    } else if (kind == 3) {
        // Inseguitori: scendono piano verso di te
        repeat (2 + wave div 4) {
            instance_create_layer(random_range(30, room_width - 30), -20, "Instances", obj_stalker);
        }
    } else {
        // ondata mista: obbliga a cambiare forma di continuo
        for (var j = 0; j < 6; j++) {
            instance_create_layer(random_range(20, room_width - 20), -20 - j * 14, "Instances", obj_moth);
        }
        instance_create_layer(random_range(40, room_width - 40), -30, "Instances", obj_spear);
        instance_create_layer(random_range(30, room_width - 30), -20, "Instances", obj_stalker);
    }
    spawn_timer = 270;  // 4,5 secondi tra un'ondata e l'altra
}
