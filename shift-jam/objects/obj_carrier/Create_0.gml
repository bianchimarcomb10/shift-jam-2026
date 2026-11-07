/// PORTATRICE: piccola nave BIANCA E NERA (come la Lancia speciale) che attraversa lo schermo in alto,
/// veloce, senza sparare. Porta un'arma speciale per la navicella: abbattuta, la lascia cadere (obj_powerup).
/// Non schiva: passa una volta sola, ondeggiando, e se non la abbatti in tempo l'arma e' persa.
/// La crea obj_game con il comando ["carrier", arma, attesa]: arma 1 razzi, 2 laser, 3 ventaglio.
hp = 3;
radius = 9;
kind = 1;          // che arma porta
side = 1;          // 1 entra da sinistra, -1 da destra (lo decide obj_game)
base_y = 90;       // altezza della sua rotta
wait = 0;          // fotogrammi di attesa fuori schermo prima di entrare
t = 0;
flash = 0;         // lampo bianco quando viene colpita
last_hp = hp;
x = -100;
y = -100;

// RITIRATA: quando il tempo dell'ondata scade se ne va (la muove la Begin Step di obj_enemy)
retreat = false;
rspd = 0;
rdir = 90;
