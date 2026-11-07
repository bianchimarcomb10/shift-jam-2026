/// End Step, ereditato da tutti i nemici:
/// se due nemici si sovrappongono, chi puo' si sposta.
/// Le Falene in formazione e il boss seguono un percorso fisso: non vengono mai spinti,
/// sono gli altri a scansarsi del tutto. Tra due nemici "liberi" ognuno fa meta' strada.
if (object_index == obj_boss) exit;
if (retreat) exit;                      // chi si ritira passa attraverso gli altri
if (object_index == obj_turret) exit;   // le torrette sono agganciate alla nave enorme
if (object_index == obj_laser) exit;    // la nave laser tiene la sua colonna
if (object_index == obj_carrier) exit;  // la Portatrice segue la sua rotta
if (object_index == obj_moth && form > 0) exit;

var me = id;
with (obj_enemy) {
    if (id != me && !retreat) {
        var fixed = (object_index == obj_boss) || (object_index == obj_turret) || (object_index == obj_laser) || (object_index == obj_moth && form > 0);
        var min_d = radius + me.radius + 2;   // distanza minima tra i due bordi, piu' 2 px
        var d = point_distance(x, y, me.x, me.y);
        if (d < min_d) {
            if (d == 0) {
                me.x += choose(-1, 1);   // esattamente sovrapposti: una spinta a caso
            } else {
                var share = fixed ? 1 : 0.5;   // contro un percorso fisso mi sposto tutto io
                var a = point_direction(x, y, me.x, me.y);
                me.x += lengthdir_x((min_d - d) * share, a);
                me.y += lengthdir_y((min_d - d) * share, a);
            }
        }
    }
}
