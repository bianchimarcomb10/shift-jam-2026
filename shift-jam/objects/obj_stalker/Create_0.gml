/// Inseguitore (nuovo nemico): si avvicina lentamente a te e ogni tanto spara un colpo mirato.
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
