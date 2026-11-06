/// Colpo della navicella: sale dritto e colpisce il primo nemico che tocca.
/// Colpo PARATO: parte spinto via dal mecha, lento, poi curva verso un nemico accelerando,
/// come una scintilla che cerca casa (non una palla colpita con la mazza).
if (parried) {
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
} else {
    y -= 9;
    if (y < -10) { instance_destroy(); exit; }
}

var e = instance_nearest(x, y, obj_enemy);
if (e != noone && point_distance(x, y, e.x, e.y) < e.radius + 3) {
    // torretta corazzata: lo sparo normale rimbalza (lampo bianco) senza danno; solo i colpi parati la feriscono
    if (e.object_index == obj_turret && e.armored && !parried) {
        e.flash = 6;
        instance_destroy();
        exit;
    }
    e.hp -= 1;
    if (e.hp <= 0) {
        global.enemy_boom(e);
        with (e) instance_destroy();
        audio_play_sound(snd_enemy_die, 3, false, 0.6);
    }
    instance_destroy();
}
