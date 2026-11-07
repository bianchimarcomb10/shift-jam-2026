/// Lancia (E02): si ferma in alto e spara mirando. Si batte con la navicella.
hp = 8;
radius = 14;   // adattato alla sprite
stop_y = random_range(60, 180);   // dove si ferma
timer = 0;
charge = 0;       // > 0 mentre l'occhio si accende (avviso)
life = 420;       // dopo 7 secondi se ne va
special = false;  // true = Lancia BIANCA E NERA: abbattuta lascia un cuore (obj_heart). La sceglie obj_game
// COME SPARA (lo sceglie obj_game, come in Ikaruga ogni disegno e' sempre uguale):
//  0 MIRA: un colpo verso di te (tre a ventaglio dall'ondata 4, cinque dalla 10)
//  1 SPIRALE: tre bracci di colpi che girano (sdir = verso)
//  2 ANELLO: un anello di 16 colpi; uno si' e uno no e' sfalsato, cosi' i varchi si spostano
//  3 PIOGGIA: una colonna dritta in giu'. Con le Lance in fila fa delle corsie che si aprono e chiudono
pat = 0;
sdir = 1;         // verso della spirale
next = 40;        // fotogrammi al prossimo avviso (disegni 1-3)
burst = 0;        // > 0 mentre spara la raffica (spirale, pioggia)
spin = 90;        // angolo del primo braccio della spirale
rings = 0;        // quanti anelli ha gia' sparato (per sfalsarli)

// RITIRATA: quando il tempo dell'ondata scade se ne va (la muove la Begin Step di obj_enemy)
retreat = false;
rspd = 0;
rdir = 90;
