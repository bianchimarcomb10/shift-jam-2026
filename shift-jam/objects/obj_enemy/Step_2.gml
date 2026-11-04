/// End Step, ereditato da tutti i nemici (Falene, Lance...):
/// se due nemici si sovrappongono, ognuno si sposta un po' via dall'altro.
with (obj_enemy) {
    if (id != other.id) {
        var min_d = radius + other.radius + 2;   // distanza minima tra i due bordi, piu' 2 px
        var d = point_distance(x, y, other.x, other.y);
        if (d < min_d) {
            if (d == 0) {
                other.x += choose(-1, 1);   // esattamente sovrapposti: una spinta a caso
            } else {
                var a = point_direction(x, y, other.x, other.y);
                var push = (min_d - d) / 2;   // meta' della spinta: l'altra meta' la fa l'altro nemico
                other.x += lengthdir_x(push, a);
                other.y += lengthdir_y(push, a);
            }
        }
    }
}
