y += spd;

// HANGAR: dalla prua escono tre Falene alla volta, a ventaglio fisso (e ti costringono a cambiare forma)
if (!retired && y > 20) {
    launch_timer -= 1;
    if (launch_timer <= 0) {
        launch_timer = 170;
        var hx = x + launch_side * 18, hy = y + 44;   // la prua: la nave e' girata, il muso e' in basso
        // sempre lo stesso ventaglio, piegato dalla parte del lato di lancio: si impara a memoria
        // (prima mirava a te e le tre falene si ammucchiavano)
        for (var k = -1; k <= 1; k++) {
            var m = instance_create_layer(hx + k * 12, hy + 8 + (1 - abs(k)) * 18, "Instances", obj_moth);   // sotto la prua, lontani dalle torrette
            m.dir = 270 + k * 22 - launch_side * 12;
            m.spd = 2.6;
            m.home_time = 0;   // vanno dritte
        }
        launch_side *= -1;
    }
}

// --- lo scafo colpito: lampo, poi fumo sempre piu' fitto, poi ESPLODE ---
if (hull_flash > 0) hull_flash -= 1;
if (!smoke1 && hull_hp < hull_max * 2 / 3) { smoke1 = true; array_push(wrecks, [-12, 14]); }
if (!smoke2 && hull_hp < hull_max / 3)     { smoke2 = true; array_push(wrecks, [10, -16]); array_push(wrecks, [2, 30]); }
if (hull_hp <= 0) {
    // ABBATTUTA: lo scafo si spacca (animazione Destruction della Battlecruiser) e le sbarre saltano a catena dal centro
    var b = instance_create_layer(x, y, "Instances", obj_boom);
    b.spr = spr_boom_battlecruiser;
    b.f = 4;
    b.last = 14;
    b.sc = 1;
    b.rot = 180;
    b.spd = 0.2;   // piu' lenta: e' grande
    for (var r = 0; r < array_length(rows); r++) {
        for (var c = 0; c < array_length(cols); c++) {
            var bb = instance_create_layer(x + cols[c], y + rows[r], "Instances", obj_boom);
            bb.delay = 6 + abs(cols[c]) div 9 + r * 4;   // prima le sbarre vicine allo scafo, poi le lontane
            bb.sc = 0.9;
        }
    }
    with (obj_turret) if (ship == other.id) { silent = true; instance_destroy(); }   // saltano con le sbarre
    audio_play_sound(snd_enemy_die, 3, false, 1);
    save_checkpoint();
    instance_destroy();
    exit;
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

// CHECKPOINT: solo se la abbatti (sopra) o quando esce del tutto dallo schermo
if (y > room_height + 140) {
    save_checkpoint();
    instance_destroy();
}
