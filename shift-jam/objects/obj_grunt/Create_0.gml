/// Alieno di terra: cammina verso il mecha e ci si aggrappa.
spd = random_range(0.5, 0.9);
cling_dist = random_range(14, 26);   // a che distanza si ferma (cosi' si ammucchiano)
clinging_now = false;
face = 270;   // direzione in cui guarda (verso il mecha)
fling = false;   // true quando l'esplosione lo scaglia via
fvx = 0;
fvy = 0;
spin = 0;
anim = random(360);   // fase della camminata: ognuno muove le chele per conto suo
if (obj_ground.mass) {
    // ondata finale: piu' veloci, e si fermano ovunque fino a coprire lo schermo
    spd = random_range(1.5, 2.5);
    cling_dist = random_range(12, 320);
}
