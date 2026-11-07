// Lancia a pezzi: scafo e due motori laterali che respirano.
// quando carica il colpo i motori si stringono contro lo scafo.
// girata di 180 gradi: guarda verso il basso, verso il giocatore
var ph = current_time * 0.35 + id * 41;
var pod = 1 + dsin(ph);
if (charge > 0) pod = -(30 - charge) / 30 * 2;   // si stringono sempre di piu' mentre carica
// la Lancia speciale e' bianca e nera (spr_enemy_spear_mono): annuncia lo yin-yang del cuore che lascia
global.draw_parts(special ? spr_enemy_spear_mono : spr_enemy_spear, [
    [14, 29, 6, 19, 19, 38, 0, -pod, 0],   // motore sinistro
    [44, 29, 6, 19, 44, 38, 0,  pod, 0],   // motore destro
    [20, 11, 24, 39, 32, 32, 0, 0, 0]      // scafo
], x, y, 180, 1);
// avviso: la bocca del cannone si accende mezzo secondo prima del colpo
if (charge > 0) {
    draw_set_colour(c_white);
    draw_circle(x, y + 14, 2 + (30 - charge) / 10, false);
}
// AVVISO DEL DISEGNO: in magenta, come i colpi che stanno per uscire, mostra gia' la loro forma
if (pat > 0 && charge > 0) {
    var gk = (30 - charge) / 30;   // 0 -> 1 mentre carica
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.25 + 0.45 * gk);
    draw_set_colour(make_colour_rgb(255, 40, 190));
    if (pat == 1) {
        // SPIRALE: i tre bracci, nella direzione esatta in cui partiranno
        for (var arm = 0; arm < 3; arm++) {
            var aa = spin + arm * 120;
            draw_line_width(x, y + 6, x + lengthdir_x(10 + 22 * gk, aa), y + 6 + lengthdir_y(10 + 22 * gk, aa), 2);
        }
    } else if (pat == 2) {
        // ANELLO: un cerchio che si stringe sulla Lancia
        draw_circle(x, y + 6, 34 - 20 * gk, true);
        draw_circle(x, y + 6, 35 - 20 * gk, true);
    } else {
        // PIOGGIA: la linea della colonna, fino in fondo allo schermo
        for (var ly = y + 18; ly < room_height - HUD_H; ly += 10) draw_line_width(x, ly, x, ly + 4, 2);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    draw_set_colour(c_white);
}
