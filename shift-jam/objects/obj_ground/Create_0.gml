/// Prologo a terra: il mecha resiste finche' gli alieni non lo sommergono.
state = 0;          // 0 = combatte, 1 = sommerso (aspetta SHIFT), 2 = lampo, 3 = volo
bar = 0;            // accerchiamento: da 0 (libero) a 1 (sommerso)
t = 0;              // frame passati nello stato attuale
spawn_timer = 30;
spawn_interval = 45;   // frame tra un gruppo e l'altro: scende col tempo
flash = 0;
mass = false;       // true durante l'ondata finale: alieni ovunque, niente piu' attacco
free_time = 600;    // primi 10 secondi (600 frame): il mecha si muove libero
mass_time = 1500;   // a 25 secondi parte comunque l'ondata finale
ground_y = room_height - 70;   // il terreno: il mecha cammina qui sopra, non vola
scroll = 0;         // quanto il terreno e' sceso sotto lo schermo durante il volo
depth = 100;        // le rovine si disegnano sotto a tutto il resto

// rovine provvisorie: rettangoli scuri in posizioni casuali
ruins = [];
for (var i = 0; i < 10; i++) {
    ruins[i] = [random(room_width), random_range(40, room_height - 120), random_range(14, 44), random_range(10, 34)];
}

instance_create_layer(room_width / 2, ground_y, "Instances", obj_mech_ground);
