// il foglio aperto: un quadrato con la diagonale della piega, che si gira (si schiaccia) mentre cade
var a = 1 - t / 70;
var sq = dcos(t * 9);          // il foglio che gira su se stesso
var r = 11;
draw_set_alpha(a);
var xs = [], ys = [];
for (var k = 0; k < 4; k++) {
    var ang = rot + 45 + k * 90;
    xs[k] = x + lengthdir_x(r, ang);
    ys[k] = y + lengthdir_y(r, ang) * sq;
}
draw_set_colour(make_colour_rgb(255, 222, 130));
draw_triangle(xs[0], ys[0], xs[1], ys[1], xs[2], ys[2], false);
draw_set_colour(make_colour_rgb(200, 140, 46));
draw_triangle(xs[0], ys[0], xs[2], ys[2], xs[3], ys[3], false);
draw_set_colour(make_colour_rgb(46, 28, 10));
draw_line(xs[0], ys[0], xs[2], ys[2]);
draw_set_alpha(1);
draw_set_colour(c_white);
