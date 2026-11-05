/// Controllore della partita: manda le ondate di nemici.
/// Nasce quando il mecha si trasforma (rm_ground) o all'inizio di rm_game.
randomize();
audio_master_gain(0.4);   // volume generale piu' basso
global.hp = 3;          // il giocatore regge 3 colpi
spawn_timer = 120;      // 2 secondi prima della prima ondata
wave = 0;
game_over = false;
boss_wave = 16;         // dopo 16 ondate arriva il boss
boss_spawned = false;
finale = false;         // true durante il finale "Silenzio"
preview_timer = 0;      // > 0 mentre le sagome dell'ondata salgono sullo sfondo
boss_preview = false;   // la sagoma della nave madre e' gia' passata?
boss_timer = 0;
draw_set_font(fnt_main);
if (!instance_exists(obj_starfield)) instance_create_layer(0, 0, "Instances", obj_starfield);
if (!instance_exists(obj_player)) instance_create_layer(room_width / 2, room_height - 80, "Instances", obj_player);

/// Crea una formazione di Falene.
/// _form: 1 serpente, 2 V, 3 anello, 4 tenaglia.  _n: quante.  _cx: centro.  _amp: ampiezza del serpente.
spawn_formation = function(_form, _n, _cx, _amp) {
    for (var i = 0; i < _n; i++) {
        var m = instance_create_layer(-100, -100, "Instances", obj_moth);
        m.form = _form;
        m.idx = i;
        m.n = _n;
        m.cx = _cx;
        m.amp = _amp;
        if (_form == 1) m.delay = i * 12;          // il serpente entra una falena dopo l'altra
        if (_form == 4) {                          // tenaglia: meta' da sinistra, meta' da destra
            m.side = (i mod 2 == 0) ? 1 : -1;
            m.delay = (i div 2) * 14;
        }
        if (_form == 5) {                          // corridoio: prima una fila da sinistra, poi una da destra piu' in basso
            var half = ceil(_n / 2);
            m.side = (i < half) ? 1 : -1;
            m.delay = (i mod half) * 14 + ((m.side == -1) ? 100 : 0);
            m.base_y = (m.side == 1) ? 250 : 340;
        }
        // dall'ondata 2 una falena su due spara; dall'ondata 8 spara due colpi
        m.can_shoot = (wave >= 2 && irandom(1) == 0);
        m.shots = (wave >= 8) ? 2 : 1;
    }
}

/// Lance in fila, a distanza regolare nella fascia alta dello schermo (y 50-100):
/// cosi' non si scontrano tra loro e lasciano libero il centro alle Falene.
spawn_spears = function(_k) {
    for (var i = 0; i < _k; i++) {
        var sp = instance_create_layer(room_width * (i + 1) / (_k + 1), -30, "Instances", obj_spear);
        sp.stop_y = random_range(50, 100);
    }
}

/// Inseguitori che entrano DAI LATI dopo _wait fotogrammi (quando le Falene sono gia' passate):
/// cosi' non attraversano la fascia alta dove stanno le Lance.
spawn_stalkers = function(_k, _wait) {
    for (var i = 0; i < _k; i++) {
        var sx = (i mod 2 == 0) ? -30 : room_width + 30;   // uno da sinistra, uno da destra
        var st = instance_create_layer(sx, random_range(220, 360), "Instances", obj_stalker);
        st.wait = _wait + i * 40;
    }
}

/// Che cosa contiene l'ondata numero "wave": quante Falene, Lance e Inseguitori.
/// Serve all'anteprima, che deve mostrare la stessa ondata che poi arriva.
wave_contents = function() {
    var kind = (wave - 1) mod 7;
    switch (kind) {
        case 0: return [8 + wave div 2, 0, 0];
        case 1: return [10 + wave div 2, 2 + wave div 5, 0];
        case 2: return [8, 0, 1 + wave div 5];
        case 3: return [10 + wave div 2, 0, 0];
        case 4: return [2 * (6 + wave div 3), 0, 0];
        case 5: return [8, 3, 2];
        case 6: return [7 + wave div 6, 0, 0];
    }
    return [0, 0, 0];
}

/// Anteprima: le sagome dell'ondata salgono dal basso sullo sfondo, piccole e scure.
/// In testa le Lance, poi le Falene a file da 6, in coda gli Inseguitori.
spawn_preview = function() {
    var c = wave_contents();
    var p = instance_create_layer(random_range(100, room_width - 100), room_height + 30, "Instances", obj_preview);
    var rows = [[spr_enemy_spear, c[1]], [spr_enemy_moth, min(c[0], 12)], [spr_enemy_stalker, c[2]]];
    var ry = 0;
    for (var r = 0; r < 3; r++) {
        var spr = rows[r][0];
        var cnt = rows[r][1];
        for (var i = 0; i < cnt; i++) {
            var line = i div 6;
            var in_row = min(6, cnt - line * 6);
            array_push(p.items, [spr, ((i mod 6) - (in_row - 1) / 2) * 16, ry + line * 14, 0.45]);
        }
        if (cnt > 0) ry += ceil(cnt / 6) * 14 + 6;
    }
}

/// Crea l'ondata vera (quella che l'anteprima ha appena mostrato).
spawn_wave = function() {
    var kind = (wave - 1) mod 7;
    var w = room_width;
    switch (kind) {
        case 0: // serpente, da solo
            spawn_formation(1, 8 + wave div 2, random_range(120, w - 120), 100);
            break;
        case 1: // Lance in alto + Falene che attraversano dai lati, piu' in basso
            spawn_spears(2 + wave div 5);
            spawn_formation(5, 10 + wave div 2, 0, 0);
            break;
        case 2: // anello, poi gli Inseguitori quando l'anello e' sceso
            spawn_formation(3, 8, w / 2, 0);
            spawn_stalkers(1 + wave div 5, 300);
            break;
        case 3: // tenaglia dai lati, da sola
            spawn_formation(4, 10 + wave div 2, 0, 0);
            break;
        case 4: // due serpenti a specchio, da soli
            spawn_formation(1, 6 + wave div 3, w * 0.28, 70);
            spawn_formation(1, 6 + wave div 3, w * 0.72, -70);
            break;
        case 5: // Lance in alto + corridoio, poi Inseguitori
            spawn_spears(3);
            spawn_formation(5, 8, 0, 0);
            spawn_stalkers(2, 330);
            break;
        case 6: // V che si ferma e picchia, da sola
            spawn_formation(2, 7 + wave div 6, w / 2, 0);
            break;
    }
}
