/// Il pilota: navicella (forma 0) o mecha (forma 1).
form = 0;               // 0 = navicella, 1 = mecha
transform_timer = 0;    // > 0 durante la trasformazione
switch_cooldown = 0;    // tempo minimo tra due SHIFT
fire_cooldown = 0;      // ritmo dello sparo
sweep_cooldown = 0;     // ritmo della falciata
sweep_anim = 0;         // per quanti frame si disegna la falciata
invuln = 0;             // invulnerabilita' dopo un colpo
parry_radius = 72;      // la falciata annulla i proiettili un po' oltre la lama
sparks = [];            // scintille dei proiettili annullati: [x, y, vita]
tilt = 0;               // inclinazione della navicella in virata
if (!variable_global_exists("has_drill")) global.has_drill = false;   // la imposta obj_game; qui solo per sicurezza
drill_charge = 0;       // TRIVELLA: PARATE andate a segno (falciate che hanno rimandato almeno un colpo su un nemico)
drill_full = 10;        // a 10 la trivella e' carica: si lancia passando a navicella
sweep_n = 0;            // numero della falciata: i colpi che rimanda se lo portano dietro (sid)
drill_last = -1;        // l'ultima falciata che ha gia' caricato la trivella
/// un colpo parato (della falciata _sid) ha colpito un nemico: con la trivella in mano la carica sale di uno,
/// ma UNA SOLA VOLTA per falciata, anche se ne rimanda tanti (prima ogni colpo contava: bastavano 3 parate)
drill_add = function(_sid) {
    if (!global.has_drill || drill_charge >= drill_full) return;
    if (_sid <= drill_last) return;   // questa falciata ha gia' caricato (o e' piu' vecchia)
    drill_last = _sid;
    drill_charge += 1;
    if (drill_charge >= drill_full) audio_play_sound(snd_drill_full, 9, false, 0.9 * SFX_GAIN);   // carica piena: "pronta" (tools/game_sounds.py)
}
mech_scale = 1.2;       // il mecha e' un po' piu' grosso della navicella (la hitbox resta quella)
trail = [];             // scintille della scia del motore: [x, y, vita]
shift_flash = 0;        // > 0 dopo SHIFT: l'ensō azzurro del cambio
heal_t = 0;             // > 0 dopo aver preso un cuore: "+1" che sale

// Valori del GDD (sezione 4), da tarare provando
ship_speed = 4;         // px per frame
mech_speed = 2.5;
sweep_radius = 56;      // raggio della falciata

// ARMI SPECIALI della navicella: le lascia la PORTATRICE abbattuta (obj_carrier -> obj_powerup).
// Come in Metal Slug sono CONSUMABILI: hanno munizioni, si consumano solo sparando, e finite
// si torna allo sparo normale. Funzionano solo da navicella: da mecha le munizioni restano li'.
// Presa la stessa arma, le munizioni si sommano; un'arma diversa sostituisce quella che hai.
special = 0;            // 0 nessuna, 1 RAZZI, 2 LASER, 3 VENTAGLIO
special_ammo = 0;       // munizioni rimaste
special_full = 1;       // munizioni al momento della presa (per la barretta)
special_max = [0, 80, 480, 60];   // munizioni di ogni arma: 80 razzi (4 a raffica), 480 = 8 s di raggio, 60 ventagli
/// consuma munizioni; finite, si torna allo sparo normale
special_use = function(_n) {
    special_ammo -= _n;
    if (special_ammo <= 0) { special_ammo = 0; special = 0; special_cd = 0; }
}
special_cd = 0;         // ritmo dell'arma speciale
beam_on = false;        // il laser e' acceso in questo fotogramma (lo disegna il Draw)
beam_top = -20;         // fin dove arriva il raggio (si ferma su scudi e gru del boss)

/// RAZZI: 4 alla volta, partono a ventaglio e ognuno insegue un nemico diverso (i quattro piu' vicini)
special_rockets = function() {
    var chosen = [];
    for (var k = 0; k < 4; k++) {
        var best = noone, bd = 100000;
        with (obj_enemy) {
            if (retreat || y < 0 || y > room_height) continue;
            if (object_index == obj_turret && armored) continue;   // la corazza non si buca
            if (array_contains(chosen, id)) continue;
            var d = point_distance(x, y, other.x, other.y);
            if (d < bd) { bd = d; best = id; }
        }
        array_push(chosen, best);
    }
    var offs = [-12, -5, 5, 12];
    var dirs = [160, 115, 65, 20];   // in fuori, poi curvano verso il bersaglio
    for (var r = 0; r < 4; r++) {
        var o = instance_create_layer(x + offs[r], y - 4, "Instances", obj_shot);
        o.kind = 1;
        o.dmg = 2;
        o.hd = dirs[r];
        o.v = 2;
        o.tgt = (chosen[r] != noone) ? chosen[r] : chosen[0];
    }
    audio_play_sound(snd_rockets, 2, false, 0.25 * SFX_GAIN);   // la salva di razzi (tools/game_sounds.py)
}

/// VENTAGLIO: 5 globi azzurri. Il ventaglio si apre sempre di piu': stretto appena preso,
/// man mano che consumi le munizioni copre quasi tutto lo schermo. E in volo ogni globo si allarga ancora un po'.
special_fan = function() {
    var k = 1 - special_ammo / special_full;   // si apre man mano che consumi le munizioni
    var gap = lerp(5, 24, k);   // gradi tra un globo e l'altro
    for (var i = -2; i <= 2; i++) {
        var o = instance_create_layer(x + i * 3, y - 12, "Instances", obj_shot);
        o.kind = 3;
        o.dmg = 2;
        o.hd = 90 + i * gap;
        o.v = 6.5;
        o.drift = i * lerp(0.05, 0.3, k);
    }
    audio_play_sound(snd_shot, 1, false, 0.2 * SFX_GAIN);
}

/// LASER: un raggio azzurro continuo fino in cima allo schermo. Passa attraverso tutto (tranne scudi e gru del boss),
/// fa 15 danni al secondo a ogni nemico nella colonna e brucia i colpi nemici (anche i muri).
special_beam = function() {
    var bx = x, by = y - 12;
    var killed = false;
    // SCUDI e GRU DI CARTA del boss fermano il raggio: arriva solo fino al primo che incontra
    var top = -20;
    with (obj_shield) if (y < by && abs(x - bx) < 6 + radius) top = max(top, y);
    with (obj_crane) if (y < by && abs(x - bx) < 6 + radius) top = max(top, y);
    beam_top = top;
    with (obj_enemy) {
        if (object_index == obj_turret && armored) continue;
        if (y < by && y >= top && abs(x - bx) < 6 + radius) {
            hp -= (object_index == obj_shield || object_index == obj_crane) ? 0.1 : 0.25;   // scudi e gru reggono di piu'
            if (hp <= 0) { killed = true; global.enemy_boom(id); instance_destroy(); }
        }
    }
    if (killed) audio_play_sound(snd_enemy_die, 3, false, 0.6 * SFX_GAIN);
    with (obj_ebullet) if (y < by && y > top && abs(x - bx) < 8) instance_destroy();
    with (obj_bigship) if (y < by && y > top && abs(x - bx) < 30) { hull_hp -= 0.25; hull_flash = 3; }
    if (special_cd == 0) { audio_play_sound(snd_laser, 2, false, 0.35 * SFX_GAIN); special_cd = 22; }   // snd_laser (file di Chelios): uno ogni 0,37 s, quanto dura
}
