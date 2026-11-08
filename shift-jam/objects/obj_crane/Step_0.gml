if (delay > 0) { delay -= 1; exit; }
t += 1;
if (t == 1) look = side;
if (hp < last_hp) flash = 4;
last_hp = hp;
if (flash > 0) flash -= 1;
var cx = room_width / 2, cy = 140, bt = t;
if (instance_exists(obj_boss)) { var bs = instance_nearest(x, y, obj_boss); cx = bs.x; cy = bs.y; bt = bs.t; }
var ox = x, oy = y;
if (t > arrive + hold) {
    // se ne va: sale e torna verso il suo lato
    lv = min(lv + 0.1, 4);
    x -= side * lv * 0.5;
    y -= lv;
    if (y < -40 || x < -60 || x > room_width + 60) { instance_destroy(); exit; }
} else {
    // il posto nel muro: le gru rimaste si stringono e chiudono i buchi
    var rk = 0, nn = 0;
    with (obj_crane) if (t <= arrive + hold) { nn += 1; if (slot < other.slot) rk += 1; }
    var drift = 26 * dsin(bt * 1.3);   // il muro scivola piano sotto i Koi: un buco non resta sotto la perla
    var hw = (nn - 1) / 2 * 28;         // meta' larghezza del muro (una gru ogni 28 pixel)
    var wc = clamp(cx + drift, hw + 14, room_width - hw - 14);   // il muro resta dentro lo schermo
    var tx = wc + (rk - (nn - 1) / 2) * 28;
    var ty = cy + 100 + 6 * dsin(bt * 4 + slot * 45);   // sotto la mala; un'onda leggera lungo il muro
    if (t <= arrive) {
        var k = t / arrive;
        k = k * k * (3 - 2 * k);
        x = lerp(x0, tx, k);
        y = lerp(y0, ty, k) - 40 * sin(pi * k);   // arriva con una curva
    } else {
        x = lerp(x, tx, 0.15);
        y = lerp(y, ty, 0.15);
    }
}
// di profilo: guarda dove vola (nel muro guarda verso il centro); il muso sale quando sale
var dx = x - ox, dy = y - oy;
if (abs(dx) > 1.2) look = sign(dx);
tilt += (clamp(-dy * 8, -25, 25) - tilt) * 0.2;
flap += (point_distance(ox, oy, x, y) > 1.2) ? 16 : 7;
// nel muro tiene le ali alte (si vede bene la gru), in volo le batte tutte
var inwall = (t > arrive + 10 && t <= arrive + hold);
hover += ((inwall ? 1 : 0) - hover) * 0.1;
