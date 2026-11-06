// sfera di energia magenta (disegnata da global.draw_ebullet, in obj_game Create).
// i colpi fermi in fila (posati dalle fregate) non hanno scia e tremolano un po' piu' veloci, come in attesa
var ph = current_time * 0.6 + id * 47;
if (hold > 0) global.draw_ebullet(x, y, dir, 0, ph * 2);
else global.draw_ebullet(x, y, dir, spd, ph);
