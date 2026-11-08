/// PROIETTILE-REGALO del boss: un globo BIANCO E NERO (il colore dei nemici che portano un regalo,
/// come la Lancia del cuore e la Portatrice). Scende lento: se lo tocchi ti fa male, se lo spacchi
/// (3 colpi, o una falciata) lascia cadere il suo regalo.
/// Due forme, per capire subito cosa porta:
///   ROTONDO con dentro il cuore yin-yang  -> CUORE (+1 vita)
///   a ROMBO con dentro la lettera R, L o S -> ARMA SPECIALE (razzi, laser, ventaglio)
/// E' figlio di obj_enemy: colpi, razzi, laser e falciata lo colpiscono come un nemico.
hp = 3;
radius = 11;
gift = 0;          // 0 cuore, 1 razzi, 2 laser, 3 ventaglio (lo decide obj_boss)
dir = 270;
spd = 1.1;
t = 0;
rot = 0;           // il guscio gira
flash = 0;         // lampo bianco quando viene colpito
last_hp = hp;

// RITIRATA (richiesta da obj_enemy; il regalo non si ritira mai)
retreat = false;
rspd = 0;
rdir = 90;

/// il cuore yin-yang in piccolo, pixel per pixel (come obj_heart): half = mezza larghezza in pixel
draw_heart_px = function(cx, cy, half, mode, col) {
    var S = 1.25;
    var ca = dcos(rot), sa = dsin(rot);
    var R = 1.1, r2 = R / 2, dot = R * 0.14;
    var white = make_colour_rgb(240, 244, 250), black = make_colour_rgb(16, 14, 24);
    var n = ceil(half) + 1;
    for (var j = -n; j <= n; j++) {
        var run_c = -1, run_s = 0;
        for (var i = -n; i <= n + 1; i++) {
            var c = -1;
            if (i <= n) {
                var hx = (i + 0.5) / half * S, hy = -(j + 0.5) / half * S + 0.12;
                var q = hx * hx + hy * hy - 1;
                if (q * q * q - hx * hx * hy * hy * hy <= 0) {
                    if (mode == 0) c = col;
                    else {
                        var py = hy - 0.15;
                        var ux = hx * ca + py * sa, uy = -hx * sa + py * ca;
                        if (point_distance(ux, uy, 0, r2) < r2) c = black;
                        else if (point_distance(ux, uy, 0, -r2) < r2) c = white;
                        else c = (ux < 0) ? white : black;
                        if (point_distance(ux, uy, 0, r2) < dot) c = white;
                        if (point_distance(ux, uy, 0, -r2) < dot) c = black;
                    }
                }
            }
            if (c != run_c) {
                if (run_c != -1) {
                    draw_set_colour(run_c);
                    draw_primitive_begin(pr_trianglestrip);
                    draw_vertex(cx + run_s, cy + j);
                    draw_vertex(cx + i, cy + j);
                    draw_vertex(cx + run_s, cy + j + 1);
                    draw_vertex(cx + i, cy + j + 1);
                    draw_primitive_end();
                }
                run_c = c; run_s = i;
            }
        }
    }
}
