/// Interfaccia provvisoria: vita, forma attuale, comandi.
if (finale) exit;   // nel finale lo schermo resta vuoto
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_text(8, 8, "HP: " + string(global.hp));
if (instance_exists(obj_player)) {
    draw_text(8, 24, "FORM: " + ((obj_player.form == 0) ? "SHIP" : "MECHA"));
}
draw_text(8, room_height - 20, "WASD/ARROWS  Z ATTACK  SHIFT FORM");

if (game_over) {
    // enorme, lampeggiante: l'unica cosa da fare e' rialzarsi
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var pulse = 4 + 0.25 * dsin(current_time * 0.4);
    if ((current_time div 400) mod 2 == 0) draw_set_colour(c_white); else draw_set_colour(make_colour_rgb(255, 80, 160));
    draw_text_transformed(room_width / 2, room_height / 2, "SHIFT\nTO\nSTRUGGLE", pulse, pulse, 0);
    draw_set_colour(c_white);
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}
