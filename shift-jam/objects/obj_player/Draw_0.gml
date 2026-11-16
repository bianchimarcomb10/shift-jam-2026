/// Navicella e mecha: il PELLEGRINO (scr_pilgrim). Stessi pezzi nelle due forme:
/// cappello -> muso, mantello -> ali, gambe -> motori, lama della falce -> mezzaluna dietro i motori.
/// Nello spazio il mecha e' SOSPESO; a terra (obj_mech_ground) sta in GUARDIA.
// scintille delle parate: una crocetta bianca che si allarga e svanisce
draw_set_colour(c_white);
for (var k = 0; k < array_length(sparks); k++) {
    var sp = sparks[k];
    var sr = 2 + (12 - sp[2]) * 0.6;
    draw_set_alpha(sp[2] / 12);
    draw_line(sp[0] - sr, sp[1], sp[0] + sr, sp[1]);
    draw_line(sp[0], sp[1] - sr, sp[0], sp[1] + sr);
}
draw_set_alpha(1);

if (invuln > 0 && (invuln div 4) mod 2 == 0) exit;   // lampeggia dopo un colpo

var m = form;
if (transform_timer > 0) {
    var tt = 1 - transform_timer / 6;      // da 0 a 1 durante i 6 frame del cambio
    m = (form == 0) ? tt : 1 - tt;
}

// --- VITA: quanto si e' mosso in questo fotogramma ---
// navicella e mecha si inclinano allo stesso modo in virata: tutto ruota attorno al centro (x, y)
var mvx = x - xprevious, mvy = y - yprevious;
tilt += (clamp(mvx, -4, 4) * 4 - tilt) * 0.2;   // si inclina in virata e torna dritto piano
var bob = dsin(current_time * 0.25);            // respiro lento, sempre
var sq = 1 - abs(tilt) / 60;                    // inclinato: si stringe come se girasse su se stesso
var rc = dcos(-tilt), rs = dsin(-tilt);         // per ruotare un punto (lx, ly) attorno a (x, y)
// punto ruotato: x + lx * rc + ly * rs , y - lx * rs + ly * rc

// scia del motore: le scintille nascono sotto il motore (che si inclina con la nave) e scivolano indietro
if (form == 0 && transform_timer == 0) {
    var tlx = random_range(-3, 3) * sq, tly = 14 + bob * 0.6;
    array_push(trail, [x + tlx * rc + tly * rs, y - tlx * rs + tly * rc, 14]);
} else if (form == 1 && transform_timer == 0) {
    // anche il mecha SOSPESO vola: la scia esce dalla fiamma sotto il mantello
    var tlx = random_range(-5, 5) * sq, tly = global.mecha_sketch ? 36 : 17 * mech_scale;   // il mecha dello sketch ha le fiamme piu' in basso
    array_push(trail, [x + tlx * rc + tly * rs, y - tlx * rs + tly * rc, 14]);
}
gpu_set_blendmode(bm_add);
for (var q = array_length(trail) - 1; q >= 0; q--) {
    var tr = trail[q];
    tr[2] -= 1;
    tr[1] += 1.6;
    if (tr[2] <= 0) { array_delete(trail, q, 1); continue; }
    trail[q] = tr;
    draw_set_alpha(tr[2] / 14 * 0.6);
    draw_set_colour(merge_colour(make_colour_rgb(80, 160, 255), c_white, tr[2] / 14));
    draw_circle(tr[0], tr[1], 1 + tr[2] / 10, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// LASER (arma speciale): il raggio azzurro sale dalla prua fino in cima, dietro la navicella
if (beam_on) {
    var bx = x, btop = y - 14;
    gpu_set_blendmode(bm_add);
    draw_set_colour(make_colour_rgb(40, 140, 255));
    draw_set_alpha(0.22 + 0.08 * dsin(current_time * 2));
    draw_rectangle(bx - 9, max(0, beam_top), bx + 9, btop, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    var seg = 0;
    for (var sy = btop - 13; sy > beam_top - 13; sy -= 26) {
        draw_sprite(spr_zapper, (current_time div 50 + seg) mod 8, bx, sy);
        seg += 1;
    }
    // fermato da uno scudo o da una gru: schizza contro
    if (beam_top > 0) {
        gpu_set_blendmode(bm_add);
        draw_set_colour(make_colour_rgb(40, 140, 255));
        draw_set_alpha(0.5);
        draw_circle(bx, beam_top + 8, 10 + random(3), false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
        draw_set_colour(make_colour_rgb(215, 250, 255));
        draw_circle(bx, beam_top + 8, 4 + random(2), false);
    }
    // dove nasce: un lampo bianco sulla prua
    draw_set_colour(make_colour_rgb(215, 250, 255));
    draw_circle(bx, btop + 2, 3 + random(1.5), false);
    draw_set_colour(c_white);
}

var flash = shift_flash / 12;   // l'ensō azzurro del cambio
if (form == 0 && transform_timer == 0) {
    // navicella viva: si inclina, galleggia, la fiamma si allunga quando sale
    var fl = 1 + clamp(-mvy, -3, 4) * 0.12;
    var by = bob * 0.6;
    draw_pilgrim(x + by * rs, y + by * rc, 0, tilt, 0, sweep_radius, flash, mech_scale, true, fl);
} else {
    // mecha (o trasformazione in corso): nello spazio e' SOSPESO (pose 1): niente gambe, mantello a strisce,
    // fiamma del volo, falce dritta a due mani; nella falciata gira con la falce tesa.
    // Con la trivella in mano la falce non c'e': le due mani tengono la trivella
    draw_pilgrim(x, y, m, tilt, sweep_anim, sweep_radius, flash, mech_scale, !global.has_drill, 1, 1, 1);
}

// CUORE preso: la nave SI RIPARA. Tre anelli azzurri si stringono su di lei (il cuore entra nello scafo),
// poi la nave brilla sempre meno per 2 secondi. Sul cruscotto la spia ritrovata lampeggia e c'e' scritto HULL REPAIRED
if (heal_t > 0) {
    gpu_set_blendmode(bm_add);
    if (heal_t > 70) {
        var rk = (120 - heal_t) / 50;   // 0 -> 1 nei primi 50 fotogrammi
        draw_set_colour(make_colour_rgb(110, 210, 255));
        for (var q = 0; q < 3; q++) {
            var rr = (1 - rk) * 64 - q * 14;
            if (rr <= 2) continue;
            draw_set_alpha(0.3 + 0.5 * rk);
            draw_circle(x, y, rr, true);
            draw_circle(x, y, rr + 1, true);
        }
    }
    draw_set_alpha(0.55 * heal_t / 120 * (0.6 + 0.4 * dsin(current_time * 1.2)));
    draw_set_colour(make_colour_rgb(70, 190, 255));
    draw_circle(x, y, 18, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

// ARMA SPECIALE: una barretta azzurra sotto la navicella che si accorcia con le munizioni
if (special > 0) {
    var bw = 24 * clamp(special_ammo / special_full, 0, 1);
    var byy = y + (global.has_drill ? 34 : 24);
    draw_set_colour(c_black);
    draw_rectangle(x - 13, byy - 2, x + 13, byy + 2, false);
    draw_set_colour((special_ammo < special_full * 0.2 && (current_time div 120) mod 2 == 0) ? c_white : make_colour_rgb(110, 210, 255));   // lampeggia quando stanno finendo
    if (bw > 0) draw_rectangle(x - 12, byy - 1, x - 12 + bw, byy + 1, false);
    draw_set_colour(c_white);
}

// TRIVELLA: dieci tacche sotto il giocatore = colpi parati andati a segno (la carica)
if (global.has_drill) {
    draw_set_colour(c_black);
    draw_rectangle(x - 16, y + 24, x + 15, y + 28, false);
    for (var dk = 0; dk < drill_full; dk++) {
        var dxk = x - 15 + dk * 3, dyk = y + 25;
        if (dk < drill_charge) draw_set_colour((drill_charge >= drill_full && (current_time div 120) mod 2 == 0) ? c_white : make_colour_rgb(110, 210, 255));
        else draw_set_colour(make_colour_rgb(50, 60, 80));
        draw_rectangle(dxk, dyk, dxk + 1, dyk + 2, false);
    }
    draw_set_colour(c_white);
}

if (form == 1 && transform_timer == 0 && global.has_drill) {
    // la TRIVELLA GRANDE (Chelios, 16-11: "in mano risulta troppo piccola", poi "un pochino piu' grande"): cono 34x48.
    // Sta nella mano di prima, a destra (spostata di 3 px in fuori e 2 in giu', cosi' non copre il cappello):
    // la destra la impugna sotto il collare, la sinistra attraversa la pancia e sorregge il pugno da sotto.
    // La trivella si disegna SOPRA le braccia (Chelios: "occhio che va sotto").
    // Gira sempre e vibra (e' accesa), con l'aria che sale attorno al cono e tre scintille sulla punta.
    // Nell'attacco scatta in alto con le due braccia e gira veloce.
    // Bozze e anteprima animata: /mnt/project-files/trivella-bozze/
    var dst = 2.4;                                             // un "pixel" della trivella (era 1)
    var dH = 20 * dst;                                         // altezza del cono
    var thr = (sweep_anim > 0) ? sweep_anim * 1.6 : 0;
    var dsp = current_time * ((sweep_anim > 0) ? 1.5 : 0.48);  // gira sempre (prima 0.3)
    var fy = y + 1.5 * dsin(current_time * 0.15);              // galleggia insieme al corpo (draw_mecha)
    var jit = (current_time div 50) mod 2;                     // vibra di un pixel
    // un punto del corpo (lx, ly) sullo schermo: stretto e ruotato in virata come lo sprite del mecha
    var lx = 15 * sq, ly = 0;                                  // la mano (prima era a 12, -2.4)
    var dbx = round(x + lx * rc + ly * rs) + jit;              // centro della base (il collare)
    var dby = round(fy - lx * rs + ly * rc - thr);
    var rfx = dbx, rfy = dby + round(2 * dst) + 3;             // pugno destro, sul manico sotto il collare
    var lhx = rfx - 1, lhy = rfy + 5;                          // mano sinistra, a coppa sotto il pugno
    // le braccia, corte (Chelios, 16-11: "un po' troppo lunghe", versione A della bozza):
    // il DESTRO ha la spalla dietro la trivella e il gomito sotto il collare, e sale al pugno;
    // il SINISTRO esce da sotto il lembo sinistro del mantello e va in diagonale fino a sotto il pugno
    lx = 19 * sq; ly = -8;  var rsx = x + lx * rc + ly * rs, rsy = fy - lx * rs + ly * rc;    // spalla destra (coperta dalla trivella)
    lx = 23 * sq; ly = 13;  var rex = x + lx * rc + ly * rs, rey = fy - lx * rs + ly * rc;    // gomito destro, sotto il collare
    lx = -13 * sq; ly = 3;  var lsx = x + lx * rc + ly * rs, lsy = fy - lx * rs + ly * rc;    // dove il sinistro esce dal mantello
    mecha_drill_arm(lsx, lsy, lsx, lsy, lhx, lhy);
    // il lembo sinistro del mantello, ridisegnato SOPRA l'attacco del braccio: cosi' il braccio ne esce da sotto.
    // E' un pezzo dello sprite del corpo (x 24-38, y 40-63 nell'immagine), stesso fotogramma, stesse scala e rotazione
    var mfr = (sweep_anim > 0) ? (current_time div 50) mod 12 : (current_time div 100) mod 12;   // come draw_mecha
    lx = (24 - 47) * sq; ly = 40 - 47;
    draw_sprite_general(spr_mecha_body, mfr, 24, 40, 15, 24, x + lx * rc + ly * rs, fy - lx * rs + ly * rc, sq, 1, -tilt, c_white, c_white, c_white, c_white, 1);
    mecha_drill_arm(rsx, rsy, rex, rey, rfx, rfy);
    // il manico d'acciaio sotto il collare, e i due pugni che lo stringono
    draw_set_colour(make_colour_rgb(14, 10, 20));
    draw_rectangle(dbx - 2, dby + 2 * dst, dbx + 1, dby + 2 * dst + 9, false);
    draw_set_colour(make_colour_rgb(60, 70, 95));
    draw_rectangle(dbx - 1, dby + 2 * dst, dbx, dby + 2 * dst + 8, false);
    mecha_drill_fist(lhx, lhy);
    mecha_drill_fist(rfx, rfy);
    // la trivella, sopra a tutto
    global.draw_drill(dbx, dby, dst, dsp, (drill_charge >= drill_full) ? 1 : 0);
    // il vortice: tre archi d'aria azzurra che salgono dalla base alla punta, sempre piu' stretti
    gpu_set_blendmode(bm_add);
    draw_set_colour(make_colour_rgb(60, 170, 255));
    for (var k = 0; k < 3; k++) {
        var vf = frac(current_time / 700 + k / 3);           // 0 = base, 1 = punta
        var vy = dby - vf * dH, vr = 8 * dst * (1 - vf) * 0.9 + 3;
        draw_set_alpha(0.67 * max(0, 1 - abs(vf - 0.5) * 1.2));
        for (var va = 200; va < 340; va += 20) {
            draw_line(dbx + vr * dcos(va), vy + 2 * dsin(va), dbx + vr * dcos(va + 20), vy + 2 * dsin(va + 20));
        }
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    // tre scintille che girano attorno alla punta
    draw_set_colour(make_colour_rgb(215, 250, 255));
    var tk = current_time / 50, tipy = dby - dH - dst;
    for (var s2 = 0; s2 < 3; s2++) {
        var sph = (tk * 0.37 + s2 * 1.9) * 3;                // radianti
        var srr = 4 + ((floor(tk) + s2 * 5) mod 8);
        draw_point(dbx + srr * cos(sph), tipy - 2 + srr * 0.5 * sin(sph));
    }
    draw_set_colour(c_white);
    if (sweep_anim > 0) {
        // il colpo: un ventaglio azzurro davanti (non piu' un cerchio intorno)
        var rr = sweep_radius + 16;
        gpu_set_blendmode(bm_add);
        draw_set_alpha(sweep_anim / 10 * 0.35);
        draw_set_colour(make_colour_rgb(60, 160, 255));
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(x, y);
        for (var fa = 40; fa <= 140; fa += 10) draw_vertex(x + lengthdir_x(rr, fa), y + lengthdir_y(rr, fa));
        draw_primitive_end();
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(sweep_anim / 10);
        draw_set_colour(make_colour_rgb(120, 235, 255));
        for (var fa2 = 40; fa2 < 140; fa2 += 10) {
            draw_line_width(x + lengthdir_x(rr, fa2), y + lengthdir_y(rr, fa2), x + lengthdir_x(rr, fa2 + 10), y + lengthdir_y(rr, fa2 + 10), 2);
        }
        draw_set_alpha(1);
        draw_set_colour(c_white);
    }
}
