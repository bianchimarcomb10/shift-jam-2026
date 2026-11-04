/// Il pilota: navicella (forma 0) o mecha (forma 1).
form = 0;               // 0 = navicella, 1 = mecha
transform_timer = 0;    // > 0 durante la trasformazione
switch_cooldown = 0;    // tempo minimo tra due SHIFT
fire_cooldown = 0;      // ritmo dello sparo
sweep_cooldown = 0;     // ritmo della falciata
sweep_anim = 0;         // per quanti frame si disegna la falciata
invuln = 0;             // invulnerabilita' dopo un colpo
parry_radius = 72;      // la falciata annulla i proiettili un po' oltre la lama
sparks = [];            // scintille dei proiettili annullati: [x, y, vita]

// Valori del GDD (sezione 4), da tarare provando
ship_speed = 4;         // px per frame
mech_speed = 2.5;
sweep_radius = 56;      // raggio della falciata
