x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
if (y < -20 || y > room_height + 20 || x < -20 || x > room_width + 20) instance_destroy();
