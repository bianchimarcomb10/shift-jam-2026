t += 1;
if (hp < last_hp) flash = 4;
last_hp = hp;
if (flash > 0) flash -= 1;
if (!instance_exists(obj_boss)) { instance_destroy(); exit; }
var bs = instance_nearest(x, y, obj_boss);
// il suo posto sull'arco: lo spazio fra le navette dipende da quante sono, l'arco oscilla con l'orologio del boss
// (tutte insieme, quindi non si toccano mai)
var n = bs.shield_n;
var gap = (n >= 5) ? 22 : 26;
var a = 270 + (slot - (n - 1) / 2) * gap + 24 * dsin(bs.t * 1.1);
// HANGAR aperto: la meta' sinistra va sul fianco sinistro, la destra sul destro (sopra la strada delle Falene)
var so = bs.shield_open;
var rr = 118;
if (so > 0) {
    var op = clamp(min((150 - so) / 20, so / 30), 0, 1);
    op = op * op * (3 - 2 * op);
    var nl = ceil(n / 2);                       // quante vanno a sinistra
    var a1 = (slot < nl) ? 190 - (nl - 1 - slot) * 25 : 350 + (slot - nl) * 25;
    a += angle_difference(a1, a) * op;
    rr = lerp(118, 100, op);   // sui fianchi un po' piu' vicine, per restare dentro lo schermo
}
var tx = bs.x + lengthdir_x(rr, a);   // sotto lo scafo, non sopra
var ty = bs.y + 6 + lengthdir_y(rr, a) * 0.9;
if (t <= 60) {
    // esce dall'hangar e va al suo posto in un secondo
    var k = t / 60;
    k = k * k * (3 - 2 * k);
    x = lerp(sx, tx, k);
    y = lerp(sy, ty, k);
} else {
    x = lerp(x, tx, 0.15);
    y = lerp(y, ty, 0.15);
}
