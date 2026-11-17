if (flash > 0) {
    draw_set_alpha(flash);
    draw_set_colour(c_white);
    draw_rectangle(0, 0, room_width, room_height, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var cx = room_width / 2;
var cy = room_height / 2 + 60;   // sotto il punto dove la navicella sparisce

// le RINASCITE (Chelios, 17-11): quante volte sei ripartito dopo un game over (global.continues).
// Una riga sola, mentre la navicella comincia a salire, prima della poesia: da 3 a 8 s, i tempi del finale non cambiano.
// In alto, dove la navicella non e' ancora arrivata
var a_r = clamp(min((t - 180) / 60, (480 - t) / 60), 0, 1);
if (a_r > 0) {
    var rn = global.continues;
    var rtxt = (rn == 0) ? "Never reborn." : ((rn == 1) ? "Reborn once." : "Reborn " + string(rn) + " times.");
    draw_set_alpha(a_r);
    draw_text(cx, room_height / 2 - 90, rtxt);
}

// poesia di Ryokan: compare in 1 s, resta, svanisce in 1 s
var a_poem = clamp(min((t - 600) / 60, (1200 - t) / 60), 0, 1);
if (a_poem > 0) {
    draw_set_alpha(a_poem);
    draw_text(cx, cy - 48, "\"You must rise above");
    draw_text(cx, cy - 32, "The gloomy clouds");
    draw_text(cx, cy - 16, "Covering the mountaintop");
    draw_text(cx, cy,      "Otherwise, how will you");
    draw_text(cx, cy + 16, "Ever see the brightness?\"");
    draw_text(cx, cy + 48, "- Ryokan Taigu");
}

// poi i titoli di coda, quattro cartelli: compaiono in 1 s, restano, svaniscono in 1 s
// (fnt_main: 11 px a lettera, quindi al massimo 32 lettere per riga)
// 1) l'autore
var a1 = clamp(min((t - 1230) / 60, (1500 - t) / 60), 0, 1);
if (a1 > 0) {
    draw_set_alpha(a1);
    draw_text(cx, cy - 10, "A game by Marco Bianchi");
    draw_text(cx, cy + 10, "(Chelios)");
}
// 2) il mecha e la musica
var a2 = clamp(min((t - 1560) / 60, (1860 - t) / 60), 0, 1);
if (a2 > 0) {
    draw_set_alpha(a2);
    draw_text(cx, cy - 52, "Mecha design by");
    draw_text(cx, cy - 34, "Francesco \"Rocketbird\" Passero");
    draw_text(cx, cy + 4, "Music by");
    draw_text(cx, cy + 22, "Emanuele Luigi Andolfi");
    draw_text(cx, cy + 40, "(CUBESANDO)");
}
// 3) il grazie ai playtester
var a3 = clamp(min((t - 1920) / 60, (2220 - t) / 60), 0, 1);
if (a3 > 0) {
    draw_set_alpha(a3);
    draw_text(cx, cy - 32, "Thank you");
    draw_text(cx, cy - 8, "to all the playtesters");
    draw_text(cx, cy + 8, "who helped me with");
    draw_text(cx, cy + 24, "my very first game.");
}
// 4) la dedica: compare per ultima e resta fino al buio
var a4 = clamp((t - 2280) / 60, 0, 1);
if (a4 > 0) {
    draw_set_alpha(a4);
    draw_text(cx, cy - 32, "Dedicated to");
    draw_text(cx, cy - 14, "my beloved Ginevra,");
    draw_text(cx, cy + 10, "without whom I would");
    draw_text(cx, cy + 28, "do nothing in life.");
}
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
}
draw_set_alpha(1);
