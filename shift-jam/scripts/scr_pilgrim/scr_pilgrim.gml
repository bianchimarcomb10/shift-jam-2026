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

/// IL MECHA DALLO SKETCH di Francesco "Rocketbird" Passero (dal 2026-11-14): il mecha non e' piu' a poligoni,
/// e' fatto di due sprite: spr_mecha_body (12 frame: mantello, fiamme, luci) e spr_mecha_scythe
/// (36 frame: la falce girata di 10 gradi alla volta; frame 0 = a riposo, lama in basso a destra a 45 gradi).
/// Origine di tutti e due = la vita, dove le mani tengono la falce. La navicella resta quella a poligoni.
/// false = torna il mecha a poligoni di prima (per confrontare)
global.mecha_sketch = true;

/// GRANDEZZA DEL MECHA (Chelios, 16-11: "riducimi la dimensione del mecha, rendendola coerente con il suo hitbox").
/// Gli sprite sono 94x94 e il mantello e' largo 40 px: a 0.5 e' largo 20 px, quanto la hitbox (raggio 10, obj_player Step).
/// Vale per il mecha in volo, per quello a terra e per la trivella in mano (obj_player Draw).
/// Il raggio della falciata (fin dove taglia) NON cambia: la scia arriva sempre li'.
global.mecha_size = 0.5;

/// VERSO DELLA FALCIATA: 1 = antiorario, -1 = orario.
global.sweep_dir = 1;

/// FALCIATA (Chelios, 16-11: "parte dalla sua punta e si muove in senso antiorario"):
/// primo frame fermo, con un lampo sulla PUNTA della lama; poi la falce fa tutto il giro e la scia nasce
/// dalla punta e si allarga fino a dove taglia (R). Veloce all'inizio, poi rallenta e si ferma in basso a destra.
/// sweep: frame rimasti (10..1, 0 = ferma) | R: raggio della falciata | sc: scala del disegno (1 nel gioco)
function draw_mecha(px, py, tilt, sweep, R, sc, scythe) {
    var ms = sc * global.mecha_size;                              // scala degli sprite
    var yy = py + 1.5 * dsin(current_time * 0.15) * ms;          // galleggia
    var rot = -tilt;                                              // si inclina in virata come la navicella
    var sq = 1 - abs(tilt) / 60;
    // il mantello: 10 frame al secondo, il doppio mentre falcia
    var fr = (sweep > 0) ? (current_time div 50) mod 12 : (current_time div 100) mod 12;
    // quanto e' girata la falce dal riposo (gradi, positivo = antiorario)
    var th = 3 * dsin(current_time * 0.2 - 40);                  // ferma: ondeggia appena col respiro
    var dir = global.sweep_dir;
    if (sweep > 0) {
        var u = clamp((10 - sweep) / 9, 0, 1);                    // sweep 10 = ancora ferma, sweep 1 = giro finito
        th = dir * 360 * (1 - power(1 - u, 2));
    }
    // la scia azzurra: comincia sulla punta della lama e resta dietro (rispetto al verso del giro)
    if (sweep > 0 && scythe) {
        var tip_r = 39 * ms, heel_r = 22 * ms;                    // punta e bordo interno della lama (sprite: 39 e 22 px)
        var lead = th + rot + 4;                                  // a riposo la punta sta a 4 gradi (a destra)
        var len = min(150, abs(th));
        var fade = sqrt(sweep / 10);
        var r_cut = R * sc;
        gpu_set_blendmode(bm_add);
        if (len > 0) {
            for (var i = 0; i < 24; i++) {
                var u0 = i / 24, u1 = (i + 1) / 24;
                var b0 = lead - dir * u0 * len, b1 = lead - dir * u1 * len;
                // sulla punta e' larga quanto la lama, poi si allarga fino a dove taglia
                var g0 = min(1, u0 / 0.3), g1 = min(1, u1 / 0.3);
                var o0 = tip_r + (r_cut - tip_r) * g0, o1 = tip_r + (r_cut - tip_r) * g1;
                var i0 = heel_r + (r_cut - 20 * sc - heel_r) * g0, i1 = heel_r + (r_cut - 20 * sc - heel_r) * g1;
                draw_set_colour(make_colour_rgb(40, 140, 255));
                draw_set_alpha(0.6 * (1 - u0) * fade);
                draw_primitive_begin(pr_trianglestrip);
                draw_vertex(px + lengthdir_x(o0, b0), yy + lengthdir_y(o0, b0));
                draw_vertex(px + lengthdir_x(i0, b0), yy + lengthdir_y(i0, b0));
                draw_vertex(px + lengthdir_x(o1, b1), yy + lengthdir_y(o1, b1));
                draw_vertex(px + lengthdir_x(i1, b1), yy + lengthdir_y(i1, b1));
                draw_primitive_end();
                // il filo chiaro sul bordo esterno: fin dove arriva
                draw_set_colour(make_colour_rgb(215, 250, 255));
                draw_set_alpha(0.7 * (1 - u0) * fade);
                draw_line(px + lengthdir_x(o0, b0), yy + lengthdir_y(o0, b0), px + lengthdir_x(o1, b1), yy + lengthdir_y(o1, b1));
            }
        }
        // il lampo sulla punta, nei primi due frame
        if (sweep >= 9) {
            var tx = px + lengthdir_x(tip_r, lead), ty = yy + lengthdir_y(tip_r, lead);
            var ls = (sweep == 10) ? 4 : 3;
            draw_set_colour(make_colour_rgb(215, 250, 255));
            draw_set_alpha(1);
            draw_line(tx - ls, ty, tx + ls, ty);
            draw_line(tx, ty - ls, tx, ty + ls);
        }
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_colour(c_white);
    }
    draw_sprite_ext(spr_mecha_body, fr, px, yy, sq * ms, ms, rot, c_white, 1);
    if (scythe) {
        // frame piu' vicino (10 gradi l'uno) + il resto con la rotazione dello sprite
        var a = th + rot;
        var k = round(a / 10);
        draw_sprite_ext(spr_mecha_scythe, ((k mod 36) + 36) mod 36, px, yy, ms, ms, a - k * 10, c_white, 1);
    }
}

/// BRACCIO del mecha con la trivella (gli sprite di Francesco non hanno braccia: le disegna il codice).
/// (Non si chiama pil_arm: quel nome ce l'ha gia' il braccio del mecha a poligoni, piu' sotto.)
/// Spalla (x0, y0), gomito (x1, y1), mano (x2, y2), in pixel dello schermo. w = spessore della manica.
/// Manica blu scuro del mantello con il contorno d'inchiostro e una riga di luce della stoffa sopra.
function mecha_drill_arm(x0, y0, x1, y1, x2, y2, w = 5) {
    draw_set_colour(make_colour_rgb(14, 10, 20));          // contorno
    draw_line_width(x0, y0, x1, y1, w + 2);
    draw_line_width(x1, y1, x2, y2, w + 2);
    draw_circle(x0, y0, (w + 1) / 2, false);
    draw_circle(x1, y1, (w + 1) / 2, false);               // il gomito, senza tacche
    draw_set_colour(make_colour_rgb(45, 51, 94));          // manica: l'ombra del mantello
    draw_line_width(x0, y0, x1, y1, w);
    draw_line_width(x1, y1, x2, y2, w);
    draw_circle(x1, y1, (w - 1) / 2, false);
    draw_set_colour(make_colour_rgb(78, 92, 168));         // luce della stoffa
    draw_line(x0 - 1, y0 - 1, x1 - 1, y1 - 1);
    draw_line(x1 - 1, y1 - 1, x2 - 1, y2 - 1);
    draw_set_colour(c_white);
}
/// PUGNO d'acciaio col contorno, centrato in (px, py). r = 3: 6x6 (mecha grande), r = 2: 4x4 (mecha a meta')
function mecha_drill_fist(px, py, r = 3) {
    px = round(px); py = round(py);
    draw_set_colour(make_colour_rgb(14, 10, 20));
    draw_rectangle(px - r, py - r, px + r - 1, py + r - 1, false);
    draw_set_colour(make_colour_rgb(170, 186, 206));
    draw_rectangle(px - r + 1, py - r + 1, px + r - 2, py + r - 2, false);
    draw_set_colour(c_white);
}

/// l'ensō azzurro del cambio forma: si apre e svanisce (flash 1 -> 0)
function pil_enso(px, py, flash, sc) {
    if (flash <= 0) return;
    var r = (12 + 20 * (1 - flash)) * sc;
    var st = 120 + 200 * (1 - flash);
    draw_set_colour(make_colour_rgb(215, 250, 255));
    for (var i = 0; i < 30; i++) {
        var u0 = i / 30;
        var b0 = st + u0 * 320, b1 = st + (u0 + 1 / 30) * 320;
        draw_set_alpha(0.9 * flash * (1 - 0.6 * u0));
        draw_line_width(px + lengthdir_x(r, b0), py + lengthdir_y(r, b0), px + lengthdir_x(r, b1), py + lengthdir_y(r, b1),
            max(1, (1 - u0) * 5 * flash + 1));
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

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
    if (global.mecha_sketch && m >= 0.5) {
        // il mecha dello sketch (lo stesso a terra e nello spazio); la trasformazione la copre l'ensō
        draw_mecha(px, py, tilt, sweep, sweep_r, sc, scythe);
        pil_enso(px, py, flash, sc);
        return;
    }
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
    pil_enso(px, py, flash, sc);
    draw_set_colour(c_white);
}
