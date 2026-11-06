if (silent) exit;
// esplosione (animazione del pacchetto Kla'ed) e fumo che resta sulla nave: la nave e' ferita, ma va avanti
instance_create_layer(x, y, "Instances", obj_boom);
if (instance_exists(ship)) array_push(ship.wrecks, [x - ship.x, y - ship.y]);
