/// Boss in due fasi.
/// Fase 1: la nave madre da guerra degli alieni. Fase 2: perso il guscio, restano i KOI DELL'ENSŌ.
/// Disegnati dal codice: la mala (108 grani), un ensō a pennello che gira e si accorcia con la vita,
/// la perla al centro (il punto debole) e due carpe che le nuotano attorno.
/// Attacchi fase 1: cannoni mirati a raffica, hangar di Falene con corda, sipario di due ventagli, anelli sfalsati, spirale.
/// Difese: in fase 1 le navette SCUDO, in fase 2 il muro di GRU DI CARTA: si prendono i tuoi colpi.
/// Attacchi fase 2: spirale di squame, grani della mala d'oro (parabili, tornano contro il boss),
/// affondo della carpa d'oro (avviso d'oro, poi si lancia e scoppia in un anello di squame), petali (rete di due spirali).
/// Tutti i colpi magenta si parano. Deve essere piu' duro delle ultime ondate.
/// E' figlio di obj_enemy: colpi, falciata e contatto funzionano come con gli altri nemici.
phase = 1;
hp_p2 = 154;              // vita dei Koi (era 220: -30% il 16-11, per stare nella musica del boss)
hp_p1 = 210;              // vita della nave madre (era 300: -30% il 16-11)
hp = hp_p1 + hp_p2;       // un solo contatore: quando scende a hp_p2 il guscio si rompe
radius = 56;              // la nave madre e' grande
target_y = 140;           // dove si ferma dopo l'entrata
t = 0;
attack = 0;
attack_timer = 90;
transition = 0;           // > 0 mentre il guscio esplode e si rivela il Custode
debris = [];
bead_angle = 0;           // rotazione della mala
stun = 0;                 // il Custode resta stordito quando un palmo respinto lo colpisce
hint = 0;                 // per quanto mostrare il suggerimento sulla parata

// ===== ATTACCHI LUNGHI: durano piu' fotogrammi e si sovrappongono all'attacco successivo =====
volley_t = 0;             // CANNONI: raffiche mirate, una ogni 10 fotogrammi
fan_t = 0;                // SIPARIO: due ventagli sfalsati, il secondo copre i buchi del primo
ring_t = 0;               // ANELLI: tre o quattro anelli dalla prua, sfalsati di mezzo passo
ring_n = 0;
spin_t = 0;               // SPIRALE della nave madre: tre bracci che girano
spin_a = 0;
rope_t = 120;             // sotto meta' vita: corde mirate dai cannoni laterali
petal_t = 0;              // PETALI dei Koi: due spirali che girano in versi opposti (una rete)
petal_a = 0;
pearl_t = 90;             // la perla ti spara una corda ogni tanto: stare fermi non basta
gift_t = 0;               // REGALI: proiettili bianchi e neri che, spaccati, lasciano un'arma o il cuore (obj_gift).
                          // Fase 1: partono mezzo secondo dopo ogni hangar (dietro alle Falene, che sono piu' veloci: non si toccano). Fase 2: ogni 10 s, fra uno stormo di gru e l'altro
gift_n = 0;
shield_cd = array_create(5, 0);   // SCUDI (fase 1): navette con una lastra verde fra te e la nave madre (obj_shield).
                          // Le prime appena arriva; un posto rimasto vuoto si riempie dopo 4 s
shield_n = 4;             // quante (5 sotto meta' guscio)
shield_open = 0;          // > 0: gli scudi si aprono sui fianchi per far uscire le Falene dall'hangar (2,5 s)
crane_t = 0;              // GRU DI CARTA (fase 2): ogni 10 s uno stormo d'oro fa muro sotto i Koi (obj_crane)
crane_hint = -1;          // l'avviso "PARRY TEARS PAPER" sul cruscotto: 5 s, la prima volta che arrivano le gru

// ===== I KOI DELL'ENSŌ (fase 2) =====
enso_rot = 0;             // l'ensō gira
hp_prev = 0;              // per accorgersi dei colpi presi
pearl_flash = 0;          // la perla lampeggia quando e' colpita
bead_gone = array_create(108, 0);   // grani lanciati: mancano dalla mala per un po'
bead_sel = [];            // grani scelti per la prossima raffica (brillano d'oro prima di partire)
bead_t = 0;               // > 0: i grani scelti stanno per partire
spiral_t = 0;             // > 0: le carpe perdono squame a spirale
lunge_t = 0;              // > 0: la carpa d'oro carica (1-30) e si lancia (31-120)
l_x0 = 0; l_y0 = 0; l_tx = 0; l_ty = 0;   // da dove parte e dove mira l'affondo
koi_orb = 46;             // raggio del giro delle carpe
koi_ang = [0, 180];       // dove sono le due carpe sul giro
koi_hx = [[], []];        // scia della testa di ogni carpa (il corpo la segue)
koi_hy = [[], []];
koi_bx = [array_create(16, 0), array_create(16, 0)];   // 16 punti del corpo, dalla testa alla coda
koi_by = [array_create(16, 0), array_create(16, 0)];
// chiazze di ogni carpa: [dal punto, al punto, spostamento di lato]
koi_runs = [ [[2, 5, 0.3], [8, 11, -0.25]], [[1, 3, -0.3], [6, 9, 0.35], [11, 13, -0.2]] ];

/// riempie la scia delle carpe lungo il giro, cosi' appaiono gia' intere
koi_reset = function() {
    for (var k = 0; k < 2; k++) {
        koi_hx[k] = []; koi_hy[k] = [];
        for (var i = 90; i >= 0; i--) {
            var a = koi_ang[k] - i * 1.4;
            array_push(koi_hx[k], x + lengthdir_x(koi_orb, a));
            array_push(koi_hy[k], y + lengthdir_y(koi_orb * 0.92, a));
        }
        koi_sample(k);
    }
}

/// i 16 punti del corpo, presi ogni 5,6 pixel lungo la scia della testa
koi_sample = function(k) {
    var hx = koi_hx[k], hy = koi_hy[k];
    var bx = koi_bx[k], by = koi_by[k];
    var n = array_length(hx);
    var cx = hx[n - 1], cy = hy[n - 1];
    bx[@ 0] = cx; by[@ 0] = cy;
    var cnt = 1, acc = 0, i = n - 2;
    while (cnt < 16 && i >= 0) {
        var seg = point_distance(cx, cy, hx[i], hy[i]);
        if (acc + seg >= 5.6) {
            var u = (seg > 0) ? (5.6 - acc) / seg : 0;
            cx = lerp(cx, hx[i], u); cy = lerp(cy, hy[i], u);
            bx[@ cnt] = cx; by[@ cnt] = cy;
            cnt += 1; acc = 0;
        } else {
            acc += seg; cx = hx[i]; cy = hy[i]; i -= 1;
        }
    }
    while (cnt < 16) { bx[@ cnt] = bx[cnt - 1]; by[@ cnt] = by[cnt - 1]; cnt += 1; }
}

/// la carpa e' "fisica": true se un cerchio (px, py, r) tocca il corpo di una delle due
koi_touch = function(px, py, r) {
    if (phase != 2 || transition > 0) return false;
    for (var k = 0; k < 2; k++) {
        for (var i = 0; i < 16; i += 2) {
            var rd = (i < 3) ? 7 + 1.2 * i : max(2, 10.4 - (i - 3) * 0.68);
            if (point_distance(px, py, koi_bx[k][i], koi_by[k][i]) < r + rd * 0.8) return true;
        }
    }
    return false;
}

/// poligono pieno (a ventaglio dal primo vertice) con contorno
koi_poly = function(xs, ys, col, line) {
    var n = array_length(xs);
    draw_set_colour(col);
    draw_primitive_begin(pr_trianglefan);
    for (var i = 0; i < n; i++) draw_vertex(xs[i], ys[i]);
    draw_primitive_end();
    draw_set_colour(line);
    for (var i = 0; i < n; i++) draw_line(xs[i], ys[i], xs[(i + 1) mod n], ys[(i + 1) mod n]);
}

/// disegna una carpa: corpo che ondeggia, coda e pinne che battono, chiazze, occhi e baffi
koi_draw = function(k, body, patch, glow, ga) {
    var ink = make_colour_rgb(14, 10, 20);
    var light = merge_colour(body, c_white, 0.45);
    var ph = current_time * 0.0135;
    var bx = koi_bx[k], by = koi_by[k];
    var Px = array_create(16), Py = array_create(16), Nx = array_create(16), Ny = array_create(16);
    var Fx = array_create(16), Fy = array_create(16), R = array_create(16);
    for (var i = 0; i < 16; i++) {
        var dx, dy;
        if (i < 15) { dx = bx[i] - bx[i + 1]; dy = by[i] - by[i + 1]; }
        else        { dx = bx[i - 1] - bx[i]; dy = by[i - 1] - by[i]; }
        var L = max(0.001, point_distance(0, 0, dx, dy));
        Fx[i] = dx / L; Fy[i] = dy / L;          // verso la testa
        Nx[i] = -Fy[i]; Ny[i] = Fx[i];           // di lato
        var off = 2.6 * sin(ph - i * 0.8) * (0.15 + 0.85 * i / 15);   // ondulazione: piu' forte verso la coda
        Px[i] = bx[i] + Nx[i] * off; Py[i] = by[i] + Ny[i] * off;
        R[i] = (i < 3) ? 7 + 1.2 * i : max(2, 10.4 - (i - 3) * 0.68);   // testa tozza, ventre largo, coda sottile
    }
    // tre campioni per tratto: contorno liscio
    var Dx = [], Dy = [], Dnx = [], Dny = [], Dr = [], Dk = [];
    for (var i = 0; i < 15; i++) {
        for (var j = 0; j < 3; j++) {
            var u = j / 3;
            array_push(Dx, lerp(Px[i], Px[i + 1], u)); array_push(Dy, lerp(Py[i], Py[i + 1], u));
            array_push(Dnx, Nx[i]); array_push(Dny, Ny[i]);
            array_push(Dr, lerp(R[i], R[i + 1], u)); array_push(Dk, i + u);
        }
    }
    array_push(Dx, Px[15]); array_push(Dy, Py[15]); array_push(Dnx, Nx[15]); array_push(Dny, Ny[15]);
    array_push(Dr, R[15]); array_push(Dk, 15);
    var nd = array_length(Dx);

    // coda a due lobi che sbatte
    var tx = Px[15], ty = Py[15], nx = Nx[15], ny = Ny[15], bkx = -Fx[15], bky = -Fy[15];
    var fl = sin(ph - 13);
    for (var s = -1; s <= 1; s += 2) {
        var sw = s * 12 + 5 * fl;
        koi_poly([tx + nx * s * 1.5, tx + bkx * 7 + nx * s * 4, tx + bkx * 19 + nx * sw, tx + bkx * 13 + nx * fl * 3],
                 [ty + ny * s * 1.5, ty + bky * 7 + ny * s * 4, ty + bky * 19 + ny * sw, ty + bky * 13 + ny * fl * 3], light, ink);
    }
    // pinne pettorali morbide
    var fp = 0.75 + 0.25 * sin(current_time * 0.009);
    var qx = Px[3], qy = Py[3]; nx = Nx[3]; ny = Ny[3]; var fx = Fx[3], fy = Fy[3];
    for (var s = -1; s <= 1; s += 2) {
        koi_poly([qx + nx * s * 5, qx + nx * s * 21 * fp - fx * 9, qx + nx * s * 13 - fx * 14, qx + nx * s * 4 - fx * 7],
                 [qy + ny * s * 5, qy + ny * s * 21 * fp - fy * 9, qy + ny * s * 13 - fy * 14, qy + ny * s * 4 - fy * 7], light, ink);
    }
    // pinnette ventrali
    qx = Px[8]; qy = Py[8]; nx = Nx[8]; ny = Ny[8]; fx = Fx[8]; fy = Fy[8];
    for (var s = -1; s <= 1; s += 2) {
        koi_poly([qx + nx * s * 3, qx + nx * s * 9 - fx * 5, qx + nx * s * 2 - fx * 6],
                 [qy + ny * s * 3, qy + ny * s * 9 - fy * 5, qy + ny * s * 2 - fy * 6], light, ink);
    }
    // avviso d'oro prima dell'affondo
    if (glow > 0) {
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.5 * glow * ga);
        draw_set_colour(make_colour_rgb(255, 220, 120));
        for (var i = 0; i < nd; i += 4) draw_circle(Dx[i], Dy[i], Dr[i] + 3 + 2 * glow, false);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(ga);
    }
    // corpo: prima il contorno scuro, poi il colore
    draw_set_colour(ink);
    for (var i = 0; i < nd; i++) draw_circle(Dx[i], Dy[i], Dr[i] + 1, false);
    draw_set_colour(body);
    for (var i = 0; i < nd; i++) draw_circle(Dx[i], Dy[i], Dr[i], false);
    // chiazze: macchie continue, spostate di lato
    draw_set_colour(patch);
    var runs = koi_runs[k];
    for (var r = 0; r < array_length(runs); r++) {
        var k0 = runs[r][0], k1 = runs[r][1], side = runs[r][2];
        for (var i = 0; i < nd; i++) {
            if (Dk[i] < k0 || Dk[i] > k1) continue;
            var f = min(1, 0.45 + min(Dk[i] - k0, k1 - Dk[i]) * 0.6);
            draw_circle(Dx[i] + Dnx[i] * side * Dr[i], Dy[i] + Dny[i] * side * Dr[i], Dr[i] * 0.62 * f, false);
        }
    }
    // riflesso sul dorso
    draw_set_colour(merge_colour(body, c_white, 0.6));
    for (var i = 1; i < 30; i++) draw_circle(Dx[i] - Dnx[i] * Dr[i] * 0.35, Dy[i] - Dny[i] * Dr[i] * 0.35, max(0.8, Dr[i] * 0.18), false);
    // occhi e baffi
    qx = Px[0]; qy = Py[0]; nx = Nx[0]; ny = Ny[0]; fx = Fx[0]; fy = Fy[0];
    for (var s = -1; s <= 1; s += 2) {
        draw_set_colour(ink);
        draw_circle(qx + nx * s * 4.8 + fx * 1.5, qy + ny * s * 4.8 + fy * 1.5, 1.7, false);
        draw_set_colour(make_colour_rgb(235, 205, 130));
        draw_line(qx + fx * 6 + nx * s * 2.5, qy + fy * 6 + ny * s * 2.5, qx + fx * 9 + nx * s * 7, qy + fy * 9 + ny * s * 7);
    }
}

// RITIRATA: quando il tempo dell'ondata scade se ne va (la muove la Begin Step di obj_enemy)
retreat = false;
rspd = 0;
rdir = 90;
