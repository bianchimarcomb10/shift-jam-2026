// guarda sempre verso il giocatore
var face = 270;
if (instance_exists(obj_player)) face = point_direction(x, y, obj_player.x, obj_player.y);
draw_sprite_ext(spr_enemy_stalker, 0, x, y, 1, 1, face - 90, c_white, 1);
// il nucleo si accende nell'ultimo mezzo secondo prima del colpo
if (fire_timer < 30) {
    draw_set_colour(c_white);
    draw_circle(x, y, 3, false);
}
