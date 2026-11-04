// Alieno di terra: la sprite guarda in alto, la giro verso il mecha.
// Meta' grandezza: sono piccoli e devono ammucchiarsi.
draw_sprite_ext(spr_enemy_grunt, 0, x, y, 0.5, 0.5, face - 90, c_white, 1);
// (quando vola via per l'esplosione, "face" gira e la sprite ruota da sola)
