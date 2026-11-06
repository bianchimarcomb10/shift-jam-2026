/// Fregata: scende in picchiata al centro, vira verso il suo lato e semina il muro di colpi,
/// poi al bordo cabra e sparisce verso l'alto. Cosi' le due fregate non si incrociano mai.
/// Non si puo' colpire e non conta come nemico. obj_game (spawn_wall) ne manda due insieme.
side = 1;        // 1 va verso destra, -1 verso sinistra
spd = 4;
slots = [];      // le x dove posare i colpi, dal centro verso il bordo (le sceglie obj_game)
k = 0;           // prossimo colpo da posare
total = 0;       // fotogrammi dopo cui tutti i colpi partono insieme
bspd = 1.5;      // velocita' dei colpi quando partono
t = 0;
phase = 0;       // 0 picchiata, 1 virata, 2 posa il muro, 3 cabrata verso l'alto
hd = 270;        // direzione in cui vola (270 = giu')
row_y = 26;      // altezza del muro
