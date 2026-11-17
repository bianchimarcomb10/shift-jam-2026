/// Sequenza d'apertura: titolo, la frase di Linji, le stelle che riempiono lo schermo.
game_title = "SHIFT INTO\nSILENCE";   // su due righe: a grandezza 3 non entra in una
state = 0;   // 0 titolo, 1 dissolvenza al nero, 2 frase, 3 "Press SHIFT", 4 stelle fino al bianco
t = 0;       // frame passati nello stato attuale
stars = [];  // stelle accese: [x, y, fotogramma in cui si accendono]
cells = [];  // posti dove si accenderanno (una per quadratino di griglia, in ordine casuale)
next_cell = 0;
star_grow = 90;   // fotogrammi perche' una stella arrivi alla grandezza piena
star_max_r = 18;  // raggio pieno: copre tutto il suo quadratino, cosi' alla fine non resta nero
master_gain_apply();   // volume generale (scr_pause: GAME_MASTER di scr_music, o zero se hai premuto M): resta questo fino alla fine; gli effetti per SFX_GAIN
// "Mood Intenso" di Cubesando: da capo, poi in loop finche' non si va avanti (TITLE_LOOP_START/END in scr_music);
// sfuma nell'esplosione di stelle (Step, stato 3 -> 4)
music_play(MUSIC_TITLE, 0, 0, true);
// la versione non si vede piu' nel gioco (va su itch.io): si legge solo nella finestra Output di GameMaker
show_debug_message("SHIFT INTO SILENCE - BUILD " + BUILD);
draw_set_font(fnt_main);   // Press Start 2P per tutte le scritte
