/// IL PELLEGRINO: navicella e mecha sono gli stessi pezzi, rimontati.
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

/// Disegna il pellegrino.
/// m: 0 navicella, 1 mecha (in mezzo: la trasformazione)
/// tilt: inclinazione in virata (gradi) | sweep: frame rimasti della falciata (10..0) | sweep_r: raggio della falciata
/// flash: 0..1 l'ensō azzurro del cambio | ms: quanto e' piu' grosso il mecha | scythe: false = in mano c'e' la trivella
/// flame: lunghezza della fiamma (1 = normale) | sc: scala di tutto (il finale lo rimpicciolisce)
function draw_pilgrim(px, py, m, tilt = 0, sweep = 0, sweep_r = 56, flash = 0, ms = 1.2, scythe = true, flame = 1, sc = 1) {
    var P = global.pil;
    P.x = px; P.y = py;
    P.sq = 1 - abs(tilt) / 60;              // inclinato: si stringe come se girasse su se stesso
    P.rc = dcos(-tilt); P.rs = dsin(-tilt);
    P.k = lerp(1, ms, m) * sc;

    var ink    = make_colour_rgb(14, 10, 20);
    var hat    = make_colour_rgb(214, 226, 222);
    var hat_d  = make_colour_rgb(150, 166, 176);
    var hat_l  = make_colour_rgb(250, 255, 255);
    var steel_d = make_colour_rgb(70, 80, 104);
    var cloak  = make_colour_rgb(46, 52, 112);
    var cloak_l = make_colour_rgb(78, 92, 168);
    var leg    = make_colour_rgb(52, 58, 80);
    var cyan   = make_colour_rgb(70, 190, 255);
    var cyan_l = make_colour_rgb(215, 250, 255);
    var cyan_g = make_colour_rgb(40, 140, 255);

    var bob  = dsin(current_time * 0.25);    // respiro
    var wave = dsin(current_time * 0.2);     // il mantello ondeggia
    var flare = (sweep > 0) ? sweep * 0.5 : 0;   // e si apre nella falciata
    var show_blade = scythe || m < 0.5;      // con la trivella in mano la falce sparisce dal mecha

    // --- fiamme dei motori (solo navicella: svaniscono nel cambio) ---
    if (m < 0.5) {
        var fa = (1 - m * 2) * flame;
        for (var s = -1; s <= 1; s += 2) {
            var fl = (5 + 2 * dsin(current_time * 0.9 + s * 60) + ((current_time div 50) mod 2) * 2) * fa;
            pil_poly([s * 3 - 1.5, 14, s * 3 + 1.5, 14, s * 3, 14 + fl], cyan, -1);
            pil_poly([s * 3 - 0.6, 14, s * 3 + 0.6, 14, s * 3, 14 + fl * 0.6], cyan_l, -1);
        }
    }

    // --- asta della falce (dietro a tutto; nella navicella e' nascosta sotto la fusoliera) ---
    if (sweep <= 0 && show_blade) {
        var sb = bob * 0.5 * m;
        var ax = lerp(0, 15, m);
        pil_line(ax, lerp(10, 15, m) + sb, ax, lerp(-2, -22, m) + sb, ink, 3);
        pil_line(ax, lerp(10, 15, m) + sb, ax, lerp(-2, -22, m) + sb, make_colour_rgb(150, 170, 200), 1);
    }

    // --- gambe / motori ---
    var lx = lerp(3, 3.5, m), ly0 = lerp(8, 3, m), ly1 = lerp(14, 21, m);
    for (var s = -1; s <= 1; s += 2) {
        var c = s * lx;
        pil_poly([c - 2.5, ly0, c + 2.5, ly0, c + 2.5, ly1 + 1, c - 2.5, ly1 + 1], ink, -1);
        pil_poly([c - 1.5, ly0, c + 1.5, ly0, c + 1.5, ly1, c - 1.5, ly1], leg, -1);
        if (m < 0.5) pil_poly([c - 1.5, ly1 - 1, c + 1.5, ly1 - 1, c + 1.5, ly1, c - 1.5, ly1], cyan, -1);   // ugello
        else pil_poly([c - 2 + s * 0.5, ly1 - 1, c + 2 + s * 1.5, ly1 - 1, c + 2 + s * 1.5, ly1 + 1, c - 2 + s * 0.5, ly1 + 1], steel_d, -1);   // piede
    }

    // --- busto / fusoliera: chiara nella navicella, scura sotto il mantello ---
    var B = pil_mix([-4.5, -6, 4.5, -6, 3.5, 11, -3.5, 11], [-5, -13, 5, -13, 4, 5, -4, 5], m);
    for (var i = 1; i < 8; i += 2) B[i] += bob * 0.5 * m;
    pil_poly(B, merge_colour(make_colour_rgb(196, 210, 214), steel_d, m), ink);
    pil_line(0, B[1] + 1, 0, B[5] - 1, steel_d, 1);

    // --- mantello / ali ---
    for (var s = -1; s <= 1; s += 2) {
        var W = pil_mix([3, -3, 10, 3, 18, 10, 16, 13, 3, 9], [0.5, -12, 9, -11, 13, 4, 15, 18, 3, 16], m);
        W[6] += (wave * 1.5 + flare * 1.2) * m;   // l'orlo ondeggia e si apre nella falciata
        W[7] += (-flare * 0.6 + bob * 0.5) * m;
        W[4] += (wave * 0.8 + flare * 0.8) * m;
        W[8] += wave * 0.6 * m;
        W[9] += bob * 0.5 * m;
        if (s < 0) for (var j = 0; j < 10; j += 2) W[j] = -W[j];   // a specchio
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
    // intreccio della paglia (nel muso: le linee dei pannelli)
    var vv = [1, 2, 4, 5];
    for (var i = 0; i < 4; i++) {
        var qx = H[vv[i] * 2], qy = H[vv[i] * 2 + 1];
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

    // --- lama della falce: nel mecha in cima all'asta, nella navicella mezzaluna dietro i motori ---
    if (sweep <= 0 && show_blade) {
        var bcx = lerp(0, 15, m), bcy = lerp(11, -19, m) + bob * 0.5 * m;
        var rx = lerp(11, 12, m), ry = lerp(6, 7, m);
        var a0 = lerp(215, 90, m), a1 = lerp(325, -30, m);
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

    // --- FALCIATA: la falce intera gira attorno al mecha e lascia una scia azzurra ---
    if (sweep > 0 && scythe) {
        var R = sweep_r * sc;
        var ah = 90 - (10 - sweep) / 10 * 360;     // gira in senso orario partendo dall'alto
        var fade = sqrt(sweep / 10);
        gpu_set_blendmode(bm_add);
        draw_set_colour(cyan_g);
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
        // asta dal mecha alla lama
        var hx = px + lengthdir_x(R, ah), hy = py + lengthdir_y(R, ah);
        draw_set_colour(ink);
        draw_line_width(px + lengthdir_x(10, ah), py + lengthdir_y(10, ah), hx, hy, 3);
        draw_set_colour(make_colour_rgb(150, 170, 200));
        draw_line(px + lengthdir_x(10, ah), py + lengthdir_y(10, ah), hx, hy);
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
