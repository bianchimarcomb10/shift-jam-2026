/// GRU DI CARTA (fase 2 del boss): origami d'oro. Ogni 10 s uno stormo arriva dai due lati
/// e fa muro sotto i Koi, fra te e la perla. Non sparano: si prendono i tuoi colpi
/// (sparo, razzi, ventaglio, e fermano anche il laser). Quando una cade, le altre si stringono
/// e chiudono il buco; il muro scivola piano a destra e a sinistra, sempre allo stesso modo.
/// Ogni colpo toglie 1, qualunque arma sia: reggono 4 colpi. Ma un colpo PARATO le apre subito:
/// la carta non regge i colpi rimandati.
/// La trivella le buca senza fermarsi. Dopo 5,5 s se ne vanno verso l'alto.
hp = 4;
radius = 13;
slot = 0;          // il suo posto nello stormo, da sinistra (lo da' il boss)
side = 1;          // 1 arriva da sinistra, -1 da destra
delay = 0;         // fotogrammi di attesa prima di partire
t = 0;
arrive = 70;       // quanto ci mette ad arrivare al muro
hold = 330;        // quanto resta nel muro (5,5 s)
x0 = x;            // da dove parte
y0 = y;
lv = 0;            // velocita' quando se ne va
look = 1;          // di profilo: 1 guarda a destra, -1 a sinistra (nel muro guardano verso il centro)
tilt = 0;          // il muso si alza quando sale
hover = 0;         // 1 = ferma nel muro: ali alte
flap = 0;          // battito delle ali
flash = 0;
last_hp = hp;

// RITIRATA: quando il tempo dell'ondata scade se ne va (la muove la Begin Step di obj_enemy)
retreat = false;
rspd = 0;
rdir = 90;
