// lo sfondo disegnato nel livello "Background" scorre insieme alle stelle
// (e nel finale si ferma con loro). Nella room basta spuntare "Vertical Tile".
var bg = layer_get_id("Background");
if (bg != -1) {
    // 0,5 px per fotogramma = 1 pixel ogni 2 fotogrammi, sempre uguale.
    // (con 0,6 il passo era irregolare: 1, 1, 0, 1, 0... e lo sfondo andava a scatti)
    layer_vspeed(bg, 0.5 * speed_mult);
    // lo sprite ha 16 fotogrammi in cui le nebulose cambiano forma: animato sembra saltare.
    // Lo teniamo fermo sul primo fotogramma.
    var bge = layer_background_get_id(bg);
    if (bge != -1) {
        layer_background_speed(bge, 0);
        layer_background_index(bge, 0);
    }
}

for (var i = 0; i < array_length(stars); i++) {
    var s = stars[i];
    s[@ 1] += s[2] * speed_mult;
    if (s[1] > room_height) { s[@ 1] = 0; s[@ 0] = random(room_width); }
}
