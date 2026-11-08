/// Inseguitore: entra di lato nella sua corsia, si mette al suo posto e ondeggia a otto scendendo piano;
/// ti "insegue" con i colpi, sempre mirati a te. Il percorso e' sempre lo stesso (si impara a memoria)
/// e non incrocia gli altri nemici.
/// Regge piu' colpi di una Falena: conviene la navicella da lontano, o il mecha se ti arriva addosso.
hp = 5;
radius = 11;   // adattato alla sprite
spd = 0.7;
fire_timer = irandom_range(60, 120);
wait = 0;      // fotogrammi di attesa fuori schermo (obj_game lo usa per farli entrare dopo le Falene)
stay = 420;       // dopo 7 secondi sullo schermo smette di sparare e se ne va
leaving = false;
ldir = 90;        // direzione di fuga
lspd = 0;
face = 270;       // dove guarda (la aggiorna il Draw)
side = 1;         // 1 entra da sinistra, -1 da destra (deciso dalla x di partenza)
lane_y = 0;       // la sua corsia
t = 0;            // fotogrammi da quando e' entrato
pat = 0;          // 0 un colpo mirato; 1 CORDA: 4 colpi in fila verso di te (lo sceglie obj_game)

// RITIRATA: quando il tempo dell'ondata scade se ne va (la muove la Begin Step di obj_enemy)
retreat = false;
rspd = 0;
rdir = 90;
