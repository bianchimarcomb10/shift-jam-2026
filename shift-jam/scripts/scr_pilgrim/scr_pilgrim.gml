/// IL PELLEGRINO: navicella e mecha sono gli stessi pezzi, rimontati.
/// Il mecha ha due pose: GUARDIA a terra (gambe, falce in diagonale a due mani) e SOSPESO nello spazio
/// (niente gambe, mantello a strisce, fiamma del volo, falce dritta con la lama a luna sopra il cappello).
///   cappello di paglia  -> muso della navicella
///   mantello            -> ali
///   gambe               -> motori
///   lama della falce    -> mezzaluna azzurra dietro i motori
/// Tutto disegnato dal codice (poligoni, linee): nessuno sprite.
/// Le coordinate dei pezzi sono "locali": (0, 0) e' il centro, y in giu', 1 = 1 pixel a scala 1.

// trasformazione del disegno in corso: centro, scala, schiacciamento in virata, rotazione
global.pil = { x: 0, y: 0, k: 1, sq: 1, rc: 1, rs: 0 };

/// punto locale -> schermo (x e y separati)
function pil_x(lx, ly) {
    var p = global.pil;
    lx *= p.sq * p.k; ly *= p.k;
    return p.x + lx * p.rc + ly * p.rs;
}
function pil_y(lx, ly) {
    var p = global.pil;
    lx *= p.sq * p.k; ly *= p.k;
    return p.y - lx * p.rs + ly * p.rc;
}

/// poligono pieno; pts = [x0, y0, x1, y1, ...] in coordinate locali; line = colore del contorno, -1 = niente
function pil_poly(pts, col, line) {
    var n = array_length(pts) div 2;
    var sx = array_create(n), sy = array_create(n);
    for (var i = 0; i < n; i++) {
        sx[i] = pil_x(pts[i * 2], pts[i * 2 + 1]);
        sy[i] = pil_y(pts[i * 2], pts[i * 2 + 1]);
    }
    draw_set_colour(col);
    draw_primitive_begin(pr_trianglefan);
    for (var i = 0; i < n; i++) draw_vertex(sx[i], sy[i]);
    draw_primitive_end();
    if (line != -1) {
        draw_set_colour(line);
        for (var i = 0; i < n; i++) {
            var j = (i + 1) mod n;
            draw_line(sx[i], sy[i], sx[j], sy[j]);
        }
    }
}

/// linea tra due punti locali
function pil_line(x1, y1, x2, y2, col, w) {
    draw_set_colour(col);
    if (w <= 1) draw_line(pil_x(x1, y1), pil_y(x1, y1), pil_x(x2, y2), pil_y(x2, y2));
    else draw_line_width(pil_x(x1, y1), pil_y(x1, y1), pil_x(x2, y2), pil_y(x2, y2), w);
}

/// mescola due forme con lo stesso numero di vertici (0 = a, 1 = b)
function pil_mix(a, b, m) {
    var n = array_length(a);
    var r = array_create(n);
    for (var i = 0; i < n; i++) r[i] = lerp(a[i], b[i], m);
    return r;
}

/// lama della falce: mezzaluna da un arco di ellisse (coordinate locali). a0 -> a1 in gradi, 90 = su
function pil_blade(bcx, bcy, rx, ry, a0, a1) {
    var cyan   = make_colour_rgb(70, 190, 255);
    var cyan_l = make_colour_rgb(215, 250, 255);
    var cyan_g = make_colour_rgb(40, 140, 255);
    var ox = [], oy = [], ix = [], iy = [];
    for (var i = 0; i <= 14; i++) {
        var u = i / 14;
        var a = lerp(a0, a1, u);
        var qx = bcx + rx * dcos(a), qy = bcy - ry * dsin(a);
        var th = 1 - 0.55 * sin(pi * u);     // zero alle punte, massimo a meta'
        var wx = bcx + (qx - bcx) * th, wy = bcy + (qy - bcy) * th;
        array_push(ox, pil_x(qx, qy)); array_push(oy, pil_y(qx, qy));
        array_push(ix, pil_x(wx, wy)); array_push(iy, pil_y(wx, wy));
    }
    var nb = array_length(ox);
    gpu_set_blendmode(bm_add);                 // alone che pulsa
    draw_set_alpha(0.4 + 0.15 * dsin(current_time * 0.3));
    draw_set_colour(cyan_g);
    for (var i = 0; i < nb - 1; i++) draw_line_width(ox[i], oy[i], ox[i + 1], oy[i + 1], 4);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(cyan);
    draw_primitive_begin(pr_trianglestrip);
    for (var i = 0; i < nb; i++) { draw_vertex(ox[i], oy[i]); draw_vertex(ix[i], iy[i]); }
    draw_primitive_end();
    draw_set_colour(cyan_l);
    for (var i = 0; i < nb - 1; i++) {
        draw_line(ox[i], oy[i], ox[i + 1], oy[i + 1]);
        draw_line(ix[i], iy[i], ix[i + 1], iy[i + 1]);
    }
}

/// braccio nella manica: spalla -> gomito -> mano, con il pugno d'acciaio (coordinate locali)
function pil_arm(sx, sy, ex, ey, hx, hy) {
    var ink = make_colour_rgb(14, 10, 20), sleeve = make_colour_rgb(30, 32, 76);
    pil_line(sx, sy, ex, ey, ink, 5);
    pil_line(ex, ey, hx, hy, ink, 5);
    pil_line(sx, sy, ex, ey, sleeve, 3);
    pil_line(ex, ey, hx, hy, sleeve, 3);
    pil_fist(hx, hy);
}
function pil_fist(hx, hy) {
    var fx = pil_x(hx, hy), fy = pil_y(hx, hy);
    draw_set_colour(make_colour_rgb(14, 10, 20));
    draw_rectangle(fx - 2, fy - 2, fx + 1, fy + 1, false);
    draw_set_colour(make_colour_rgb(170, 186, 206));
    draw_rectangle(fx - 1, fy - 1, fx, fy, false);
}

/// asta della falce tra due punti locali
function pil_shaft(x1, y1, x2, y2) {
    pil_line(x1, y1, x2, y2, make_colour_rgb(14, 10, 20), 3);
    pil_line(x1, y1, x2, y2, make_colour_rgb(150, 170, 200), 1);
}

/// FALCIATA A DUE MANI: il monaco gira con la falce tesa, la lama lascia una scia azzurra.
/// arms = false: solo la falce (le braccia le copre il cappello quando la lama passa dietro)
function pil_sweep(px, py, R, sweep, k, arms) {
    var ink = make_colour_rgb(14, 10, 20);
    var cyan = make_colour_rgb(70, 190, 255), cyan_l = make_colour_rgb(215, 250, 255);
    var ah = 90 - (10 - sweep) / 10 * 360;     // gira in senso orario partendo dall'alto
    // le mani: davanti al petto, sull'asta, verso la lama
    var cx0 = px, cy0 = py - 6 * k;
    var h1x = cx0 + lengthdir_x(9, ah), h1y = cy0 + lengthdir_y(9, ah);
    var h2x = cx0 + lengthdir_x(15, ah), h2y = cy0 + lengthdir_y(15, ah);
    var hx = px + lengthdir_x(R, ah), hy = py + lengthdir_y(R, ah);
    var bx = cx0 + lengthdir_x(3, ah), by = cy0 + lengthdir_y(3, ah);
    draw_set_colour(ink);
    draw_line_width(bx, by, hx, hy, 3);
    draw_set_colour(make_colour_rgb(150, 170, 200));
    draw_line(bx, by, hx, hy);
    // lama in punta, piegata nel verso del giro
    var lxp = hx, lyp = hy;
    for (var i = 1; i <= 7; i++) {
        var u = i / 7;
        var rr = R - 2 + 10 * sin(pi * u * 0.5);
        var aa = ah - u * 26;
        var nx = px + lengthdir_x(rr, aa), ny = py + lengthdir_y(rr, aa);
        draw_set_colour(cyan_l); draw_line_width(lxp, lyp, nx, ny, 3);
        draw_set_colour(cyan);   draw_line(lxp, lyp, nx, ny);
        lxp = nx; lyp = ny;
    }
    if (arms) {
        for (var s = -1; s <= 1; s += 2) {
            var shx = px + s * 6 * k, shy = py - 11 * k;
            var tx = (s < 0) ? h1x : h2x, ty = (s < 0) ? h1y : h2y;
            draw_set_colour(ink); draw_line_width(shx, shy, tx, ty, 5);
            draw_set_colour(make_colour_rgb(30, 32, 76)); draw_line_width(shx, shy, tx, ty, 3);
        }
        for (var s = 0; s < 2; s++) {
            var fx = (s == 0) ? h1x : h2x, fy = (s == 0) ? h1y : h2y;
            draw_set_colour(ink); draw_rectangle(fx - 2, fy - 2, fx + 1, fy + 1, false);
            draw_set_colour(make_colour_rgb(170, 186, 206)); draw_rectangle(fx - 1, fy - 1, fx, fy, false);
        }
    }
}

/// Disegna il pellegrino.
/// m: 0 navicella, 1 mecha (in mezzo: la trasformazione)
/// tilt: inclinazione in virata (gradi) | sweep: frame rimasti della falciata (10..0) | sweep_r: raggio della falciata
/// flash: 0..1 l'ensō azzurro del cambio | ms: quanto e' piu' grosso il mecha | scythe: false = in mano c'e' la trivella
/// flame: lunghezza della fiamma (1 = normale) | sc: scala di tutto (il finale lo rimpicciolisce)
/// pose: come sta il mecha. 0 = GUARDIA (a terra: gambe che camminano, falce in diagonale a due mani)
///       1 = SOSPESO (nello spazio: niente gambe, mantello a strisce, fiamma del volo, falce dritta con la lama a luna)
/// walk: 0..1 quanto sta camminando (solo GUARDIA)
function draw_pilgrim(px, py, m, tilt = 0, sweep = 0, sweep_r = 56, flash = 0, ms = 1.2, scythe = true, flame = 1, sc = 1, pose = 1, walk = 0) {
    var P = global.pil;
    var hover = (pose == 1) ? 1.5 * dsin(current_time * 0.15) * m : 0;   // il SOSPESO galleggia
    P.x = px; P.y = py + hover;
    P.sq = 1 - abs(tilt) / 60;              // inclinato: si stringe come se girasse su se stesso
    P.rc = dcos(-tilt); P.rs = dsin(-tilt);
    P.k = lerp(1, ms, m) * sc;

    var ink    = make_colour_rgb(14, 10, 20);
    var hat    = make_colour_rgb(214, 226, 222);
    var hat_s  = make_colour_rgb(176, 190, 196);
    var hat_d  = make_colour_rgb(150, 166, 176);
    var hat_l  = make_colour_rgb(250, 255, 255);
    var steel_d = make_colour_rgb(70, 80, 104);
    var cloak  = make_colour_rgb(46, 52, 112);
    var cloak_l = make_colour_rgb(78, 92, 168);
    var leg    = make_colour_rgb(52, 58, 80);
    var cyan   = make_colour_rgb(70, 190, 255);
    var cyan_l = make_colour_rgb(215, 250, 255);

    var bob  = dsin(current_time * 0.25);    // respiro
    var wave = dsin(current_time * 0.2);     // il mantello ondeggia
    var flare = (sweep > 0) ? sweep * 0.5 : 0;   // e si apre nella falciata
    var mech = (m >= 0.5);                   // da meta' trasformazione in poi si disegnano le pose del mecha
    var still = (sweep <= 0);                // falce in mano (non sta girando)

    // dove sta la falce, nelle due pose (coordinate locali)
    // GUARDIA: asta in diagonale davanti al petto, dal basso a sinistra all'alto a destra; dondola col respiro
    var g_ang = 36 + 3 * dsin(current_time * 0.2) - tilt * 0.6;
    var g_cx = 0, g_cy = -4 + bob * 0.5;
    // SOSPESO: asta dritta a destra, la lama sopra il cappello come una luna
    var s_lean = 2 * dsin(current_time * 0.15 + 34);
    var s_x = 6 + s_lean * 0.3;

    // --- fiamme: dei motori (navicella) o del volo sotto il mantello (SOSPESO) ---
    if (!mech) {
        var fa = (1 - m * 2) * flame;
        for (var s = -1; s <= 1; s += 2) {
            var fl = (5 + 2 * dsin(current_time * 0.9 + s * 60) + ((current_time div 50) mod 2) * 2) * fa;
            pil_poly([s * 3 - 1.5, 14, s * 3 + 1.5, 14, s * 3, 14 + fl], cyan, -1);
            pil_poly([s * 3 - 0.6, 14, s * 3 + 0.6, 14, s * 3, 14 + fl * 0.6], cyan_l, -1);
        }
    } else if (pose == 1) {
        // due getti come quelli della navicella, piu' lunghi, con un alone: escono da sotto il mantello
        var fa = (m * 2 - 1) * flame;
        for (var s = -1; s <= 1; s += 2) {
            var fl = (10 + 2 * dsin(current_time * 0.9 + s * 60) + ((current_time div 50) mod 2) * 2) * fa;
            gpu_set_blendmode(bm_add);
            draw_set_alpha(0.45);
            pil_poly([s * 3 - 3.5, 13, s * 3 + 3.5, 13, s * 3, 15 + fl * 1.15], make_colour_rgb(40, 140, 255), -1);
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1);
            pil_poly([s * 3 - 2, 14, s * 3 + 2, 14, s * 3, 15 + fl], cyan, -1);
            pil_poly([s * 3 - 0.8, 14, s * 3 + 0.8, 14, s * 3, 15 + fl * 0.6], cyan_l, -1);
        }
    }

    // --- asta della falce dietro al corpo (navicella: nascosta sotto la fusoliera; SOSPESO: dietro il mantello) ---
    if (still && !mech) {
        pil_shaft(0, 10, 0, -2);
    } else if (still && scythe && pose == 1) {
        pil_shaft(s_x + 1, 16, s_x - 1, -30);
    }

    // --- gambe / motori ---
    if (!mech) {
        var lx = lerp(3, 3.5, m), ly0 = lerp(8, 3, m), ly1 = lerp(14, 21, m);
        for (var s = -1; s <= 1; s += 2) {
            var c = s * lx;
            pil_poly([c - 2.5, ly0, c + 2.5, ly0, c + 2.5, ly1 + 1, c - 2.5, ly1 + 1], ink, -1);
            pil_poly([c - 1.5, ly0, c + 1.5, ly0, c + 1.5, ly1, c - 1.5, ly1], leg, -1);
            pil_poly([c - 1.5, ly1 - 1, c + 1.5, ly1 - 1, c + 1.5, ly1, c - 1.5, ly1], cyan, -1);   // ugello
        }
    } else if (pose == 0) {
        // GUARDIA: due gambe con il ginocchio; camminando una si alza mentre l'altra spinge
        var amp = 3 * clamp(walk, 0, 1);
        for (var s = -1; s <= 1; s += 2) {
            var stp = dsin(current_time * 0.6 + ((s < 0) ? 0 : 180));
            var lift = max(0, stp) * amp;
            var kx = s * 4 + stp * amp * 0.2, ky = 11.5 - lift * 0.5;
            var fx = s * 4.5 + stp * amp * 0.4, fy = 20 - lift;
            pil_line(s * 3, 3, kx, ky, ink, 5); pil_line(kx, ky, fx, fy, ink, 5);
            pil_line(s * 3, 3, kx, ky, leg, 3); pil_line(kx, ky, fx, fy, leg, 3);
            pil_poly([fx - 2.5 + s * 0.5, fy, fx + 2.5 + s * 0.5, fy, fx + 2.5 + s * 0.5, fy + 1.5, fx - 2.5 + s * 0.5, fy + 1.5], steel_d, -1);   // piede
        }
    }

    // --- busto / fusoliera: chiara nella navicella, scura sotto il mantello ---
    var B = pil_mix([-4.5, -6, 4.5, -6, 3.5, 11, -3.5, 11], [-5, -13, 5, -13, 4, 5, -4, 5], m);
    for (var i = 1; i < 8; i += 2) B[i] += bob * 0.5 * m;
    pil_poly(B, merge_colour(make_colour_rgb(196, 210, 214), steel_d, m), ink);
    pil_line(0, B[1] + 1, 0, B[5] - 1, steel_d, 1);

    // --- mantello / ali ---
    for (var s = -1; s <= 1; s += 2) {
        var W = pil_mix([3, -3, 10, 3, 18, 10, 16, 13, 3, 9], [0.5, -12, 9, -11, 13, 4, 15, 18, 3, 16], m);
        W[6] += (wave * 1.5 + flare * 1.2 - tilt * 0.15 * s) * m;   // l'orlo ondeggia, resta indietro in virata e si apre nella falciata
        W[7] += (-flare * 0.6 + bob * 0.5) * m;
        W[4] += (wave * 0.8 + flare * 0.8) * m;
        W[8] += wave * 0.6 * m;
        W[9] += bob * 0.5 * m;
        if (s < 0) for (var j = 0; j < 10; j += 2) W[j] = -W[j];   // a specchio
        // SOSPESO: l'orlo si sfilaccia in due strisce che ondeggiano (disegnate sotto il mantello)
        if (mech && pose == 1) {
            for (var q = 0; q < 2; q++) {
                var u = 0.3 + q * 0.45;
                var ex = lerp(W[8], W[6], u), ey = lerp(W[9], W[7], u);
                var du = 0.17;
                var e0x = lerp(W[8], W[6], u - du), e0y = lerp(W[9], W[7], u - du);
                var e1x = lerp(W[8], W[6], u + du), e1y = lerp(W[9], W[7], u + du);
                var tlen = (6 + 3 * dsin(current_time * 0.25 + q * 90 + s * 40)) * (m * 2 - 1);
                var tx = ex + 1.5 * dsin(current_time * 0.2 + q * 120 + s * 70) - tilt * 0.2;
                pil_poly([e0x, e0y - 1, e1x, e1y - 1, tx, ey + tlen], cloak, ink);
            }
        }
        pil_poly(W, merge_colour(cloak_l, cloak, m), ink);
        // piega piu' chiara dalla spalla verso l'orlo
        pil_poly([W[0], W[1], W[2], W[3], (W[2] + W[4]) / 2, (W[3] + W[5]) / 2, (W[0] + W[8]) / 2, (W[1] + W[9]) / 2],
            merge_colour(make_colour_rgb(110, 128, 200), cloak_l, m), -1);
        // fodera azzurra sull'orlo / bordo d'uscita dell'ala
        pil_line(W[4], W[5], W[6], W[7], cyan, 1);
        pil_line(W[6], W[7], W[8], W[9], cyan, 1);
        // bordo d'attacco chiaro: fa brillare l'ala; nel mecha e' la piega sulla spalla
        var edge = merge_colour(make_colour_rgb(200, 214, 250), cloak_l, m);
        pil_line(W[0], W[1], W[2], W[3], edge, 1);
        pil_line(W[2], W[3], W[4], W[5], edge, 1);
    }

    // --- braccia e falce davanti al mantello (solo mecha, falce ferma) ---
    if (mech && still) {
        if (!scythe) {
            // con la trivella: tutte e due le mani sull'impugnatura, a destra
            pil_arm(-6, -11, -2, -4, 7, -1);
            pil_arm(6, -11, 9, -7, 9, -3);
        } else if (pose == 0) {
            var dx = dcos(g_ang), dy = -dsin(g_ang);
            pil_shaft(g_cx - 14 * dx, g_cy - 14 * dy, g_cx + 27 * dx, g_cy + 27 * dy);
            pil_arm(-6, -11, -7, -5, g_cx - 3 * dx, g_cy - 3 * dy);
            pil_arm(6, -11, 6, -7, g_cx + 6 * dx, g_cy + 6 * dy);
        } else {
            pil_arm(-6, -11, -3, -4, s_x + 0.6, -3);   // il braccio sinistro attraversa il petto
            pil_arm(6, -11, 9, -8, s_x + 0.2, -9);
        }
    }

    // --- FALCIATA che passa DIETRO la testa: prima del cappello ---
    var R = sweep_r * sc;
    var sw_ah = 90 - (10 - sweep) / 10 * 360;
    var sw_back = (sweep > 0 && scythe && dsin(sw_ah) > 0.2);
    if (sw_back) pil_sweep(px, py, R, sweep, P.k, true);

    // --- cappello / muso ---
    var H = pil_mix([0, -18, 3, -13, 4, -6, 0, -4, -4, -6, -3, -13], [0, -25, 8, -20, 15, -14, 0, -12, -15, -14, -8, -20], m);
    for (var i = 1; i < 12; i += 2) H[i] += bob * m;
    if (m > 0.3) {
        // viso in ombra sotto la tesa
        var fy = H[7] + 2;
        var face = [];
        for (var a = 0; a < 360; a += 45) { array_push(face, 6 * dcos(a)); array_push(face, fy - 3 * dsin(a)); }
        pil_poly(face, ink, -1);
    }
    pil_poly(H, hat, ink);
    // nel mecha la meta' destra del cappello e' in ombra: sembra un cono, non un triangolo
    if (mech) pil_poly([H[0], H[1] + 0.5, H[6], H[7] - 0.5, H[4] - 0.6, H[5] - 0.4], hat_s, -1);
    // intreccio della paglia (nel muso: le linee dei pannelli); nella falciata le righe girano
    var vv = [1, 2, 4, 5];
    for (var i = 0; i < 4; i++) {
        var qx = H[vv[i] * 2], qy = H[vv[i] * 2 + 1];
        if (sweep > 0 && mech) qx = lerp(H[8], H[4], frac((i + 0.5) / 4 + (10 - sweep) / 10));
        pil_line(H[0], H[1], H[0] * 0.25 + qx * 0.75, H[1] * 0.25 + qy * 0.75, hat_d, 1);
    }
    pil_line(H[0], H[1], H[0] - (1 - m) - 3 * m, H[1] + 3 + 2 * m, hat_l, 1);
    // tesa
    pil_line(H[8], H[9], H[6], H[7], hat_d, 1);
    pil_line(H[6], H[7], H[4], H[5], hat_d, 1);
    // occhio (mecha) / abitacolo (navicella): sempre azzurro
    var ey = lerp(-12, H[7] + 2, m), ew = lerp(1, 3.5, m), eh = lerp(2.5, 0.6, m);
    pil_poly([-ew, ey - eh, ew, ey - eh, ew, ey + eh, -ew, ey + eh], cyan, -1);
    draw_set_colour(cyan_l);
    draw_point(pil_x(-ew * 0.4, ey - eh * 0.5), pil_y(-ew * 0.4, ey - eh * 0.5));

    // --- lama della falce (ferma) ---
    if (still && !mech) {
        pil_blade(0, 11, 11, 6, 215, 325);                 // navicella: mezzaluna dietro i motori
    } else if (still && scythe && pose == 0) {
        var dx = dcos(g_ang), dy = -dsin(g_ang);
        var hx = g_cx + 27 * dx, hy = g_cy + 27 * dy;
        pil_blade(hx, hy + 8, 12, 8, 90, -40);              // GUARDIA: in cima all'asta, piegata verso fuori
    } else if (still && scythe && pose == 1) {
        pil_blade(s_x, -36 + s_lean * 0.3, 6, 7, 70, 290);  // SOSPESO: una luna sopra il cappello
    }

    // --- FALCIATA che passa davanti: dopo il cappello ---
    if (sweep > 0 && scythe && !sw_back) pil_sweep(px, py, R, sweep, P.k, true);
    // la scia della falciata, sempre
    if (sweep > 0 && scythe) {
        var ah = sw_ah;
        var fade = sqrt(sweep / 10);
        gpu_set_blendmode(bm_add);
        draw_set_colour(make_colour_rgb(40, 140, 255));
        for (var i = 0; i < 24; i++) {
            var u0 = i / 24, u1 = (i + 1) / 24;
            var b0 = ah + u0 * 150, b1 = ah + u1 * 150;
            draw_set_alpha(0.67 * (1 - u0) * fade);
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex(px + lengthdir_x(R, b0), py + lengthdir_y(R, b0));
            draw_vertex(px + lengthdir_x(R - 12 * (1 - u0), b0), py + lengthdir_y(R - 12 * (1 - u0), b0));
            draw_vertex(px + lengthdir_x(R, b1), py + lengthdir_y(R, b1));
            draw_vertex(px + lengthdir_x(R - 12 * (1 - u1), b1), py + lengthdir_y(R - 12 * (1 - u1), b1));
            draw_primitive_end();
        }
        gpu_set_blendmode(bm_normal);
        draw_set_colour(cyan_l);
        draw_set_alpha(0.47 * sweep / 10);
        draw_circle(px, py, R, true);
        draw_set_alpha(1);
    }

    // --- il cambio: un ensō azzurro che si apre e svanisce ---
    if (flash > 0) {
        var r = (12 + 20 * (1 - flash)) * sc;
        var st = 120 + 200 * (1 - flash);
        draw_set_colour(cyan_l);
        for (var i = 0; i < 30; i++) {
            var u0 = i / 30;
            var b0 = st + u0 * 320, b1 = st + (u0 + 1 / 30) * 320;
            draw_set_alpha(0.9 * flash * (1 - 0.6 * u0));
            draw_line_width(px + lengthdir_x(r, b0), py + lengthdir_y(r, b0), px + lengthdir_x(r, b1), py + lengthdir_y(r, b1),
                max(1, (1 - u0) * 5 * flash + 1));
        }
        draw_set_alpha(1);
    }
    draw_set_colour(c_white);
}
