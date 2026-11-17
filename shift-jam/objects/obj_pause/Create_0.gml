/// Pausa (P o ESC) e audio muto (M). Persistente: lo crea music_ensure (scr_music). Vedi scr_pause.
pause_spr = -1;      // la fotografia dello schermo mentre si e' in pausa
pause_t0 = 0;        // current_time quando e' iniziata la pausa
pause_layers = [];   // i livelli che scorrevano da soli: [livello, hspeed, vspeed]
mute_msg = 0;        // fotogrammi in cui resta la scritta SOUND OFF / SOUND ON
