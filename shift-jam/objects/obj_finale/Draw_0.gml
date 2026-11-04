// esplosione: anelli bianchi che si allargano e svaniscono
if (t < 100) {
    draw_set_colour(c_white);
    for (var i = 0; i < 4; i++) {
        var rr = (t - i * 10) * 3;
        if (rr > 0) {
            draw_set_alpha(max(0, 1 - rr / 240));
            draw_circle(boss_x, boss_y, rr, true);
        }
    }
    draw_set_alpha(1);
}

// la navicella rimpicciolisce finche' resta un punto di luce
if (scale > 0.1) {
    draw_sprite_ext(spr_player_flame, (current_time div 80) mod 4, ship_x, ship_y, scale, scale, 0, c_white, 1);
    draw_sprite_ext(spr_player_engine, 0, ship_x, ship_y, scale, scale, 0, c_white, 1);
    draw_sprite_ext(spr_player_ship, 0, ship_x, ship_y, scale, scale, 0, c_white, 1);
} else {
    draw_set_colour(c_white);
    draw_point(ship_x, ship_y);
}
