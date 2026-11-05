/// Prologo a terra: il mecha resiste finche' gli alieni non lo sommergono.
audio_master_gain(0.4);   // torna il volume normale dopo l'apertura
global.continues = 0;     // nuova partita: si riparte da zero sconfitte
state = 0;          // 0 = combatte, 1 = sommerso (aspetta SHIFT), 2 = esplosione, 3 = la navicella vola via
bar = 0;            // accerchiamento: da 0 (libero) a 1 (sommerso)
t = 0;              // frame passati nello stato attuale
spawn_timer = 30;
spawn_interval = 30;   // frame tra un gruppo e l'altro: scende col tempo
flash = 1;          // si parte dal bianco della sequenza d'apertura
mass = false;       // true durante l'ondata finale: alieni ovunque, niente piu' attacco
free_time = 360;    // primi 6 secondi (360 frame): il mecha si muove libero
mass_time = 900;    // a 15 secondi parte comunque l'ondata finale
ground_y = room_height - 70;   // dove si disegna il terreno provvisorio
scroll = 0;         // di quanto scende il terreno mentre la navicella decolla
boom_x = 0;
boom_y = 0;
cells = [];         // esplosione a stelle: i punti dello schermo, dal centro verso fuori
stars = [];         // [x, y, fotogramma in cui nasce]
next_cell = 0;
star_grow = 40;     // fotogrammi per crescere: piu' rapida dell'intro, e' un'esplosione
star_max_r = 18;
depth = 100;        // le rovine si disegnano sotto a tutto il resto
// Se nella room c'e' un livello chiamato "Ground" (tile o asset disegnati a mano),
// il cielo e le rovine provvisorie non servono piu': questo oggetto disegna solo l'esplosione, sopra a tutto.
ground_layer = layer_get_id("Ground");
if (ground_layer != -1) depth = -10;
// Il terreno puo' essere piu' alto dello schermo: si vede la parte in fondo, e al decollo
// scendendo mostra quella sopra, senza mai finire. Se il livello e' un Background con uno sprite,
// lo allineo da solo in modo che il bordo inferiore dello sprite coincida col fondo della room.
ground_base = 0;
if (ground_layer != -1) {
    ground_base = layer_get_y(ground_layer);
    var bg = layer_background_get_id(ground_layer);
    if (bg != -1) {
        var bspr = layer_background_get_sprite(bg);
        if (bspr != -1) {
            ground_base = room_height - sprite_get_height(bspr);
            layer_y(ground_layer, ground_base);
        }
    }
}

// rovine provvisorie: rettangoli scuri in posizioni casuali
ruins = [];
for (var i = 0; i < 10; i++) {
    ruins[i] = [random(room_width), random_range(40, room_height - 120), random_range(14, 44), random_range(10, 34)];
}

instance_create_layer(room_width / 2, room_height * 0.6, "Instances", obj_mech_ground);
