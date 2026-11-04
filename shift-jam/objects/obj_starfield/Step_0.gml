// lo sfondo disegnato nel livello "Background" scorre insieme alle stelle
// (e nel finale si ferma con loro). Nella room basta spuntare "Vertical Tile".
var bg = layer_get_id("Background");
if (bg != -1) layer_vspeed(bg, 0.6 * speed_mult);

for (var i = 0; i < array_length(stars); i++) {
    var s = stars[i];
    s[@ 1] += s[2] * speed_mult;
    if (s[1] > room_height) { s[@ 1] = 0; s[@ 0] = random(room_width); }
}
