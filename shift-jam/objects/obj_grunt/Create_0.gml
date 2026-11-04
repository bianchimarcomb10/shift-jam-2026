/// Alieno di terra: cammina verso il mecha e ci si aggrappa.
spd = random_range(0.5, 0.9);
cling_dist = random_range(12, 22);   // a che distanza si ferma (cosi' si ammucchiano)
clinging_now = false;
if (obj_ground.mass) {
    // ondata finale: piu' veloci, e si fermano ovunque fino a coprire lo schermo
    spd = random_range(1.5, 2.5);
    cling_dist = random_range(12, 320);
}
