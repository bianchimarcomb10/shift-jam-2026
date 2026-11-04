/// Stelle che scorrono verso il basso: danno l'idea che la navicella sale.
alpha = 1;
speed_mult = 1;   // 1 = velocita' normale; nel finale scende a 0 e le stelle si fermano
depth = 90;   // sopra il cielo e il terreno, sotto navicella e nemici
stars = [];
for (var i = 0; i < 90; i++) {
    stars[i] = [random(room_width), random(room_height), random_range(0.4, 3)];   // x, y, velocita'
}
