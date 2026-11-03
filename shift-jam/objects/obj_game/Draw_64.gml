/// Interfaccia provvisoria: vita, forma attuale, comandi.
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_text(8, 8, "HP: " + string(global.hp));
if (instance_exists(obj_player)) {
    draw_text(8, 24, "Forma: " + ((obj_player.form == 0) ? "NAVICELLA" : "MECHA"));
}
draw_text(8, room_height - 20, "WASD/frecce  Z attacco  SHIFT forma");

if (game_over) {
    draw_set_halign(fa_center);
    draw_text(room_width / 2, room_height / 2, "GAME OVER\nSHIFT per ricominciare");
    draw_set_halign(fa_left);
}
