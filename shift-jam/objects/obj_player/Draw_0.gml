/// Navicella e mecha: il PELLEGRINO (scr_pilgrim). Stessi pezzi nelle due forme:
/// cappello -> muso, mantello -> ali, gambe -> motori, lama della falce -> mezzaluna dietro i motori.
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

var flash = shift_flash / 12;   // l'ensō azzurro del cambio
if (form == 0 && transform_timer == 0) {
    // navicella viva: si inclina, galleggia, la fiamma si allunga quando sale
    var fl = 1 + clamp(-mvy, -3, 4) * 0.12;
    var by = bob * 0.6;
    draw_pilgrim(x + by * rs, y + by * rc, 0, tilt, 0, sweep_radius, flash, mech_scale, true, fl);
} else {
    // mecha (o trasformazione in corso): il mantello ondeggia e si apre nella falciata,
    // la falce gira attorno nella falciata; con la trivella in mano la falce non c'e'
    draw_pilgrim(x, y, m, tilt, sweep_anim, sweep_radius, flash, mech_scale, !global.has_drill, 1);
}

// TRIVELLA: tre tacche sotto il giocatore = colpi rimandati di fila (la carica)
if (global.has_drill) {
    for (var dk = 0; dk < 3; dk++) {
        var dxk = x - 8 + dk * 8, dyk = y + 26;
        draw_set_colour(c_black);
        draw_rectangle(dxk - 3, dyk - 3, dxk + 3, dyk + 3, false);
        if (dk < drill_charge) draw_set_colour((drill_charge >= 3 && (current_time div 120) mod 2 == 0) ? c_white : make_colour_rgb(110, 210, 255));
        else draw_set_colour(make_colour_rgb(50, 60, 80));
        draw_rectangle(dxk - 2, dyk - 2, dxk + 2, dyk + 2, false);
    }
    draw_set_colour(c_white);
}

if (form == 1 && transform_timer == 0 && global.has_drill) {
    // la TRIVELLA, tenuta a destra e puntata avanti: nell'attacco scatta in avanti e gira veloce
    var thr = (sweep_anim > 0) ? sweep_anim * 1.6 : 0;
    var dsp = current_time * ((sweep_anim > 0) ? 1.5 : 0.3);
    global.draw_drill(x + 10 * mech_scale, y - 2 * mech_scale + bob * 0.5 - thr, 1, dsp, (drill_charge >= 3) ? 1 : 0);
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
