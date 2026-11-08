/// scende lento verso dove eri quando e' partito; il guscio gira
if (hp < last_hp) flash = 4;
last_hp = hp;
if (flash > 0) flash -= 1;
t += 1;
rot += 4;
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
if (y > room_height - HUD_H + 20 || x < -30 || x > room_width + 30 || y < -60) instance_destroy();   // perso
