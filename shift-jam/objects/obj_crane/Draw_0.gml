// gru di carta DI PROFILO, come si riconosce: corpo a rombo, collo e coda a punta verso l'alto,
// la testa piegata, due ali grandi che battono. Ogni parte ha una faccia chiara e una scura, come la carta piegata.
// Oro = roba del boss.
var hit = (flash > 0);
var light = hit ? c_white : make_colour_rgb(255, 222, 130);
var mid   = hit ? c_white : make_colour_rgb(232, 178, 66);
var dark  = hit ? c_white : make_colour_rgb(168, 112, 34);
var ink = make_colour_rgb(46, 28, 10);
var wing = lerp(dsin(flap), 0.6 + 0.4 * dsin(flap), hover);   // da +1 (ali su) a -1 (ali giu'); nel muro restano alte
var sc = 1.1;
// [u in avanti, w in su] -> schermo: ruotato di tilt, specchiato se guarda a sinistra
var ca = dcos(tilt) * sc, sa = dsin(tilt) * sc;
var tris = [
    // ala lontana (dietro, scura): un po' piu' indietro e piu' corta
    [[-5, 1], [ 3, 1], [-3, 2 + 15 * wing], dark],
    // coda e collo, sottili, verso l'alto
    [[-4, 0], [-7, 2], [-15, 11], mid],
    [[ 4, 0], [ 7, 2], [ 14, 12], light],
    // la testa piegata in avanti
    [[13, 11], [15, 13], [19, 9], dark],
    // corpo a rombo: due facce
    [[-7, 1], [ 7, 1], [ 0, -4], mid],
    [[-7, 1], [ 7, 1], [ 0, 3], light],
    // ala vicina (davanti, chiara), con la piega a meta'
    [[-4, 2], [ 4, 2], [-1, 3 + 18 * wing], light],
    [[-4, 2], [-1, 2], [-1, 3 + 18 * wing], mid]
];
for (var i = 0; i < array_length(tris); i++) {
    var q = tris[i];
    var xs = [0, 0, 0], ys = [0, 0, 0];
    for (var j = 0; j < 3; j++) {
        var u = q[j][0] * look, w = q[j][1];
        xs[j] = x + u * ca - w * sa * look;
        ys[j] = y - (w * ca + u * sa * look);
    }
    draw_set_colour(q[3]);
    draw_triangle(xs[0], ys[0], xs[1], ys[1], xs[2], ys[2], false);
    draw_set_colour(ink);
    draw_triangle(xs[0], ys[0], xs[1], ys[1], xs[2], ys[2], true);
}
draw_set_colour(c_white);
