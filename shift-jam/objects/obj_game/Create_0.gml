/// Controllore della partita: manda le ondate di nemici.
/// Nasce quando il mecha si trasforma (rm_ground) o all'inizio di rm_game.
randomize();
audio_master_gain(0.4);   // volume generale piu' basso
global.hp = 3;          // il giocatore regge 3 colpi
spawn_timer = 120;      // 2 secondi prima della prima ondata
wave = 0;
game_over = false;
boss_spawned = false;
finale = false;         // true durante il finale "Silenzio"
preview_timer = 0;      // > 0 mentre le sagome dell'ondata salgono sullo sfondo
boss_preview = false;   // la sagoma della nave madre e' gia' passata?
boss_timer = 0;
walls = [];             // conto alla rovescia dei muri di colpi in arrivo
draw_set_font(fnt_main);
if (!instance_exists(obj_sky)) instance_create_layer(0, 0, "Instances", obj_sky);
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
        m.can_shoot = (wave >= 2 && (wave >= 10 || i mod 2 == 0));   // una su due, dalla 10 tutte
        m.fire_timer = 60 + (i * 37) mod 140;   // sempre lo stesso ritmo: si puo' imparare
        m.shots = 1 + wave div 5;   // 1, poi 2 dalla 5, 3 dalla 10, 4 dalla 15
    }
}

/// Lance in fila, a distanza regolare nella fascia alta dello schermo (y 50-100):
/// cosi' non si scontrano tra loro e lasciano libero il centro alle Falene.
spawn_spears = function(_k) {
    for (var i = 0; i < _k; i++) {
        var sp = instance_create_layer(room_width * (i + 1) / (_k + 1), -30, "Instances", obj_spear);
        sp.stop_y = 50 + (i mod 2) * 40;   // a zig-zag, sempre uguale
    }
}

/// Inseguitori che entrano DAI LATI dopo _wait fotogrammi (quando le Falene sono gia' passate):
/// cosi' non attraversano la fascia alta dove stanno le Lance.
spawn_stalkers = function(_k, _wait) {
    for (var i = 0; i < _k; i++) {
        var sx = (i mod 2 == 0) ? -30 : room_width + 30;   // uno da sinistra, uno da destra
        var st = instance_create_layer(sx, 230 + (i mod 3) * 55, "Instances", obj_stalker);
        st.fire_timer = 70 + i * 20;
        st.wait = _wait + i * 40;
    }
}

/// LE 16 ONDATE, scritte a mano: ogni partita e' uguale, si imparano a memoria.
/// Ogni riga e' un comando:
///   ["snake", quante, centro x, ampiezza]   serpente
///   ["v", quante, centro x]                 V che si ferma e picchia
///   ["ring", quante, centro x]              anello che ruota
///   ["pincer", quante]                      tenaglia dai lati
///   ["corridor", quante]                    corridoio laterale
///   ["spears", quante]                      Lance in fila in alto
///   ["stalkers", quante, attesa]            Inseguitori dai lati dopo "attesa" fotogrammi
///   ["wall", attesa]                        muro di colpi dopo "attesa" fotogrammi
/// Per cambiare il gioco basta cambiare questa tabella.
waves = [
    /* 1  */ [["snake", 8, 180, 100]],
    /* 2  */ [["v", 7, 180]],
    /* 3  */ [["snake", 6, 110, 50], ["wall", 220]],                        // primo muro: da solo, per impararlo
    /* 4  */ [["pincer", 10]],
    /* 5  */ [["spears", 2], ["corridor", 10]],
    /* 6  */ [["ring", 8, 180], ["stalkers", 1, 300], ["wall", 240]],
    /* 7  */ [["snake", 7, 100, 70], ["snake", 7, 260, -70]],
    /* 8  */ [["v", 8, 180], ["wall", 150], ["wall", 300]],
    /* 9  */ [["spears", 3], ["corridor", 10], ["stalkers", 2, 330]],
    /* 10 */ [["ring", 8, 120], ["ring", 8, 240], ["wall", 200]],
    /* 11 */ [["pincer", 14], ["snake", 6, 180, 50], ["wall", 180], ["wall", 320]],
    /* 12 */ [["spears", 4], ["corridor", 12], ["wall", 250]],
    /* 13 */ [["snake", 9, 100, 70], ["snake", 9, 260, -70], ["stalkers", 2, 300], ["wall", 120], ["wall", 280]],
    /* 14 */ [["v", 10, 180], ["ring", 8, 180], ["wall", 200], ["wall", 340]],
    /* 15 */ [["spears", 4], ["pincer", 14], ["stalkers", 3, 300], ["wall", 150], ["wall", 300], ["wall", 420]],
    /* 16 */ [["snake", 10, 90, 60], ["snake", 10, 270, -60], ["v", 8, 180], ["stalkers", 3, 360], ["wall", 160], ["wall", 320], ["wall", 460]]
];
boss_wave = array_length(waves);   // dopo l'ultima ondata arriva il boss

/// Quante Falene, Lance e Inseguitori ci sono nell'ondata "wave" (serve all'anteprima).
wave_contents = function() {
    var res = [0, 0, 0];
    var cmds = waves[wave - 1];
    for (var i = 0; i < array_length(cmds); i++) {
        var k = cmds[i][0];
        if (k == "spears") res[1] += cmds[i][1];
        else if (k == "stalkers") res[2] += cmds[i][1];
        else if (k != "wall") res[0] += cmds[i][1];
    }
    return res;
}

/// Anteprima: le sagome dell'ondata salgono dal basso sullo sfondo.
/// In testa le Lance, poi le Falene a file da 6, in coda gli Inseguitori.
spawn_preview = function() {
    var c = wave_contents();
    var p = instance_create_layer(room_width / 2, room_height + 30, "Instances", obj_preview);
    p.spd = 3.5;
    var rows = [[spr_enemy_spear, c[1]], [spr_enemy_moth, min(c[0], 24)], [spr_enemy_stalker, c[2]]];
    var ry = 0;
    for (var r = 0; r < 3; r++) {
        var spr = rows[r][0];
        var cnt = rows[r][1];
        for (var i = 0; i < cnt; i++) {
            var line = i div 6;
            var in_row = min(6, cnt - line * 6);
            array_push(p.items, [spr, ((i mod 6) - (in_row - 1) / 2) * 22, ry + line * 20, 0.6, 1]);
        }
        if (cnt > 0) ry += ceil(cnt / 6) * 20 + 8;
    }
    // dietro l'ondata, l'orda: tantissime sagome piu' piccole e lontane, che cresce a ogni ondata.
    // Non arrivano tutte: dicono soltanto che non finiranno mai.
    var horde = 20 + wave * 4;
    var sprs = [spr_enemy_moth, spr_enemy_moth, spr_enemy_moth, spr_enemy_stalker, spr_enemy_spear];
    for (var h = 0; h < horde; h++) {
        array_push(p.items, [sprs[irandom(4)], random_range(-p.x + 10, room_width - p.x - 10), random_range(-40, ry + 120 + wave * 6), random_range(0.25, 0.4), 0]);
    }
}

/// Crea l'ondata vera, leggendo la sua riga della tabella.
spawn_wave = function() {
    var cmds = waves[wave - 1];
    for (var i = 0; i < array_length(cmds); i++) {
        var c = cmds[i];
        switch (c[0]) {
            case "snake":    spawn_formation(1, c[1], c[2], c[3]); break;
            case "v":        spawn_formation(2, c[1], c[2], 0); break;
            case "ring":     spawn_formation(3, c[1], c[2], 0); break;
            case "pincer":   spawn_formation(4, c[1], 0, 0); break;
            case "corridor": spawn_formation(5, c[1], 0, 0); break;
            case "spears":   spawn_spears(c[1]); break;
            case "stalkers": spawn_stalkers(c[1], c[2]); break;
            case "wall":     array_push(walls, c[1]); break;
        }
    }
}

/// MURO: una fila di colpi da un bordo all'altro, senza varchi.
/// La navicella non puo' schivarlo: bisogna diventare mecha e tagliarlo.
spawn_wall = function() {
    var gap = 12;
    for (var wx = 6; wx < room_width; wx += gap) {
        var b = instance_create_layer(wx, -8, "Instances", obj_ebullet);
        b.dir = 270;
        b.spd = 1.5 + min(wave, 16) * 0.03;
    }
    audio_play_sound(snd_menu, 6, false);   // segnale provvisorio: arriva un muro
}
