// Falena a pezzi: corpo e due ali che sbattono veloci, come una falena vera.
// la sprite guarda in alto (90 gradi): la giro nella direzione in cui vola
var ph = current_time * 1.1 + id * 53;     // ogni falena ha il suo ritmo
var flap = 14 * dsin(ph);                   // le ali si aprono e chiudono
global.draw_parts(spr_enemy_moth, [
    [20, 22, 5, 17, 24, 31,  flap, 0, 0],   // ala sinistra, perno all'attacco col corpo
    [39, 22, 5, 17, 39, 31, -flap, 0, 0],   // ala destra
    [25, 21, 14, 22, 32, 32, 0, 0, 0]       // corpo
], x, y, dir - 90, 1);

// RISALITA: prima che la fila esca da sotto il cruscotto, una freccia verde lampeggia sul bordo
if (form == 8 && idx == 0 && t < delay + 20 && (current_time div 120) mod 2 == 0) {
    var wx = (side == 1) ? 24 : room_width - 24;
    var wy = room_height - HUD_H - 10;
    draw_set_colour(make_colour_rgb(195, 255, 68));   // il verde dei nemici
    draw_triangle(wx, wy - 12, wx - 8, wy, wx + 8, wy, false);
    draw_triangle(wx, wy - 26, wx - 8, wy - 14, wx + 8, wy - 14, false);
    draw_set_colour(c_white);
}
