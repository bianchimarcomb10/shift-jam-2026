/// Il Custode (boss): teschio, mala di 108 grani, mani giunte. Versione grigia, una sola fase.
/// E' figlio di obj_enemy: colpi, falciata e contatto funzionano come con gli altri nemici.
hp = 150;
hp_max = hp;
radius = 28;
target_y = 150;     // dove si ferma dopo l'entrata
t = 0;
bead_angle = 0;     // rotazione della mala
hands_gap = 12;     // distanza tra le mani: si chiudono prima dell'attacco
attack = 0;         // 0 = mala (anello di proiettili), 1 = mani (ventaglio mirato)
attack_timer = 90;
