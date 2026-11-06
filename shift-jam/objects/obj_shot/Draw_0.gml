// colpo parato: luce azzurra (il colore del motore della navicella), cosi' non si confonde coi colpi nemici
if (parried) global.draw_pshot(x, y, trail, life, current_time * 0.6 + id * 47);
else draw_sprite(spr_player_shot, (current_time div 60) mod 4, x, y);   // colpo della navicella: 4 fotogrammi animati
