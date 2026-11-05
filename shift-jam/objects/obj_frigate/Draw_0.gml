// la sprite guarda in alto: la giro verso il lato in cui vola
draw_sprite_ext(spr_enemy_spear, 0, x, y, 1, 1, (side == 1) ? -90 : 90, c_white, 1);
