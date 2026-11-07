// colpo parato: luce azzurra (il colore del motore della navicella), cosi' non si confonde coi colpi nemici
if (parried) global.draw_pshot(x, y, trail, life, current_time * 0.6 + id * 47);
else if (kind == 1) {
    // RAZZO: scia di fumo grigio-azzurro, poi il razzo girato dove vola
    for (var i = 0; i < array_length(trail); i++) {
        var tp = trail[i];
        var a = (i + 1) / array_length(trail);
        draw_set_alpha(0.45 * a);
        draw_set_colour(merge_colour(make_colour_rgb(70, 80, 110), make_colour_rgb(150, 210, 255), a));
        draw_circle(tp[0], tp[1], 1 + a * 1.5, false);
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_sprite_ext(spr_rocket, (current_time div 70) mod 3, x, y, 1, 1, hd - 90, c_white, 1);
}
else if (kind == 3) draw_sprite_ext(spr_orb, (current_time div 50 + id) mod 10, x, y, 0.7, 0.7, 0, c_white, 1);   // globo del ventaglio
else draw_sprite(spr_player_shot, (current_time div 60) mod 4, x, y);   // colpo della navicella: 4 fotogrammi animati
