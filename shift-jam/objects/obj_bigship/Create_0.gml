/// NAVE ENORME (interludio tra l'ondata 8 e la 9): una corazzata Kla'ed attraversa lo schermo
/// dall'alto in basso, lenta e indifferente. Non si puo' distruggere: si possono solo spegnere
/// le sue torrette. Se non le distruggi, passa comunque e se ne va.
/// Grafica: scafo = Battlecruiser, sbarre e rastrelliere = Torpedo Ship (pacchetto Kla'ed, CC0),
/// tutto a grandezza vera e girato di 180 gradi: la prua guarda verso di te.
depth = 50;        // sopra stelle e cielo, sotto nemici, colpi e navicella
spd = 0.45;        // lentissima
retired = false;   // true quando ha passato meta' schermo: le torrette rimaste si spengono
wrecks = [];       // torrette distrutte: [dx, dy] rispetto al centro, da li' esce fumo
inert = [];        // torrette sopravvissute e spente: [bx, oy, rack]

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
