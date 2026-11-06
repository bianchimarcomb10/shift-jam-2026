/// NAVE ENORME (interludio tra l'ondata 8 e la 9): una corazzata Kla'ed attraversa lo schermo
/// dall'alto in basso, lenta. Si possono spegnere le sue torrette, e si puo' anche ABBATTERE
/// colpendo lo scafo al centro, ma e' tostissima. Se non ce la fai, passa comunque e se ne va.
/// Superata la nave (torrette spente o nave abbattuta) c'e' il CHECKPOINT: se muori riparti da qui.
/// Grafica: scafo = Battlecruiser, sbarre e rastrelliere = Torpedo Ship (pacchetto Kla'ed, CC0),
/// tutto a grandezza vera e girato di 180 gradi: la prua guarda verso di te.
depth = 50;        // sopra stelle e cielo, sotto nemici, colpi e navicella
spd = 0.45;        // lentissima
retired = false;   // true quando ha passato meta' schermo: le torrette rimaste si spengono
wrecks = [];       // torrette distrutte: [dx, dy] rispetto al centro, da li' esce fumo
inert = [];        // torrette sopravvissute e spente: [bx, oy, rack]
launch_timer = 70; // conto alla rovescia fino al prossimo lancio di Falene dalla prua
launch_side = 1;   // le Falene escono una volta a destra e una a sinistra della prua
hull_hp = 110;     // lo scafo: 110 colpi normali (i colpi parati ne valgono 3). Sparando sempre allo scafo ne arrivano circa 150: e' tosta
hull_max = hull_hp;
hull_flash = 0;    // > 0 subito dopo un colpo sullo scafo
smoke1 = false;    // lo scafo ha gia' cominciato a fumare (sotto 2/3)
smoke2 = false;    // e piu' forte (sotto 1/3)
saved = false;     // checkpoint gia' salvato?
my_wave = instance_exists(obj_game) ? obj_game.wave : 9;   // l'ondata della nave: dal checkpoint si riparte dalla successiva

/// CHECKPOINT: la nave e' superata. Se muori, riparti dall'ondata dopo di lei
save_checkpoint = function() {
    if (saved) return;
    saved = true;
    global.checkpoint = max(global.checkpoint, my_wave);
    if (instance_exists(obj_game)) obj_game.cp_timer = 150;   // scritta "CHECKPOINT"
}

// due file di sbarre ai lati dello scafo (le sbarre di +-162 escono dallo schermo: la nave e' piu' grande di cio' che vedi)
rows = [32, -10];                         // altezza delle file rispetto al centro dello scafo
cols = [-162, -110, -58, 58, 110, 162];   // posizione delle sbarre

// le torrette: [x della sbarra, fila, rastrelliera (0 o 1), corazzata?]
// le due accanto allo scafo sono corazzate: lo sparo ci rimbalza, servono i colpi parati dal mecha
var tlist = [
    [-58, 32, 0, true],  [-58, 32, 1, false],
    [ 58, 32, 1, true],  [ 58, 32, 0, false],
    [-110, -10, 0, false], [-110, -10, 1, false],
    [ 110, -10, 0, false], [ 110, -10, 1, false]
];
for (var i = 0; i < array_length(tlist); i++) {
    var c = tlist[i];
    var tu = instance_create_layer(x, y, "Instances", obj_turret);
    tu.ship = id;
    tu.bx = c[0];
    tu.oy = c[1];
    tu.rack = c[2];
    tu.armored = c[3];
    tu.hp = c[3] ? 4 : 10;          // corazzata: 4 colpi parati; normale: 10 colpi
    tu.timer = 40 + i * 23;         // non sparano tutte insieme
}
