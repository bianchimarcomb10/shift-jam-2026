/// Falena (E01): piccola, a sciami. Si batte col mecha.
/// Due modi di volare:
///  form = 0  -> libera: curva lenta verso il giocatore (anche dopo una picchiata)
///  form > 0  -> in formazione: segue un disegno geometrico deciso da obj_game
hp = 1;
radius = 10;   // adattato alla sprite
spd = 2.2;
dir = 270;     // 270 = verso il basso

// dati della formazione (obj_game li sovrascrive subito dopo averla creata)
form = 0;      // 1 serpente, 2 V, 3 anello, 4 tenaglia, 5 corridoio laterale
idx = 0;       // posto nella formazione
n = 1;         // quante falene nella formazione
cx = room_width / 2;   // centro orizzontale del disegno
amp = 100;     // ampiezza (serpente)
side = 1;      // 1 da sinistra, -1 da destra (tenaglia)
delay = 0;     // fotogrammi di attesa prima di entrare
base_y = 260;  // altezza del corridoio laterale
t = 0;

// alcune falene sparano un colpo mirato mentre sono in formazione
can_shoot = false;
fire_timer = irandom_range(60, 200);
