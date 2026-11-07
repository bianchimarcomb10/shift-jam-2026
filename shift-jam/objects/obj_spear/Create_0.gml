/// Lancia (E02): si ferma in alto e spara mirando. Si batte con la navicella.
hp = 8;
radius = 14;   // adattato alla sprite
stop_y = random_range(60, 180);   // dove si ferma
timer = 0;
charge = 0;       // > 0 mentre l'occhio si accende (avviso)
life = 420;       // dopo 7 secondi se ne va
special = false;  // true = Lancia BIANCA E NERA: abbattuta lascia un cuore (obj_heart). La sceglie obj_game
