/// CUORE CON LO YIN-YANG: lo lascia la Lancia bianca e nera quando la abbatti. Prenderlo ridà 1 vita (massimo 3).
/// Scende piano dondolando, lo yin-yang gira. Bordo azzurro: il colore delle cose del giocatore (da prendere, non da schivare).
/// Disegnato pixel per pixel dal codice: nessuno sprite.
x0 = x;          // centro del dondolio
t = 0;
rot = 0;         // rotazione dello yin-yang (gradi)

/// disegna il cuore pixel per pixel, unendo i pixel dello stesso colore in righe (meno chiamate di disegno).
/// half = mezza larghezza in pixel; mode 0 = tutto del colore col, mode 1 = yin-yang
draw_heart_px = function(cx, cy, half, mode, col) {
    var S = 1.25;                 // il cuore "matematico" va da -1.14 a 1.14 in x
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
                        // yin-yang ruotato: meta' bianca e meta' nera, due "gocce" e i due punti
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
                    draw_rectangle(cx + run_s, cy + j, cx + i - 1, cy + j, false);
                }
                run_c = c; run_s = i;
            }
        }
    }
}
