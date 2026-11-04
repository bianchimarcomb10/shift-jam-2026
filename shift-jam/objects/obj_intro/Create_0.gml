/// Sequenza d'apertura: titolo, la frase di Linji, le stelle che riempiono lo schermo.
game_title = "SHIFT INTO\nSILENCE";   // su due righe: a grandezza 3 non entra in una
state = 0;   // 0 titolo, 1 dissolvenza al nero, 2 frase, 3 "Press SHIFT", 4 stelle fino al bianco
t = 0;       // frame passati nello stato attuale
stars = [];  // stelle accese: [x, y, fotogramma in cui si accendono]
cells = [];  // posti dove si accenderanno (una per quadratino di griglia, in ordine casuale)
next_cell = 0;
star_grow = 60;   // fotogrammi perche' una stella arrivi alla grandezza piena
star_max_r = 18;  // raggio pieno: copre tutto il suo quadratino, cosi' alla fine non resta nero
audio_master_gain(0.4);   // volume generale: i suoni erano troppo alti
