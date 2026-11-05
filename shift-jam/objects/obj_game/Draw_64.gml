/// Interfaccia provvisoria: vita, forma attuale, comandi.
if (finale) exit;   // nel finale lo schermo resta vuoto
draw_set_colour(c_white);
draw_set_halign(fa_left);
// il sutra della ripartenza: entra e sfuma, al centro dello schermo
if (sutra_timer > 0 && sutra >= 0) {
    var sa = clamp(min((300 - sutra_timer) / 45, sutra_timer / 60), 0, 1);
    var gw = display_get_gui_width();
    draw_set_alpha(sa);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_ext(gw / 2, room_height / 2 - 30, sutras[sutra][0], 16, gw - 48);
    draw_text(gw / 2, room_height / 2 + 50, sutras[sutra][1]);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
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
