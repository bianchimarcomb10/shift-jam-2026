t += 1;
rot += spin;
x += vx + 0.6 * dsin(t * 5);   // cade ondeggiando, come un foglio
y += 0.9;
if (t > 70) instance_destroy();
