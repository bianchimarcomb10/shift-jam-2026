// Fregata: stessa nave della Lancia, a pezzi. Corre veloce: i motori vibrano.
// la sprite guarda in alto: la giro verso il lato in cui vola
var pod = 0.5 + 0.5 * dsin(current_time * 1.5);
global.draw_parts(spr_enemy_spear, [
    [14, 29, 6, 19, 19, 38, 0, -pod, 0],
    [44, 29, 6, 19, 44, 38, 0,  pod, 0],
    [20, 11, 24, 39, 32, 32, 0, 0, 0]
], x, y, (side == 1) ? -90 : 90, 1);
