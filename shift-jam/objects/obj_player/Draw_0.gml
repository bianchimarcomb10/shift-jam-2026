/// Forme provvisorie: triangolo = navicella, quadrato = mecha.
if (invuln > 0 && (invuln div 4) mod 2 == 0) exit;   // lampeggia dopo un colpo

if (transform_timer > 0) {
    // durante la trasformazione: un cerchio bianco che si allarga
    draw_set_colour(c_white);
    draw_circle(x, y, 8 + (15 - transform_timer), true);
    exit;
}

draw_set_colour(c_aqua);
if (form == 0) {
    draw_triangle(x, y - 12, x - 9, y + 9, x + 9, y + 9, false);
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
