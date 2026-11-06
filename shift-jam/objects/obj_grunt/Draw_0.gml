// Alieno di terra, scomposto come il mecha: lo sprite (Kla'ed Scout) e' tagliato in 3 pezzi,
// corpo e due chele. Le chele si aprono e chiudono mentre cammina, e mordono quando e' aggrappato.
var sc = 1;              // grandezza (prima era 0.5: troppo piccoli)
var R = face - 90;       // la sprite guarda in alto: la giro verso il mecha
var swing;
if (fling) swing = -25;                                   // sbalzato via: chele spalancate
else if (clinging_now) swing = 6 + 4 * dsin(anim * 4);    // aggrappato: chele strette che mordono
else swing = -10 + 12 * dsin(anim);                        // cammina: chele che remano

// ogni pezzo: [sinistra, alto, larghezza, altezza, perno x, perno y, verso della rotazione]
var parts = [
    [21, 24, 7, 18, 27, 32,  1],   // chela sinistra, ruota attorno alla spalla
    [36, 24, 7, 17, 36, 32, -1],   // chela destra
    [28, 23, 8, 22, 32, 32,  0]    // corpo, non ruota
];
for (var i = 0; i < array_length(parts); i++) {
    var p = parts[i];
    var a = swing * p[6];
    // centro del pezzo rispetto al perno, ruotato della chela
    var cx = (p[0] + p[2] / 2 - p[4]) * sc;
    var cy = (p[1] + p[3] / 2 - p[5]) * sc;
    var vx = lengthdir_x(point_distance(0, 0, cx, cy), point_direction(0, 0, cx, cy) + a) + (p[4] - 32) * sc;
    var vy = lengthdir_y(point_distance(0, 0, cx, cy), point_direction(0, 0, cx, cy) + a) + (p[5] - 32) * sc;
    // poi tutto ruotato verso il mecha
    var wx = x + lengthdir_x(point_distance(0, 0, vx, vy), point_direction(0, 0, vx, vy) + R);
    var wy = y + lengthdir_y(point_distance(0, 0, vx, vy), point_direction(0, 0, vx, vy) + R);
    // draw_sprite_general ruota attorno all'angolo in alto a sinistra: lo ricavo dal centro
    var hw = p[2] / 2 * sc, hh = p[3] / 2 * sc;
    var dd = point_direction(0, 0, -hw, -hh) + R + a;
    var dl = point_distance(0, 0, hw, hh);
    draw_sprite_general(spr_enemy_grunt, 0, p[0], p[1], p[2], p[3],
        wx + lengthdir_x(dl, dd), wy + lengthdir_y(dl, dd), sc, sc, R + a,
        c_white, c_white, c_white, c_white, 1);
}
