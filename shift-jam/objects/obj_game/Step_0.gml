/// Ondate a TEMPO FISSO (scaletta in obj_game Create, wave_secs), poi la trivella (15 s), poi il boss.
if (finale) exit;   // durante il finale non succede piu' niente
if (sutra_timer > 0) sutra_timer -= 1;
if (cp_timer > 0) cp_timer -= 1;
if (drill_phrase > 0) drill_phrase -= 1;
if (boss_phrase > 0) boss_phrase -= 1;

if (game_over) {
    if (global.music != -1) music_stop(1500);   // la musica sfuma
    if (keyboard_check_pressed(vk_shift)) { audio_play_sound(snd_menu, 5, false); global.continues += 1; room_goto(rm_game); }   // si riprova dallo spazio, senza rifare il prologo
    exit;
}

// i muri programmati arrivano anche mentre sale l'anteprima successiva
for (var wi = array_length(walls) - 1; wi >= 0; wi--) {
    var wl = walls[wi];   // [conto alla rovescia, tipo, x della porta]
    wl[@ 0] -= 1;
    if (wl[0] <= 0) { array_delete(walls, wi, 1); spawn_wall(wl[1], wl[2]); }
}
// i comandi "at" dell'ondata: partono quando il loro conto alla rovescia arriva a zero
for (var qi = array_length(pending) - 1; qi >= 0; qi--) {
    var pc = pending[qi];   // [conto alla rovescia, comando]
    pc[@ 0] -= 1;
    if (pc[0] <= 0) { array_delete(pending, qi, 1); spawn_cmd(pc[1]); }
}

if (boss_spawned) exit;

// --- attesa iniziale: 2 secondi (5 dopo un continue, mentre si legge il sutra) ---
if (lead > 0) {
    // la musica parte 2 s prima della prima ondata: dopo un continue riparte dal punto giusto del brano
    if (lead == 120) {
        // dal prologo: mus_intro sfuma dentro mus_waves in 2 s; dopo un continue parte e basta
        if (wave < boss_wave) music_play("mus_waves", false, (global.music != -1) ? 2000 : 0, music_offset(wave));
    }
    lead -= 1;
    if (lead > 0) exit;
    if (wave < boss_wave) {
        wave += 1;
        wave_t = 0;
        spawn_preview();
    } else {
        seq_t = 0;   // si riparte dal checkpoint del boss: subito la trivella
    }
}

// --- LE ONDATE: ognuna dura sempre wave_secs secondi ---
//   0     le sagome dell'ondata salgono sullo sfondo
//   3,5 s arrivano i nemici veri
//   fine  i nemici rimasti si ritirano e parte l'ondata dopo
if (seq_t < 0) {
    wave_t += 1;
    if (wave_t == 210) spawn_wave();   // 210 fotogrammi: il tempo che le sagome impiegano ad attraversare lo schermo
    if (wave_t >= wave_secs[wave - 1] * 60) {
        retreat_all();
        pending = [];   // quello che non e' ancora partito non parte piu': la scaletta resta fissa
        if (wave < boss_wave) {
            wave += 1;
            wave_t = 0;
            spawn_preview();
        } else {
            seq_t = 0;   // finite le ondate: la trivella
        }
    }
    exit;
}

// --- LA TRIVELLA: 15 secondi fissi, poi il boss ---
//   0    s  "Silence is near." (checkpoint)
//   2    s  la trivella compare in alto, enorme, e piomba sul mecha (obj_drill_pickup)
//   5    s  si pianta nel mecha: "YOUR DRILL IS THE DRILL..."
//   9,5  s  la sagoma della nave madre sale sullo sfondo
//   15   s  il boss scende dall'alto: "WHO THE HELL DO YOU THINK I AM?!"
if (seq_t == 0) {
    // se il file non c'e' continua mus_waves; dopo un continue dal boss, mus_waves riparte da 4:06
    if (!music_play("mus_drill", false, 400) && global.music == -1) music_play("mus_waves", false, 0, music_offset(boss_wave) + 2);
    // CHECKPOINT: sei arrivato al boss finale. Se muori, riparti da qui (trivella e poi boss)
    if (global.checkpoint < boss_wave) {
        global.checkpoint = boss_wave;
        cp_timer = cp_total;
        cp_text = "Silence is near.";
    }
    drill_state = 1;
}
if (seq_t == 120) instance_create_layer(room_width / 2, -200, "Instances", obj_drill_pickup);   // si pianta da sola dopo 3 s
if (seq_t == 570) {
    boss_preview = true;
    var bp = instance_create_layer(room_width / 2, room_height + 120, "Instances", obj_preview);
    bp.items = [[spr_boss_mothership, 0, 0, 0.9, 1]];
    bp.spd = 2.5;
}
seq_t += 1;
if (seq_t >= seq_len) {
    boss_spawned = true;
    instance_create_layer(room_width / 2, -90, "Instances", obj_boss);
    boss_phrase = 240;   // "WHO THE HELL DO YOU THINK I AM?!"
    music_play("mus_boss", true, 300);
}
