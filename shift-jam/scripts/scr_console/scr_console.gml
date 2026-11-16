/// IL CRUSCOTTO: la plancia della nave in fondo allo schermo, separata dall'area di gioco.
///   a sinistra  HULL: le spie della vita (e della trivella, quando ce l'hai)
///   al centro   la LEVA dello SHIFT, una cloche che scatta tra SHIP e MECHA
///   a destra    uno schermo che mostra i comandi, o l'avviso del momento
/// Si chiama da obj_game (Draw GUI): legge le variabili di obj_game (game_over).

#macro HUD_H 72   // altezza del cruscotto: sotto questa riga non si gioca
#macro BUILD "16-NOV-J"   // la versione, scritta in piccolo sul titolo: dice quale zip e' installato

global.console_k = 0;   // posizione della leva (0 = SHIP, 1 = MECHA), si muove morbida

/// incasso scuro con bordo smussato (ombra in alto a sinistra, luce in basso a destra)
function console_recess(x1, y1, x2, y2) {
    draw_set_colour(make_colour_rgb(10, 10, 18));
    draw_rectangle(x1, y1, x2, y2, false);
    draw_set_colour(make_colour_rgb(4, 4, 8));
    draw_line(x1, y1, x2, y1);
    draw_line(x1, y1, x1, y2);
    draw_set_colour(make_colour_rgb(62, 66, 92));
    draw_line(x1, y2, x2, y2);
    draw_line(x2, y1, x2, y2);
}

/// rivetto
function console_rivet(rx, ry) {
    draw_set_colour(make_colour_rgb(8, 8, 14));
    draw_circle(rx + 0.5, ry + 0.5, 2, false);
    draw_set_colour(make_colour_rgb(78, 84, 110));
    draw_circle(rx, ry, 1.5, false);
}

/// spia rettangolare: accesa (con alone) o spenta
function console_lamp(x1, y1, x2, y2, on, col) {
    if (on) {
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.35);
        draw_set_colour(col);
        draw_rectangle(x1 - 2, y1 - 2, x2 + 2, y2 + 2, false);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_colour(col);
        draw_rectangle(x1, y1, x2, y2, false);
        draw_set_colour(merge_colour(col, c_white, 0.6));
        draw_line(x1, y1, x2, y1);              // riflesso in cima
    } else {
        draw_set_colour(make_colour_rgb(30, 34, 52));
        draw_rectangle(x1, y1, x2, y2, false);
        draw_set_colour(make_colour_rgb(44, 50, 72));
        draw_line(x1, y1, x2, y1);
    }
}

function draw_console() {
    var gw = display_get_gui_width();
    var y0 = room_height - HUD_H;
    var cyan   = make_colour_rgb(70, 190, 255);
    var cyan_l = make_colour_rgb(215, 250, 255);
    var label  = make_colour_rgb(140, 150, 185);
    var dim    = make_colour_rgb(64, 72, 100);
    var blink  = ((current_time div 250) mod 2 == 0);
    var pl = instance_find(obj_player, 0);   // noone se il giocatore non c'e'

    draw_set_font(fnt_main);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // ===== SCOCCA: lamiera scura, con il cofano rialzato al centro =====
    draw_set_colour(make_colour_rgb(26, 28, 42));
    draw_rectangle(0, y0 + 6, gw, room_height, false);
    draw_triangle(100, y0 + 6, 116, y0, 116, y0 + 6, false);
    draw_rectangle(116, y0, 244, y0 + 6, false);
    draw_triangle(244, y0, 260, y0 + 6, 244, y0 + 6, false);
    // bordo: filo azzurro (la luce della cabina) e smusso chiaro
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.45);
    draw_set_colour(cyan);
    draw_line(0, y0 + 5, 100, y0 + 5); draw_line(100, y0 + 5, 116, y0 - 1);
    draw_line(116, y0 - 1, 244, y0 - 1); draw_line(244, y0 - 1, 260, y0 + 5); draw_line(260, y0 + 5, gw, y0 + 5);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(96, 104, 140));
    draw_line(0, y0 + 6, 100, y0 + 6); draw_line(100, y0 + 6, 116, y0);
    draw_line(116, y0, 244, y0); draw_line(244, y0, 260, y0 + 6); draw_line(260, y0 + 6, gw, y0 + 6);
    console_rivet(5, y0 + 12); console_rivet(gw - 6, y0 + 12);
    console_rivet(5, room_height - 6); console_rivet(gw - 6, room_height - 6);
    console_rivet(122, y0 + 5); console_rivet(238, y0 + 5);

    // ===== SINISTRA: HULL (vita) e DRILL (carica della trivella) =====
    console_recess(10, y0 + 12, 100, room_height - 6);
    draw_set_colour(label);
    draw_text(16, y0 + 15, "HULL");
    var danger = (global.hp == 1);   // ultima spia: lampeggia bianca
    for (var i = 0; i < 3; i++) {
        var lx = 16 + i * 28;
        var on = (global.hp > i);
        var lc = (danger && on && blink) ? c_white : cyan;
        if (pl != noone && pl.heal_t > 0 && i == global.hp - 1 && blink) lc = c_white;   // la spia appena riparata lampeggia
        console_lamp(lx, y0 + 31, lx + 21, y0 + 40, on, lc);
    }
    if (global.has_drill) {
        // icona della trivella (un cono con le spire) e dieci spie della carica (colpi parati andati a segno)
        draw_set_colour(label);
        draw_triangle(16, y0 + 60, 28, y0 + 60, 22, y0 + 47, false);
        draw_set_colour(make_colour_rgb(26, 28, 42));
        draw_line(18, y0 + 56, 26, y0 + 54);
        draw_line(20, y0 + 52, 24, y0 + 50);
        var ch = (pl != noone) ? pl.drill_charge : 0;
        var full = (pl != noone) ? pl.drill_full : 10;
        for (var i = 0; i < full; i++) {
            var dx = 34 + i * 6;
            var dc = (ch >= full && blink) ? c_white : cyan;
            console_lamp(dx, y0 + 50, dx + 3, y0 + 58, ch > i, dc);
        }
    }

    // ===== CENTRO: la LEVA dello SHIFT =====
    var target = global.console_k;
    if (pl != noone) {
        target = pl.form;
        if (pl.transform_timer > 0) {
            var tt = 1 - pl.transform_timer / 6;
            target = (pl.form == 0) ? tt : 1 - tt;
        }
    }
    global.console_k += (target - global.console_k) * 0.4;
    var k = global.console_k;
    // le due posizioni, scritte sopra la scanalatura: quella attiva e' accesa
    draw_set_halign(fa_center);
    draw_set_colour((k < 0.5) ? cyan_l : dim);
    draw_text(138, y0 + 12, "SHIP");
    draw_set_colour((k >= 0.5) ? cyan_l : dim);
    draw_text(222, y0 + 12, "MECHA");
    // la scanalatura in cui scorre la leva
    console_recess(134, y0 + 29, 226, y0 + 35);
    // base della cloche e asta inclinata verso la posizione attuale
    var kx = lerp(138, 222, k), ky = y0 + 32;
    draw_set_colour(make_colour_rgb(8, 8, 14));
    draw_ellipse(166, y0 + 58, 194, y0 + 68, false);
    draw_set_colour(make_colour_rgb(50, 54, 76));
    draw_ellipse(168, y0 + 59, 192, y0 + 66, false);
    draw_set_colour(make_colour_rgb(8, 8, 14));
    draw_line_width(180, y0 + 62, kx, ky, 5);
    draw_set_colour(make_colour_rgb(120, 130, 160));
    draw_line_width(180, y0 + 62, kx, ky, 3);
    // pomello azzurro che brilla
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.4);
    draw_set_colour(cyan);
    draw_circle(kx, ky, 9, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(8, 8, 14));
    draw_circle(kx, ky, 6, false);
    draw_set_colour(cyan);
    draw_circle(kx, ky, 5, false);
    draw_set_colour(cyan_l);
    draw_circle(kx - 1.5, ky - 1.5, 1.5, false);

    // ===== DESTRA: lo schermo con i comandi o l'avviso del momento =====
    var sx1 = 264, sy1 = y0 + 12, sx2 = gw - 8, sy2 = room_height - 6;   // 88 px: 8 lettere per riga
    console_recess(sx1 - 2, sy1 - 2, sx2 + 2, sy2 + 2);
    draw_set_colour(make_colour_rgb(8, 26, 34));
    draw_rectangle(sx1, sy1, sx2, sy2, false);
    // di base i comandi, uno alla volta (le lettere sono larghe 11 px: poche per riga)
    var cmds = [["WASD", "ARROWS", "MOVE"], ["Z/SPACE", "ATTACK"], ["SHIFT", "SHIP", "MECHA"]];   // due schemi: WASD+SPAZIO o frecce+Z
    var msg = cmds[(current_time div 2200) mod 3];
    var alert = false;
    if (instance_exists(obj_boss) && obj_boss.hint > 0 && obj_boss.transition == 0) {
        msg = ["GOLD", "BEADS:", "PARRY"]; alert = true;
    } else if (instance_exists(obj_boss) && obj_boss.crane_hint > 0) {
        msg = ["PARRY", "TEARS", "PAPER"]; alert = true;   // i colpi parati aprono subito le gru di carta
    } else if (pl != noone && global.has_drill && pl.form == 1 && pl.drill_charge >= pl.drill_full) {
        msg = ["SHIFT", "FIRES", "DRILL"]; alert = true;
    } else if (pl != noone && pl.special > 0) {
        // ARMA SPECIALE: quale e quante munizioni restano; da mecha ricorda che serve la navicella
        var wn = (pl.special == 1) ? "ROCKETS" : ((pl.special == 2) ? "LASER" : "SPREAD");
        if (pl.form == 1) msg = [wn + ":", "SHIFT TO", "SHIP"];
        else msg = [wn, "AMMO " + string(ceil(pl.special_ammo))];
        alert = true;
    } else if (pl != noone && !global.parry_learned && pl.form == 0) {
        var py = pl.y, near = false;
        with (obj_ebullet) if (wall && y < py) near = true;
        if (near) { msg = ["PARRY:", "SHIFT", "THEN", "Z/SPACE"]; alert = true; }   // prima SHIFT, poi l'attacco
    }
    if (pl != noone && pl.heal_t > 0) { msg = ["HULL", "REPAIRED"]; alert = true; }   // cuore preso: lo scafo e' riparato
    if (game_over) { msg = ["HULL", "BREACH"]; alert = true; }
    var tc = make_colour_rgb(120, 235, 220);
    if (alert) tc = blink ? cyan_l : cyan;
    draw_set_colour(tc);
    draw_set_valign(fa_middle);
    var n = array_length(msg);
    var mcx = (sx1 + sx2) / 2, mcy = (sy1 + sy2) / 2;
    var lh = (n > 3) ? 12 : 15;   // 4 righe: un po' piu' strette, per stare nello schermo
    for (var i = 0; i < n; i++) draw_text(mcx, mcy + (i - (n - 1) / 2) * lh, msg[i]);
    // righe dello schermo e riflesso del vetro
    draw_set_alpha(0.22);
    draw_set_colour(c_black);
    for (var ly = sy1; ly < sy2; ly += 2) draw_line(sx1, ly, sx2, ly);
    draw_set_alpha(0.08);
    draw_set_colour(c_white);
    draw_rectangle(sx1, sy1, sx2, sy1 + 6, false);
    draw_set_alpha(1);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
}
