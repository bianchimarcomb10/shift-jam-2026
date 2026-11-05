/// Interfaccia provvisoria: vita, forma attuale, comandi.
if (finale) exit;   // nel finale lo schermo resta vuoto
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_text(8, 8, "HP: " + string(global.hp));
if (instance_exists(obj_player)) {
    draw_text(8, 24, "FORM: " + ((obj_player.form == 0) ? "SHIP" : "MECHA"));
}
// comandi su due righe, centrati: su una riga sola uscivano dallo schermo
draw_set_halign(fa_center);
draw_text(display_get_gui_width() / 2, room_height - 36, "WASD/ARROWS: MOVE");
draw_text(display_get_gui_width() / 2, room_height - 20, "Z: ATTACK   SHIFT: FORM");
draw_set_halign(fa_left);

if (game_over) {
    // enorme, lampeggiante: l'unica cosa da fare e' rialzarsi
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var pulse = (display_get_gui_width() - 28) / string_width("STRUGGLE") * (0.95 + 0.04 * dsin(current_time * 0.4));
    if ((current_time div 400) mod 2 == 0) draw_set_colour(c_white); else draw_set_colour(make_colour_rgb(255, 80, 160));
    draw_text_transformed(room_width / 2, room_height / 2, "SHIFT\nTO\nSTRUGGLE", pulse, pulse, 0);
    draw_set_colour(c_white);
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}
