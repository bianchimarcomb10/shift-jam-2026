// colpita: lampo bianco
if (hp < last_hp) flash = 4;
last_hp = hp;
if (flash > 0) flash -= 1;

if (retreat) exit;   // tempo dell'ondata scaduto: la ritirata la fa obj_enemy (Begin Step)

if (wait > 0) { wait -= 1; y = -70; exit; }   // aspetta fuori schermo
t += 1;
// DOVE MIRA: sempre gli stessi punti, si imparano (prima ti seguiva e finiva addosso agli altri nemici).
// Da sola: prima raffica da sinistra verso il centro, seconda da destra verso il centro.
// In coppia (gabbia): prima i raggi partono dai bordi e si stringono, poi partono stretti e si allargano
var tx, sdir;
if (offs == 0) { tx = (cycles == 0) ? 110 : 250; sdir = (cycles == 0) ? 1 : -1; }
else {
    var sd = sign(offs);
    tx = room_width / 2 + sd * ((cycles == 0) ? 110 : 50);
    sdir = (cycles == 0) ? -sd : sd;
}
switch (state) {
    case 0: // entra dall'alto e si ferma
        y = min(y + 1.6, stop_y);
        if (y >= stop_y) { state = 1; t = 0; }
        break;
    case 1: // si mette in posizione
        x += clamp(tx - x, -1.6, 1.6);
        if (t >= 50) { state = 2; t = 0; }
        break;
    case 2: // carica: si blocca, i motori si aprono, una linea sottile avvisa dove passera' il raggio
        open = min(3, open + 0.1);
        if (t >= 60) { state = 3; t = 0; }
        break;
    case 3: // SPARA: il raggio si accende e scivola piano, sempre nello stesso verso
        beam_w = min(11, beam_w + 2);
        x += 0.35 * sdir;
        if (t >= 150) { state = 4; t = 0; }
        break;
    case 4: // si spegne e si raffredda
        beam_w = max(0, beam_w - 1.5);
        open = max(0, open - 0.08);
        if (t >= 50) {
            cycles += 1;
            state = (cycles >= 2) ? 5 : 1;   // due raffiche, poi basta
            t = 0;
        }
        break;
    case 5: // se ne va verso l'alto, accelerando
        lspd = min(lspd + 0.08, 4);
        y -= lspd;
        if (y < -70) instance_destroy();
        break;
}
x = clamp(x, 40, room_width - 40);
