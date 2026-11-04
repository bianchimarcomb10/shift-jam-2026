// girata di 180 gradi: guarda verso il basso, verso il giocatore
draw_sprite_ext(spr_enemy_spear, 0, x, y, 1, 1, 180, c_white, 1);
// avviso: la bocca del cannone si accende mezzo secondo prima del colpo
if (charge > 0) {
    draw_set_colour(c_white);
    draw_circle(x, y + 14, 2 + (30 - charge) / 10, false);
}
