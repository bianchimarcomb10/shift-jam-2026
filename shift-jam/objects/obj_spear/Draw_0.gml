// Lancia a pezzi: scafo e due motori laterali che respirano.
// quando carica il colpo i motori si stringono contro lo scafo.
// girata di 180 gradi: guarda verso il basso, verso il giocatore
var ph = current_time * 0.35 + id * 41;
var pod = 1 + dsin(ph);
if (charge > 0) pod = -(30 - charge) / 30 * 2;   // si stringono sempre di piu' mentre carica
global.draw_parts(spr_enemy_spear, [
    [14, 29, 6, 19, 19, 38, 0, -pod, 0],   // motore sinistro
    [44, 29, 6, 19, 44, 38, 0,  pod, 0],   // motore destro
    [20, 11, 24, 39, 32, 32, 0, 0, 0]      // scafo
], x, y, 180, 1);
// avviso: la bocca del cannone si accende mezzo secondo prima del colpo
if (charge > 0) {
    draw_set_colour(c_white);
    draw_circle(x, y + 14, 2 + (30 - charge) / 10, false);
}
