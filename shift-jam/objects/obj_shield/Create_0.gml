/// SCUDO della nave madre (fase 1 del boss): una navetta con una lastra di energia verde davanti.
/// Non spara. Sta su un arco sotto la nave madre, fra te e lei, e si prende i tuoi colpi:
/// sparo, razzi, ventaglio, e ferma anche il laser. L'arco oscilla piano, sempre allo stesso modo:
/// i buchi fra le lastre si aprono e si chiudono a tempo. 4 s dopo che ne abbatti una, la nave madre ne rimanda un'altra.
/// Ogni colpo toglie 1, qualunque arma sia (razzo, globo del ventaglio, sparo): regge 8 colpi.
/// Abbattuta, la lastra scoppia in un anello di 6 colpi lenti (si parano). La trivella le buca senza fermarsi.
hp = 8;
radius = 15;
slot = 0;         // il suo posto sull'arco (lo da' il boss)
t = 0;            // fotogrammi da quando e' uscita dall'hangar
sx = x;           // da dove parte: l'hangar della nave madre
sy = y;
flash = 0;        // lampo bianco quando e' colpita
last_hp = hp;

// RITIRATA: quando il tempo dell'ondata scade se ne va (la muove la Begin Step di obj_enemy)
retreat = false;
rspd = 0;
rdir = 90;
