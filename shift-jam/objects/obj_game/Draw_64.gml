/// Interfaccia provvisoria: vita, forma attuale, comandi.
if (finale) exit;   // nel finale lo schermo resta vuoto
draw_set_colour(c_white);
draw_set_halign(fa_left);
// il sutra della ripartenza: entra e sfuma, al centro dello schermo
if (sutra_timer > 0 && sutra >= 0) {
    var sa = clamp(min((300 - sutra_timer) / 45, sutra_timer / 60), 0, 1);
    var gw = display_get_gui_width();
    draw_set_alpha(sa);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_ext(gw / 2, room_height / 2 - 30, sutras[sutra][0], 16, gw - 48);
    draw_text(gw / 2, room_height / 2 + 50, sutras[sutra][1]);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
// CHECKPOINT: la nave enorme e' superata. La scritta entra, resta un attimo e sfuma
if (cp_timer > 0) {
    draw_set_halign(fa_center);
    draw_set_alpha(min(1, cp_timer / 40));
    draw_set_colour(make_colour_rgb(110, 190, 255));
    draw_text_transformed(display_get_gui_width() / 2, 120, "CHECKPOINT", 2, 2, 0);
    draw_set_colour(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
}
draw_text(8, 8, "HP: " + string(global.hp));
if (instance_exists(obj_player)) {
    draw_text(8, 24, "FORM: " + ((obj_player.form == 0) ? "SHIP" : "MECHA"));
}
// comandi su due righe, centrati: su una riga sola uscivano dallo schermo
draw_set_halign(fa_center);
draw_text(display_get_gui_width() / 2, room_height - 36, "WASD/ARROWS: MOVE");
draw_text(display_get_gui_width() / 2, room_height - 20, "Z: ATTACK   SHIFT: FORM");
draw_set_halign(fa_left);

// AVVISO DELLA PARATA: arriva un muro e sei navicella -> "SHIFT + Z TO PARRY",
// sempre piu' grande man mano che i colpi si avvicinano. Sparisce appena diventi mecha,
// e non torna piu' dopo che hai parato un muro almeno una volta (global.parry_learned).
if (!global.parry_learned && !game_over && instance_exists(obj_player) && obj_player.form == 0) {
    var py = obj_player.y;
    var near = -1;   // il colpo del muro piu' in basso, ma ancora sopra di te
    with (obj_ebullet) if (wall && y < py) near = max(near, y);
    if (near >= 0) {
        var gw = display_get_gui_width();
        var c = clamp((near - 26) / max(1, py - 60), 0, 1);           // 0 = muro appena posato, 1 = addosso
        var s = lerp(1.5, (gw - 28) / string_width("SHIFT + Z"), c);  // al massimo largo quanto lo schermo
        var sh = c * 2;                                               // trema quando e' vicino
        var tx = gw / 2 + random_range(-sh, sh), ty = room_height * 0.55 + random_range(-sh, sh);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(c_black);   // ombra, per leggerlo sopra i colpi
        draw_text_transformed(tx + s, ty + s, "SHIFT + Z\nTO PARRY", s, s, 0);
        // bianco e azzurro: lo stesso azzurro dei colpi parati
        draw_set_colour(((current_time div 250) mod 2 == 0) ? c_white : make_colour_rgb(110, 190, 255));
        draw_text_transformed(tx, ty, "SHIFT + Z\nTO PARRY", s, s, 0);
        draw_set_colour(c_white);
        draw_set_valign(fa_top);
        draw_set_halign(fa_left);
    }
}

// TRIVELLA: carica piena e sei mecha -> ricorda come lanciarla
if (!game_over && instance_exists(obj_player) && global.has_drill && obj_player.form == 1 && obj_player.drill_charge >= 3) {
    draw_set_halign(fa_center);
    draw_set_colour(((current_time div 250) mod 2 == 0) ? c_white : make_colour_rgb(110, 190, 255));
    draw_text(display_get_gui_width() / 2, room_height - 76, "SHIFT: LAUNCH THE DRILL");
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
}
// le due frasi enormi: la trivella presa, l'arrivo del boss
if (drill_phrase > 0) global.big_phrase("YOUR DRILL\nIS THE DRILL\nTHAT WILL\nPIERCE\nTHE HEAVENS!", drill_phrase, 270, make_colour_rgb(110, 190, 255));
if (boss_phrase > 0) global.big_phrase("WHO THE HELL\nDO YOU THINK\nI AM?!", boss_phrase, 240, make_colour_rgb(230, 190, 90));

if (game_over) {
    // enorme, lampeggiante: l'unica cosa da fare e' rialzarsi
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var pulse = (display_get_gui_width() - 28) / string_width("STRUGGLE") * (0.95 + 0.04 * dsin(current_time * 0.4));
    if ((current_time div 400) mod 2 == 0) draw_set_colour(c_white); else draw_set_colour(make_colour_rgb(255, 80, 160));
    draw_text_transformed(room_width / 2, room_height / 2, "SHIFT\nTO\nSTRUGGLE", pulse, pulse, 0);
    draw_set_colour(c_white);
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}
