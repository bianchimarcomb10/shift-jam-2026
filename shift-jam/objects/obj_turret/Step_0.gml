if (!instance_exists(ship)) { silent = true; instance_destroy(); exit; }
// resta agganciata alla nave: centro della rastrelliera (la nave e' girata di 180 gradi)
x = ship.x + bx + ((rack == 0) ? 14.5 : -14.5);
y = ship.y + oy - 0.5;
if (flash > 0) flash -= 1;

// spara solo quando e' ben dentro lo schermo
if (y < 16) exit;
timer -= 1;
if (timer <= 0) {
    charge = 30;                      // mezzo secondo di avviso: le punte gialle si accendono
    // RABBIA: meno torrette restano, piu' veloci sparano le altre (fino a quasi il doppio)
    var alive = instance_number(obj_turret);
    timer = round((armored ? 90 : 100) * (0.55 + 0.45 * alive / 8));
}
if (charge > 0) {
    charge -= 1;
    if (charge == 0) {
        // tre siluri, uno per tubo. Le normali sparano a ventaglio verso il basso (si schivano o si tagliano),
        // le corazzate mirano a te: sono i colpi da parare per rimandarglieli contro
        for (var k = -1; k <= 1; k++) {
            var b = instance_create_layer(x + k * 6, y + 6, "Instances", obj_ebullet);
            if (armored && instance_exists(obj_player)) b.dir = point_direction(x, y, obj_player.x, obj_player.y) + k * 7;
            else b.dir = 270 + k * 14;
            b.spd = armored ? 2.4 : 2.0;
        }
    }
}
