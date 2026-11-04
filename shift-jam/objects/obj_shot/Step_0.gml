/// Colpo della navicella: sale dritto e colpisce il primo nemico che tocca.
y -= 9;
if (y < -10) { instance_destroy(); exit; }

var e = instance_nearest(x, y, obj_enemy);
if (e != noone && point_distance(x, y, e.x, e.y) < e.radius + 3) {
    e.hp -= 1;
    if (e.hp <= 0) {
        with (e) instance_destroy();
        audio_play_sound(snd_enemy_die, 3, false);
    }
    instance_destroy();
}
