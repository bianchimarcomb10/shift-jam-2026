if (bead) {
    // grano della mala: perlina d'oro con alone; respinto diventa bianco
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.35);
    draw_set_colour(make_colour_rgb(255, 210, 90));
    draw_circle(x, y, radius + 3, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(120, 90, 30));
    draw_circle(x, y, radius, false);
    draw_set_colour(reflected ? c_white : make_colour_rgb(240, 200, 90));
    draw_circle(x, y, radius - 1, false);
    draw_set_colour(make_colour_rgb(255, 245, 210));
    draw_circle(x - 2, y - 2, 1.5, false);
    draw_set_colour(c_white);
    exit;
}
draw_set_colour(reflected ? c_white : make_colour_rgb(220, 180, 80));
draw_circle(x, y, radius, false);
draw_set_colour(reflected ? make_colour_rgb(220, 180, 80) : make_colour_rgb(120, 90, 30));
draw_circle(x, y, radius, true);
draw_circle(x, y, radius / 2, true);
