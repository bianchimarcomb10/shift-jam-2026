v = min(v + 0.25, 9);
y -= v;
sc = min(sc + 0.05, 4.5);   // si ingrandisce sempre di piu'
ph += 30;
var cy = y - 12 * sc;       // il punto che colpisce: a meta' strada verso la punta
// buca i colpi nemici che incontra
with (obj_ebullet) if (point_distance(x, y, other.x, cy) < 8 * other.sc) instance_destroy();
// il primo nemico che tocca prende 10 colpi
var e = instance_nearest(x, cy, obj_enemy);
if (e != noone && point_distance(x, cy, e.x, e.y) < e.radius + 7 * sc) {
    e.hp -= 20;   // 10 colpi parati per caricarla: deve fare male (era 10)
    var b = instance_create_layer(x, cy, "Instances", obj_boom);
    b.sc = 1.6;
    audio_play_sound(snd_explosion_big, 9, false, 0.8);
    if (e.hp <= 0) {
        global.enemy_boom(e);
        with (e) instance_destroy();
        audio_play_sound(snd_enemy_die, 3, false, 0.6);
    }
    instance_destroy();
    exit;
}
if (y < -10) instance_destroy();   // mancato: esce dall'alto
