if (wall) {
    // MURO VIVO: un'increspatura parte dal centro e corre verso i bordi, come un sasso nell'acqua.
    // Quando il muro cade l'onda si allarga un po'.
    wamp += (((hold > 0) ? 4 : 8) - wamp) * 0.05;
    var off = wamp * dsin((current_time - global.pause_ms) * 0.25 - wph);   // senza il tempo della pausa (scr_pause)
    y += off - woff;
    woff = off;
}
if (hold > 0) { hold -= 1; exit; }   // fermo in fila, aspetta che partano tutti
var v = spd;
if (wall) { wv = min(spd, wv + spd / 40); v = wv; }   // il muro prende velocita' piano, come un respiro
x += lengthdir_x(v, dir);
y += lengthdir_y(v, dir);
if (y < -20 || y > room_height + 20 || x < -20 || x > room_width + 20) instance_destroy();
