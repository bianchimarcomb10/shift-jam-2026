// colpo della navicella: 4 fotogrammi animati
// i colpi rimandati dalla parata restano uguali ai proiettili nemici (solo nell'aspetto):
// sono i loro stessi colpi che tornano indietro
if (variable_instance_exists(id, "vx")) {
    draw_set_colour(c_fuchsia);
    draw_circle(x, y, 3, false);
    draw_set_colour(c_white);
    draw_circle(x, y, 1, false);
} else {
    draw_sprite(spr_player_shot, (current_time div 60) mod 4, x, y);
}
