// colpo della navicella: 4 fotogrammi animati
// i colpi rimandati dalla parata restano uguali ai proiettili nemici (solo nell'aspetto):
// sono i loro stessi colpi che tornano indietro
if (variable_instance_exists(id, "vx")) {
    // stessa sfera dei colpi nemici, con la scia rivolta all'indietro rispetto a dove ora vola
    global.draw_ebullet(x, y, point_direction(0, 0, vx, -9), 3, current_time * 0.6 + id * 47);
} else {
    draw_sprite(spr_player_shot, (current_time div 60) mod 4, x, y);
}
