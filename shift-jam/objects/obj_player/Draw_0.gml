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
    var tlx = random_range(-5, 5) * sq, tly = 17 * mech_scale;
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
    draw_rectangle(bx - 9, 0, bx + 9, btop, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    var seg = 0;
    for (var sy = btop - 13; sy > -32; sy -= 26) {
        draw_sprite(spr_zapper, (current_time div 50 + seg) mod 8, bx, sy);
        seg += 1;
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
    // la TRIVELLA, tenuta a destra e puntata avanti: nell'attacco scatta in avanti e gira veloce
    var thr = (sweep_anim > 0) ? sweep_anim * 1.6 : 0;
    var dsp = current_time * ((sweep_anim > 0) ? 1.5 : 0.3);
    global.draw_drill(x + 10 * mech_scale, y - 2 * mech_scale + bob * 0.5 - thr, 1, dsp, (drill_charge >= drill_full) ? 1 : 0);
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
