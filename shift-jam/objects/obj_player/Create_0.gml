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
drill_charge = 0;       // TRIVELLA: colpi rimandati di fila (3 = carica piena, si lancia passando a navicella)
mech_scale = 1.2;       // il mecha e' un po' piu' grosso della navicella (la hitbox resta quella)
trail = [];             // scintille della scia del motore: [x, y, vita]
shift_flash = 0;        // > 0 dopo SHIFT: l'ensō azzurro del cambio
heal_t = 0;             // > 0 dopo aver preso un cuore: "+1" che sale

// Valori del GDD (sezione 4), da tarare provando
ship_speed = 4;         // px per frame
mech_speed = 2.5;
sweep_radius = 56;      // raggio della falciata

// ARMI SPECIALI della navicella: le lascia la PORTATRICE abbattuta (obj_carrier -> obj_powerup).
// Durano 10 secondi, come la stellina: servono a ripulire lo schermo. Funzionano solo da navicella,
// ma il tempo scorre anche da mecha. Una nuova arma sostituisce quella che hai.
special = 0;            // 0 nessuna, 1 RAZZI, 2 LASER, 3 VENTAGLIO
special_t = 0;          // fotogrammi rimasti (600 = 10 s)
special_total = 600;
special_cd = 0;         // ritmo dell'arma speciale
beam_on = false;        // il laser e' acceso in questo fotogramma (lo disegna il Draw)

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
    audio_play_sound(snd_shift, 2, false, 0.25);   // segnaposto: snd_rockets
}

/// VENTAGLIO: 5 globi azzurri. Il ventaglio si apre sempre di piu': stretto appena preso,
/// alla fine dei 10 secondi copre quasi tutto lo schermo. E in volo ogni globo si allarga ancora un po'.
special_fan = function() {
    var k = 1 - special_t / special_total;
    var gap = lerp(5, 24, k);   // gradi tra un globo e l'altro
    for (var i = -2; i <= 2; i++) {
        var o = instance_create_layer(x + i * 3, y - 12, "Instances", obj_shot);
        o.kind = 3;
        o.dmg = 2;
        o.hd = 90 + i * gap;
        o.v = 6.5;
        o.drift = i * lerp(0.05, 0.3, k);
    }
    audio_play_sound(snd_shot, 1, false, 0.2);
}

/// LASER: un raggio azzurro continuo fino in cima allo schermo. Passa attraverso tutto,
/// fa 15 danni al secondo a ogni nemico nella colonna e brucia i colpi nemici (anche i muri).
special_beam = function() {
    var bx = x, by = y - 12;
    var killed = false;
    with (obj_enemy) {
        if (object_index == obj_turret && armored) continue;
        if (y < by && y > -20 && abs(x - bx) < 6 + radius) {
            hp -= 0.25;
            if (hp <= 0) { killed = true; global.enemy_boom(id); instance_destroy(); }
        }
    }
    if (killed) audio_play_sound(snd_enemy_die, 3, false, 0.6);
    with (obj_ebullet) if (y < by && abs(x - bx) < 8) instance_destroy();
    with (obj_bigship) if (y < by && abs(x - bx) < 30) { hull_hp -= 0.25; hull_flash = 3; }
    if (special_cd == 0) { audio_play_sound(snd_shot, 1, false, 0.12); special_cd = 6; }   // segnaposto: snd_beam
}
