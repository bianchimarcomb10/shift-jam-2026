/// Finale "Silenzio": esplosione, poi la navicella sale da sola fino a diventare una stella tra le stelle.
boss_x = x;
boss_y = y;
t = 0;
flash = 1;
fade = 0;
depth = -100;
obj_game.finale = true;   // niente piu' ondate ne' interfaccia

with (obj_ebullet) instance_destroy();
with (obj_enemy) if (object_index != obj_boss) instance_destroy();

// il giocatore non comanda piu': la navicella va da sola
ship_x = room_width / 2;
ship_y = room_height - 80;
if (instance_exists(obj_player)) {
    ship_x = obj_player.x;
    ship_y = obj_player.y;
    instance_destroy(obj_player);
}
start_x = ship_x;
start_y = ship_y;
scale = 1;
// qui, quando ci sara' l'audio, la musica si fermera' di colpo (audio_stop_all)
