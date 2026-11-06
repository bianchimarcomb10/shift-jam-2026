// Falena a pezzi: corpo e due ali che sbattono veloci, come una falena vera.
// la sprite guarda in alto (90 gradi): la giro nella direzione in cui vola
var ph = current_time * 1.1 + id * 53;     // ogni falena ha il suo ritmo
var flap = 14 * dsin(ph);                   // le ali si aprono e chiudono
global.draw_parts(spr_enemy_moth, [
    [20, 22, 5, 17, 24, 31,  flap, 0, 0],   // ala sinistra, perno all'attacco col corpo
    [39, 22, 5, 17, 39, 31, -flap, 0, 0],   // ala destra
    [25, 21, 14, 22, 32, 32, 0, 0, 0]       // corpo
], x, y, dir - 90, 1);
