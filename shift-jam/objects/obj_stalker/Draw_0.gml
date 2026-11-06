// guarda sempre verso il giocatore
var face = 270;
if (leaving) face = ldir;
else if (instance_exists(obj_player)) face = point_direction(x, y, obj_player.x, obj_player.y);
// Inseguitore a pezzi: corpo, due bracci a tenaglia e due piedi.
// i bracci si aprono piano mentre ti segue, si spalancano prima di sparare, si chiudono quando scappa
var ph = current_time * 0.4 + id * 29;
var arm = 6 * dsin(ph);
if (leaving) arm = 12;                              // bracci chiusi in avanti: fugge
else if (fire_timer < 30) arm = -18 + 2 * dsin(ph * 6);   // spalancati e tremanti: sta per sparare
global.draw_parts(spr_enemy_stalker, [
    [18, 15, 10, 20, 27, 29, -arm, 0, 0],   // braccio sinistro, perno alla spalla
    [36, 15, 10, 20, 36, 29,  arm, 0, 0],   // braccio destro
    [23, 35, 5, 7, 25, 35, 0, 0, 0],        // piede sinistro
    [36, 35, 5, 7, 38, 35, 0, 0, 0],        // piede destro
    [28, 21, 8, 22, 32, 32, 0, 0, 0]        // corpo
], x, y, face - 90, 1);
// il nucleo si accende nell'ultimo mezzo secondo prima del colpo
if (fire_timer < 30 && !leaving) {
    draw_set_colour(c_white);
    draw_circle(x, y, 3, false);
}
