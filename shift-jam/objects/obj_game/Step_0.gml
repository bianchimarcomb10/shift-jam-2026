/// Ondate alternate: sciami di Falene (da falciare) e Lance (da colpire da lontano).
if (game_over) {
    if (keyboard_check_pressed(vk_shift)) room_goto(rm_game);   // si riprova dallo spazio, senza rifare il prologo
    exit;
}

spawn_timer -= 1;
if (spawn_timer <= 0) {
    wave += 1;
    if (wave mod 2 == 1) {
        // Sciame di Falene: arrivano in fila dall'alto e puntano il giocatore
        var n = 8 + wave;
        for (var i = 0; i < n; i++) {
            instance_create_layer(random_range(20, room_width - 20), -20 - i * 14, "Instances", obj_moth);
        }
    } else {
        // Lance: si fermano in alto e sparano dopo un avviso
        repeat (2 + wave div 2) {
            instance_create_layer(random_range(40, room_width - 40), -30, "Instances", obj_spear);
        }
    }
    spawn_timer = 240;  // 4 secondi tra un'ondata e l'altra
}
