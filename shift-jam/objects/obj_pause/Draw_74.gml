/// Draw GUI Begin: in pausa, la fotografia dello schermo, scurita. Sopra obj_game ridisegna il cruscotto
/// (e obj_boss la sua barra), poi Draw GUI End scrive PAUSE.
if (!global.paused || !sprite_exists(pause_spr)) exit;
var gw = display_get_gui_width(), gh = display_get_gui_height();
draw_sprite_stretched(pause_spr, 0, 0, 0, gw, gh);
draw_set_alpha(0.55);
draw_set_colour(c_black);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);
draw_set_colour(c_white);
