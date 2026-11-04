// Alieno di terra. Usa la sprite spr_enemy_grunt se e' stata importata,
// altrimenti resta il pallino verde (cosi' il gioco parte comunque).
var spr = asset_get_index("spr_enemy_grunt");
if (spr != -1) {
    // la sprite guarda in alto: la giro verso il mecha; meta' grandezza, sono piccoli
    draw_sprite_ext(spr, 0, x, y, 0.5, 0.5, face - 90, c_white, 1);
} else {
    draw_set_colour(make_colour_rgb(120, 160, 90));
    draw_circle(x, y, 5, false);
    draw_set_colour(make_colour_rgb(40, 60, 30));
    draw_circle(x, y, 5, true);
}
