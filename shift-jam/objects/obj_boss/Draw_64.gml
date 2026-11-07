// vita del boss: una barra per fase
var w = room_width - 40;
var hp_frac = (phase == 1) ? (hp - hp_p2) / hp_p1 : hp / hp_p2;
draw_set_colour(c_dkgray);
draw_rectangle(20, 12, 20 + w, 16, false);   // in alto: HP e comandi ora stanno nel cruscotto
draw_set_colour((phase == 1) ? make_colour_rgb(130, 110, 170) : make_colour_rgb(225, 215, 190));
draw_rectangle(20, 12, 20 + w * clamp(hp_frac, 0, 1), 16, false);
// l'avviso sui grani d'oro ora compare sullo schermo del cruscotto (scr_console)
