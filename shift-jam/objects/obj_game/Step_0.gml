/// Ondate: le Falene arrivano in formazioni geometriche, insieme a Lance e Inseguitori.
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
    var kind = (wave - 1) mod 6;
    var w = room_width;
    switch (kind) {
        case 0: // serpente
            spawn_formation(1, 8 + wave div 2, random_range(120, w - 120), 100);
            break;
        case 1: // V che picchia + Lance
            spawn_formation(2, 7, w / 2, 0);
            repeat (1 + wave div 4) instance_create_layer(random_range(40, w - 40), -30, "Instances", obj_spear);
            break;
        case 2: // anello + Inseguitori
            spawn_formation(3, 8, w / 2, 0);
            repeat (1 + wave div 5) instance_create_layer(random_range(30, w - 30), -20, "Instances", obj_stalker);
            break;
        case 3: // tenaglia dai lati
            spawn_formation(4, 10 + wave div 2, 0, 0);
            break;
        case 4: // due serpenti a specchio + Lance
            spawn_formation(1, 6 + wave div 3, w * 0.28, 70);
            spawn_formation(1, 6 + wave div 3, w * 0.72, -70);
            repeat (2) instance_create_layer(random_range(40, w - 40), -30, "Instances", obj_spear);
            break;
        case 5: // misto: V piccola, Inseguitori, una Lancia
            spawn_formation(2, 5, w / 2, 0);
            repeat (2) instance_create_layer(random_range(30, w - 30), -20, "Instances", obj_stalker);
            instance_create_layer(random_range(40, w - 40), -30, "Instances", obj_spear);
            break;
    }
    spawn_timer = max(180, 270 - wave * 6);   // le ondate si fanno sempre piu' ravvicinate
}
