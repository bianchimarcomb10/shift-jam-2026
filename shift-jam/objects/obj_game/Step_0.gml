/// Ondate: le Falene arrivano in formazioni geometriche, insieme a Lance e Inseguitori.
if (finale) exit;   // durante il finale non succede piu' niente

if (game_over) {
    if (keyboard_check_pressed(vk_shift)) { audio_play_sound(snd_menu, 5, false); room_goto(rm_game); }   // si riprova dallo spazio, senza rifare il prologo
    exit;
}

// i muri programmati arrivano anche mentre sale l'anteprima successiva
for (var wi = array_length(walls) - 1; wi >= 0; wi--) {
    walls[@ wi] -= 1;
    if (walls[wi] <= 0) { spawn_wall(); array_delete(walls, wi, 1); }
}

if (boss_spawned) exit;

// --- l'anteprima di un'ondata sta salendo sullo sfondo: quando e' uscita in alto, arrivano i nemici veri ---
if (preview_timer > 0) {
    preview_timer -= 1;
    if (preview_timer == 0) {
        spawn_wave();
        spawn_timer = max(90, 160 - wave * 4);   // pausa minima prima della prossima anteprima
    }
    exit;
}

// finite le ondate, quando lo schermo e' libero arriva il Custode:
// prima la sagoma della nave madre sale sullo sfondo, poi lei scende dall'alto
if (wave >= boss_wave) {
    if (instance_number(obj_enemy) == 0) {
        if (!boss_preview) {
            boss_preview = true;
            var bp = instance_create_layer(room_width / 2, room_height + 120, "Instances", obj_preview);
            bp.items = [[spr_boss_mothership, 0, 0, 0.9, 1]];
            bp.spd = 2.5;
            boss_timer = 330;
        } else {
            boss_timer -= 1;
            if (boss_timer <= 0) {
                boss_spawned = true;
                instance_create_layer(room_width / 2, -90, "Instances", obj_boss);
            }
        }
    }
    exit;
}

// la nuova ondata parte solo quando la precedente e' quasi finita (al massimo 2 nemici rimasti),
// e mai finche' ci sono Lance in alto: altrimenti la formazione dopo ci passerebbe in mezzo
if (instance_number(obj_enemy) > 2 || instance_exists(obj_spear)) spawn_timer = max(spawn_timer, 45);
spawn_timer -= 1;
if (spawn_timer <= 0) {
    wave += 1;
    spawn_preview();
    preview_timer = 210;   // il tempo che le sagome impiegano ad attraversare lo schermo
}
