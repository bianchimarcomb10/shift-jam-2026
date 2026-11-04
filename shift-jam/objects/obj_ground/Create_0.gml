/// Prologo a terra: il mecha resiste finche' gli alieni non lo sommergono.
state = 0;          // 0 = combatte, 1 = sommerso (aspetta SHIFT), 2 = lampo, 3 = decollo
bar = 0;            // accerchiamento: da 0 (libero) a 1 (sommerso)
t = 0;              // frame passati nello stato attuale
spawn_timer = 30;
spawn_interval = 45;   // frame tra un gruppo e l'altro: scende col tempo
flash = 0;
depth = 100;        // le rovine si disegnano sotto a tutto il resto

// rovine provvisorie: rettangoli scuri in posizioni casuali
ruins = [];
for (var i = 0; i < 10; i++) {
    ruins[i] = [random(room_width), random_range(40, room_height - 20), random_range(14, 44), random_range(10, 34)];
}

instance_create_layer(room_width / 2, room_height * 0.6, "Instances", obj_mech_ground);
