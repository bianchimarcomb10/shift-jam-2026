/// Controllore della partita: crea il giocatore e manda le ondate di nemici.
randomize();
global.hp = 3;          // il giocatore regge 3 colpi
spawn_timer = 60;       // frame prima della prima ondata (60 = 1 secondo)
wave = 0;
game_over = false;
instance_create_layer(room_width / 2, room_height - 80, "Instances", obj_player);
