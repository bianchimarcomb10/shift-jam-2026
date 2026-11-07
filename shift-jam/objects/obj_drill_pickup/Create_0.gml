/// La TRIVELLA che arriva prima del boss finale (la crea obj_game, 2 s dopo la fine delle ondate).
/// Arriva ENORME dal MANICO, con la punta in alto (come la terra' il mecha), e in 3 secondi esatti
/// piomba sul mecha e gli si pianta in mano: da li' e' la sua arma. Non va presa: arriva sempre,
/// cosi' la sequenza dura sempre uguale (15 s). (x, y) e' il centro della BASE (il manico).
t = 0;              // fotogrammi da quando e' comparsa
dur = 180;          // dopo 3 secondi si pianta
hover = 90;         // per 1,5 s scende piano, enorme, sopra di te; poi piomba
sc = 8;             // grandezza (8 = enorme, 1 = quella in mano al mecha)
sc_end = 1;          // alla fine e' grande quanto quella in mano al mecha: il passaggio non si vede
ph = 0;             // rotazione della spirale
hx = x;             // dove si trova quando smette di scendere piano e comincia a piombare
hy = 0;
planted = false;
boom = 0;           // fotogrammi dall'impatto (anello e lampo)
depth = -4;
