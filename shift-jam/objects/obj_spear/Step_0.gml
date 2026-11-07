if (retreat) exit;   // tempo dell'ondata scaduto: la ritirata la fa obj_enemy (Begin Step)
life -= 1;
if (life <= 0) {
    y -= 3;
    if (y < -40) instance_destroy();
    exit;
}
if (y < stop_y) { y += 2; exit; }

timer += 1;
if (pat > 0) {
    // ---- DISEGNI: mezzo secondo di avviso (charge, si vede nel Draw), poi la raffica ----
    var period = (pat == 1) ? 170 : ((pat == 2) ? 110 : 150);
    var blen = (pat == 1) ? 90 : ((pat == 2) ? 1 : 80);   // quanto dura la raffica
    if (charge == 0 && burst == 0) {
        next -= 1;
        if (next <= 0) { charge = 30; next = period - 30; }
    }
    if (charge > 0) {
        charge -= 1;
        if (charge == 0) burst = blen;
    }
    if (burst > 0) {
        var k = blen - burst;   // fotogrammi da quando e' iniziata la raffica: 0, 1, 2...
        burst -= 1;
        switch (pat) {
            case 1: // SPIRALE: un colpo per braccio ogni 6 fotogrammi; i bracci girano di 9 gradi
                if (k mod 6 == 0) {
                    for (var arm = 0; arm < 3; arm++) global.shoot(x, y + 6, spin + arm * 120, 1.7);
                    spin += 9 * sdir;
                }
                break;
            case 2: // ANELLO: 16 colpi; un anello si' e uno no sfalsato di mezzo passo (11,25 gradi)
                global.shoot_ring(x, y + 6, 16, 1.6, 90 + (rings mod 2) * 11.25);
                rings += 1;
                break;
            case 3: // PIOGGIA: un colpo dritto in giu' ogni 8 fotogrammi: una colonna lunga
                if (k mod 8 == 0) global.shoot(x, y + 14, 270, 3);
                break;
        }
    }
    exit;
}
if (timer mod max(48, 75 - obj_game.wave * 2) == 0) charge = 30;   // un colpo ogni 1,25 s (era 1,5)   // 0,5 s di avviso prima di sparare
if (charge > 0) {
    charge -= 1;
    if (charge == 0 && instance_exists(obj_player)) {
        var aim = point_direction(x, y, obj_player.x, obj_player.y);
        // dall'ondata 4 le Lance sparano a ventaglio (3 colpi), prima un colpo solo
        var spread = (obj_game.wave >= 10) ? 2 : ((obj_game.wave >= 4) ? 1 : 0);
        for (var s = -spread; s <= spread; s++) {
            var b = instance_create_layer(x, y + 14, "Instances", obj_ebullet);
            b.dir = aim + s * 14;
            b.spd = 2 + obj_game.wave * 0.04;
        }
    }
}
