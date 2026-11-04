/// Palmo d'oro del Custode: lento, ti insegue un poco. Lo sparo non lo ferma:
/// solo la falciata del mecha lo respinge, e respinto torna contro il Custode.
spd = 1.7;
radius = 10;
reflected = false;
dir = 270;
if (instance_exists(obj_player)) dir = point_direction(x, y, obj_player.x, obj_player.y);
