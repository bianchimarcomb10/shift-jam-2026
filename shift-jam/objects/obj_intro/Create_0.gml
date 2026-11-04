/// Sequenza d'apertura: titolo, la frase di Linji, le stelle che riempiono lo schermo.
game_title = "TITLE";   // titolo provvisorio: da cambiare quando e' deciso
state = 0;   // 0 titolo, 1 dissolvenza al nero, 2 frase, 3 "Press SHIFT", 4 stelle fino al bianco
t = 0;       // frame passati nello stato attuale
stars = [];
