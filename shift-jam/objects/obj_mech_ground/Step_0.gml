if (sweep_cooldown > 0) sweep_cooldown -= 1;
if (sweep_anim > 0) sweep_anim -= 1;

var st = obj_ground.state;

if (st == 0 && sweep_cooldown == 0 && (keyboard_check(ord("Z")) || keyboard_check(ord("J")))) {
    sweep_cooldown = 30;   // una falciata ogni mezzo secondo
    sweep_anim = 10;
    var kills = 0;
    with (obj_grunt) {
        if (point_distance(x, y, other.x, other.y) <= other.sweep_radius) {
            kills += 1;
            instance_destroy();
        }
    }
    // ogni alieno falciato fa scendere un po' la barra: resisti di piu', ma non per sempre
    obj_ground.bar = max(0, obj_ground.bar - kills * 0.004);
}

if (st == 3) {
    vy -= 0.15;   // accelera verso l'alto
    y += vy;
}
