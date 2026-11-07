/// Colpo della navicella: sale dritto e colpisce il primo nemico che tocca.
/// Colpo PARATO: parte spinto via dal mecha, lento, poi curva verso un nemico accelerando,
/// come una scintilla che cerca casa (non una palla colpita con la mazza).
if (parried || kind == 1) {
    // (anche i RAZZI dell'arma speciale volano cosi': partono a ventaglio e curvano sul bersaglio)
    life += 1;
    if (!instance_exists(tgt)) tgt = instance_nearest(x, y, obj_enemy);
    var want = (tgt != noone) ? point_direction(x, y, tgt.x, tgt.y) : 90;   // nessun nemico: sale e se ne va
    var turn = min(1 + life * 0.35, 10);   // all'inizio gira poco (vola via), poi sempre di piu'
    hd += clamp(angle_difference(want, hd), -turn, turn);
    v = min(v + 0.2, 8);
    x += lengthdir_x(v, hd);
    y += lengthdir_y(v, hd);
    array_push(trail, [x, y]);
    if (array_length(trail) > 8) array_delete(trail, 0, 1);
    if (life > 240 || x < -20 || x > room_width + 20 || y < -20 || y > room_height + 20) { instance_destroy(); exit; }
} else if (kind == 3) {
    // globo del VENTAGLIO: vola dritto e si allarga piano verso l'esterno
    life += 1;
    hd += drift;
    x += lengthdir_x(v, hd);
    y += lengthdir_y(v, hd);
    if (x < -20 || x > room_width + 20 || y < -20) { instance_destroy(); exit; }
} else {
    y -= 9;
    if (y < -10) { instance_destroy(); exit; }
}

// il raggio della nave laser brucia i colpi che ci passano dentro: la nave si colpisce solo dai lati
var burnt = false;
with (obj_laser) if (beam_w > 3 && other.y > y + 20 && abs(other.x - x) < beam_w) burnt = true;
if (burnt) { instance_destroy(); exit; }

var e = instance_nearest(x, y, obj_enemy);
if (e != noone && point_distance(x, y, e.x, e.y) < e.radius + ((kind == 3) ? 6 : 3)) {
    // torretta corazzata: lo sparo normale rimbalza (lampo bianco) senza danno; solo i colpi parati la feriscono
    if (e.object_index == obj_turret && e.armored && !parried) {
        e.flash = 6;
        instance_destroy();
        exit;
    }
    e.hp -= dmg;
    if (kind == 1 && instance_exists(obj_player)) array_push(obj_player.sparks, [x, y, 12]);   // il razzo scoppia
    if (e.hp <= 0) {
        global.enemy_boom(e);
        with (e) instance_destroy();
        audio_play_sound(snd_enemy_die, 3, false, 0.6);
    }
    instance_destroy();
    exit;
}

// lo SCAFO della nave enorme: tostissimo, ma si puo' abbattere (i colpi parati fanno piu' male)
if (instance_exists(obj_bigship)) {
    var bs = instance_nearest(x, y, obj_bigship);
    if (abs(x - bs.x) < 30 && y > bs.y - 36 && y < bs.y + 50) {
        bs.hull_hp -= parried ? 3 : dmg;
        bs.hull_flash = 3;
        instance_destroy();
        exit;
    }
}
