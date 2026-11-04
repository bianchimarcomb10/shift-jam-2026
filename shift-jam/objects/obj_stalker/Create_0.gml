/// Inseguitore (nuovo nemico): si avvicina lentamente a te e ogni tanto spara un colpo mirato.
/// Regge piu' colpi di una Falena: conviene la navicella da lontano, o il mecha se ti arriva addosso.
hp = 5;
radius = 11;   // adattato alla sprite
spd = 0.7;
fire_timer = irandom_range(60, 120);
wait = 0;      // fotogrammi di attesa fuori schermo (obj_game lo usa per farli entrare dopo le Falene)
