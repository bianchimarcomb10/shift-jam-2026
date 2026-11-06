/// Colpo della navicella. Se e' un colpo PARATO (lo crea la falciata del mecha) obj_player cambia questi valori.
parried = false;   // true = colpo nemico parato e rimandato indietro
hd = 90;           // direzione in cui vola (solo per i colpi parati)
v = 3;             // velocita' (solo per i colpi parati: cresce)
tgt = noone;       // il nemico che insegue
life = 0;          // fotogrammi di vita
trail = [];        // ultime posizioni, per la scia che segue la curva
