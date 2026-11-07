var ox = 0;
var oy = 0;
if (obj_ground.state == 1 || obj_ground.mass) {   // sommerso: il mecha trema
    ox = irandom_range(-2, 2);
    oy = irandom_range(-2, 2);
}

// --- Il PELLEGRINO (scr_pilgrim): navicella e mecha sono gli stessi pezzi ---
// m = 1 mecha; dopo SHIFT scende a 0 mentre si apre in navicella
var m = 1 - unfold;

// in virata si piega come la navicella (stessa formula di obj_player)
tilt += (clamp(x - xprevious, -4, 4) * 4 - tilt) * 0.2;
var cx = x + ox, cy = y + oy;

// l'ensō azzurro del cambio mentre si riapre in navicella
var flash = (transformed && unfold < 1) ? 1 - unfold : 0;
// a terra il mecha sta in GUARDIA (pose 0): falce in diagonale a due mani, gambe che camminano quando si muove
var walk = min(1, point_distance(x, y, xprevious, yprevious) / max(0.1, mech_speed));
if (unfold < 1) {
    draw_pilgrim(cx, cy, m, tilt, transformed ? 0 : sweep_anim, sweep_radius, flash, mech_scale, true, 1, 1, 0, walk);
} else {
    draw_pilgrim(x, y, 0, 0, 0, sweep_radius, 0, mech_scale, true, 1.4);   // decolla: fiamma lunga
}
