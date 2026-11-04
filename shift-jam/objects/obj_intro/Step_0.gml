t += 1;

switch (state) {
case 0:   // titolo: aspetta SHIFT
    if (keyboard_check_pressed(vk_shift)) { state = 1; t = 0; audio_play_sound(snd_menu, 5, false); }
    break;

case 1:   // il titolo sfuma nel nero in 2/3 di secondo
    if (t >= 40) { state = 2; t = 0; }
    break;

case 2:   // la frase resta 5 secondi (compare e svanisce piano)
    if (t >= 300) { state = 3; t = 0; }
    break;

case 3:   // al posto della frase: "Press SHIFT"
    if (keyboard_check_pressed(vk_shift)) { state = 4; t = 0; audio_play_sound(snd_menu, 5, false); }
    break;

case 4:   // le stelle si accendono sempre piu' in fretta finche' lo schermo diventa bianco
    if (array_length(stars) < 3000) {
        repeat (1 + t div 4) array_push(stars, [random(room_width), random(room_height)]);
    }
    if (t >= 240) room_goto(rm_ground);   // 4 secondi, poi la fase a terra (che parte dal bianco)
    break;
}
