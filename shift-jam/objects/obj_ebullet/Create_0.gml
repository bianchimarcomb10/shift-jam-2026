/// Proiettile nemico: lento, colore riservato (magenta). Si disegna con global.draw_ebullet.
dir = 270;
spd = 2.5;
hold = 0;     // fotogrammi di attesa prima di muoversi (i colpi posati dalle fregate)
// solo per i colpi dei muri (li imposta obj_frigate):
wall = false; // fa parte di un muro?
wph = 0;      // fase dell'onda: dipende da quanto e' lontano dal centro dello schermo
woff = 0;     // spostamento dell'onda nel fotogramma prima
wamp = 4;     // altezza dell'onda
wv = 0;       // velocita' attuale: il muro parte piano e accelera
