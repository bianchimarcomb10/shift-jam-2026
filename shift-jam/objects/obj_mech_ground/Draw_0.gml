var ox = 0;
var oy = 0;
if (obj_ground.state == 1 || obj_ground.mass) {   // sommerso: il mecha trema
    ox = irandom_range(-2, 2);
    oy = irandom_range(-2, 2);
}

if (!transformed) {
    draw_set_colour(c_aqua);
    draw_rectangle(x - 10 + ox, y - 10 + oy, x + 10 + ox, y + 10 + oy, false);
    if (sweep_anim > 0) {
        draw_set_colour(c_white);
        draw_set_alpha(sweep_anim / 10);
        draw_circle(x, y, sweep_radius, true);
        var a = (10 - sweep_anim) * 36;
        draw_line_width(x, y, x + lengthdir_x(sweep_radius, a), y + lengthdir_y(sweep_radius, a), 3);
        draw_set_alpha(1);
    }
} else {
    draw_sprite(spr_player_flame, (current_time div 80) mod 4, x, y);
    draw_sprite(spr_player_engine, 0, x, y);
    draw_sprite(spr_player_ship, 0, x, y);
}
