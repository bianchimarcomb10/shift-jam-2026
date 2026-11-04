/// Forme provvisorie: triangolo = navicella, quadrato = mecha.
// scintille delle parate: una crocetta bianca che si allarga e svanisce
draw_set_colour(c_white);
for (var k = 0; k < array_length(sparks); k++) {
    var sp = sparks[k];
    var sr = 2 + (12 - sp[2]) * 0.6;
    draw_set_alpha(sp[2] / 12);
    draw_line(sp[0] - sr, sp[1], sp[0] + sr, sp[1]);
    draw_line(sp[0], sp[1] - sr, sp[0], sp[1] + sr);
}
draw_set_alpha(1);

if (invuln > 0 && (invuln div 4) mod 2 == 0) exit;   // lampeggia dopo un colpo

if (transform_timer > 0) {
    // durante la trasformazione: un cerchio bianco che si allarga
    draw_set_colour(c_white);
    draw_circle(x, y, 8 + (15 - transform_timer), true);
    exit;
}

draw_set_colour(c_aqua);
if (form == 0) {
draw_sprite(spr_player_flame, (current_time div 80) mod 4, x, y);
draw_sprite(spr_player_engine, 0, x, y);
draw_sprite(spr_player_ship, 0, x, y);
} else {
    draw_rectangle(x - 10, y - 10, x + 10, y + 10, false);
    if (sweep_anim > 0) {
        // la falciata: un cerchio che svanisce e una lama che ruota
        draw_set_colour(c_white);
        draw_set_alpha(sweep_anim / 10);
        draw_circle(x, y, sweep_radius, true);
        var a = (10 - sweep_anim) * 36;
        draw_line_width(x, y, x + lengthdir_x(sweep_radius, a), y + lengthdir_y(sweep_radius, a), 3);
        draw_set_alpha(1);
    }
}
