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

// la nuova ondata parte solo quando la precedente e' quasi finita (al massimo 2 nemici rimasti),
// cosi' due formazioni non si incrociano mai sullo schermo
if (instance_number(obj_enemy) > 2) spawn_timer = max(spawn_timer, 45);
spawn_timer -= 1;
if (spawn_timer <= 0) {
    wave += 1;
    var kind = (wave - 1) mod 7;
    var w = room_width;
    // ogni ondata tiene separati i tipi di nemico, nello spazio o nel tempo:
    // Lance sempre nella fascia alta, Falene dai lati quando ci sono Lance,
    // Inseguitori solo dopo che la formazione di Falene e' passata.
    switch (kind) {
        case 0: // serpente, da solo
            spawn_formation(1, 8 + wave div 2, random_range(120, w - 120), 100);
            break;
        case 1: // Lance in alto + Falene che attraversano dai lati, piu' in basso
            spawn_spears(2 + wave div 5);
            spawn_formation(5, 10 + wave div 2, 0, 0);
            break;
        case 2: // anello, poi gli Inseguitori quando l'anello e' sceso
            spawn_formation(3, 8, w / 2, 0);
            spawn_stalkers(1 + wave div 5, 300);
            break;
        case 3: // tenaglia dai lati, da sola
            spawn_formation(4, 10 + wave div 2, 0, 0);
            break;
        case 4: // due serpenti a specchio, da soli
            spawn_formation(1, 6 + wave div 3, w * 0.28, 70);
            spawn_formation(1, 6 + wave div 3, w * 0.72, -70);
            break;
        case 5: // Lance in alto + corridoio, poi Inseguitori
            spawn_spears(3);
            spawn_formation(5, 8, 0, 0);
            spawn_stalkers(2, 330);
            break;
        case 6: // V che si ferma e picchia, da sola
            spawn_formation(2, 7 + wave div 6, w / 2, 0);
            break;
    }
    spawn_timer = max(120, 200 - wave * 5);   // pausa massima dopo che lo schermo si e' liberato
}
