ph += 4;
if (y < target_y) {
    y += 1.6;   // scende piano, dentro una colonna di luce
} else {
    t += 1;
    y = target_y + 4 * dsin(t * 3);   // galleggia
    // se non vai a prenderla, dopo 2 secondi ti viene incontro piano
    if (t > 120 && instance_exists(obj_player)) {
        var d = point_direction(x, y, obj_player.x, obj_player.y);
        x += lengthdir_x(0.8, d);
        target_y += lengthdir_y(0.8, d);
    }
}
// presa!
if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 26) {
    global.has_drill = true;
    with (obj_game) {
        drill_state = 2;
        drill_phrase = 270;   // "YOUR DRILL IS THE DRILL THAT WILL PIERCE THE HEAVENS!"
    }
    audio_play_sound(snd_explosion_big, 9, false, 0.5);
    audio_play_sound(snd_shift, 9, false, 1);
    instance_destroy();
}
