// colpita: lampo bianco
if (hp < last_hp) flash = 4;
last_hp = hp;
if (flash > 0) flash -= 1;

if (retreat) exit;   // tempo dell'ondata scaduto: la ritirata la fa obj_enemy (Begin Step)

if (wait > 0) { wait -= 1; y = -70; exit; }   // aspetta fuori schermo
t += 1;
var tx = instance_exists(obj_player) ? obj_player.x + offs : x;   // dove vuole mettersi
switch (state) {
    case 0: // entra dall'alto e si ferma
        y = min(y + 1.6, stop_y);
        if (y >= stop_y) { state = 1; t = 0; }
        break;
    case 1: // mira: scivola sopra di te
        x += clamp(tx - x, -1.2, 1.2);
        if (t >= 50) { state = 2; t = 0; }
        break;
    case 2: // carica: si blocca, i motori si aprono, una linea sottile avvisa dove passera' il raggio
        open = min(3, open + 0.1);
        if (t >= 60) { state = 3; t = 0; }
        break;
    case 3: // SPARA: il raggio si accende e ti insegue, piano
        beam_w = min(11, beam_w + 2);
        x += clamp(tx - x, -0.35, 0.35);
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
