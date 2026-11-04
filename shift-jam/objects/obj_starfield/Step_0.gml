for (var i = 0; i < array_length(stars); i++) {
    var s = stars[i];
    s[@ 1] += s[2];
    if (s[1] > room_height) { s[@ 1] = 0; s[@ 0] = random(room_width); }
}
