// sbarre vuote in due file (le rastrelliere cariche le disegnano le torrette, sopra)
for (var r = 0; r < array_length(rows); r++) {
    for (var c = 0; c < array_length(cols); c++) {
        draw_sprite_ext(spr_torpedo_bar, 0, x + cols[c], y + rows[r], 1, 1, 180, c_white, 1);
    }
}
// lo scafo al centro, sopra le sbarre
draw_sprite_ext(spr_bigship_hull, 0, x, y, 1, 1, 180, c_white, 1);
if (hull_flash > 0) {   // colpita: lo scafo lampeggia di bianco
    gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(spr_bigship_hull, 0, x, y, 1, 1, 180, c_white, 0.6);
    gpu_set_fog(false, c_white, 0, 0);
}

// torrette sopravvissute e spente: restano lì, cariche ma mute
for (var k = 0; k < array_length(inert); k++) {
    var it = inert[k];
    var l = (it[2] == 0) ? 9 : 38;
    global.draw_parts(spr_torpedo_racks, [[l, 25, 17, 15, 32, 32, 0, 0, 0]], x + it[0], y + it[1], 180, 1);
}

// fumo dalle torrette distrutte: sbuffi grigi che salgono e svaniscono
for (var w = 0; w < array_length(wrecks); w++) {
    var wr = wrecks[w];
    for (var p = 0; p < 4; p++) {
        var ph = (current_time * 0.06 + p * 25 + w * 13) mod 100;   // da 0 a 100: vita dello sbuffo
        draw_set_alpha((1 - ph / 100) * 0.45);
        draw_set_colour(make_colour_rgb(90, 85, 100));
        draw_circle(x + wr[0] + 3 * dsin(ph * 4 + w * 50), y + wr[1] - ph * 0.25, 2 + ph * 0.05, false);
    }
}
draw_set_alpha(1);
