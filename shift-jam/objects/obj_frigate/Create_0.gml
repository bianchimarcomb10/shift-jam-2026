/// Fregata: attraversa veloce la parte alta dello schermo e semina il muro di colpi.
/// Non si puo' colpire e non conta come nemico: passa, posa i colpi e sparisce.
/// obj_game (spawn_wall) ne manda due insieme, una da sinistra e una da destra.
side = 1;        // 1 entra da sinistra, -1 da destra
spd = 6;         // velocissima: si vede appena
slots = [];      // le x dove posare i colpi (le sceglie obj_game)
k = 0;           // prossimo colpo da posare
total = 0;       // fotogrammi dopo cui tutti i colpi partono insieme
bspd = 1.5;      // velocita' dei colpi quando partono
t = 0;
