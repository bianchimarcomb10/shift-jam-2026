/// Draw GUI End: la scritta della pausa e quella dell'audio (M), sopra a tutto.
var gw = display_get_gui_width();
draw_set_font(fnt_main);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(c_white);

if (global.paused) {
    // al centro dell'area di gioco: nella partita sopra il cruscotto
    var cy = (room == rm_game) ? (room_height - HUD_H) / 2 : room_height / 2;
    draw_text_transformed(gw / 2, cy - 24, "PAUSE", 2, 2, 0);
    draw_text(gw / 2, cy + 16, "P OR ESC: RESUME");
    draw_text(gw / 2, cy + 36, global.muted ? "M: SOUND ON" : "M: SOUND OFF");
}

if (mute_msg > 0) {
    // in alto, sotto la barra del boss
    draw_set_alpha(min(1, mute_msg / 20));
    draw_text(gw / 2, 34, global.muted ? "SOUND OFF" : "SOUND ON");
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
