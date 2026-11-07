/// Begin Step, ereditato da tutti i nemici: la RITIRATA.
/// Quando il tempo di un'ondata scade, obj_game (retreat_all) mette retreat = true ai nemici rimasti:
/// smettono di combattere e se ne vanno accelerando verso il bordo piu' vicino (rdir 90 su, 270 giu').
/// Nel loro Step c'e' "if (retreat) exit;": da qui in poi li muove solo questo.
/// Mentre si ritirano non fanno male a toccarli, ma si possono ancora abbattere.
if (!retreat) exit;
rspd = min(rspd + 0.15, 6);
y += lengthdir_y(rspd, rdir);
if (object_index == obj_laser) {
    beam_w = max(0, beam_w - 2);   // il raggio si spegne
    open = max(0, open - 0.1);
}
if (object_index == obj_moth) dir = rdir;   // la falena si gira e scappa (la sprite guarda dove vola)
if (y < -80 || y > room_height + 80 || x < -60 || x > room_width + 60) instance_destroy();
