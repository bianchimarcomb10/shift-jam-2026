/// Controllore della partita: manda le ondate di nemici.
/// Nasce quando il mecha si trasforma (rm_ground) o all'inizio di rm_game.
randomize();
audio_master_gain(0.4);   // volume generale piu' basso
global.hp = 3;          // il giocatore regge 3 colpi
spawn_timer = 120;      // 2 secondi prima della prima ondata
// CHECKPOINT: superata la nave enorme, dopo un game over si riparte dall'ondata successiva (lo salva obj_bigship).
// Lo azzera obj_ground all'inizio di una partita nuova
if (!variable_global_exists("checkpoint")) global.checkpoint = 0;
wave = global.checkpoint;
cp_timer = 0;           // > 0 mentre si vede la scritta "CHECKPOINT"
game_over = false;
boss_spawned = false;
finale = false;         // true durante il finale "Silenzio"
preview_timer = 0;      // > 0 mentre le sagome dell'ondata salgono sullo sfondo
boss_preview = false;   // la sagoma della nave madre e' gia' passata?
boss_timer = 0;
walls = [];             // conto alla rovescia dei muri di colpi in arrivo
// avviso "SHIFT + Z TO PARRY": compare ai muri finche' il giocatore non para almeno un colpo di un muro.
// E' globale, cosi' resta anche dopo un game over
if (!variable_global_exists("parry_learned")) global.parry_learned = false;
draw_set_font(fnt_main);

/// COLPO NEMICO: una piccola sfera di energia magenta, con alone, scia e nucleo che pulsa.
/// La usa obj_ebullet (i colpi parati hanno il loro disegno: global.draw_pshot).
/// bx, by = posizione; bdir = direzione in cui vola; bspd = velocita' (lunghezza della scia); ph = fase della pulsazione
global.draw_ebullet = function(bx, by, bdir, bspd, ph) {
    var pulse = 0.5 + 0.5 * dsin(ph);
    gpu_set_blendmode(bm_add);   // luce che si somma: l'alone brilla sopra lo sfondo
    // scia: tre fantasmi sempre piu' piccoli e deboli dietro al colpo
    for (var k = 3; k >= 1; k--) {
        var tl = bspd * k * 1.6;
        draw_set_alpha(0.32 - k * 0.08);
        draw_set_colour(make_colour_rgb(190, 30, 150));
        draw_circle(bx - lengthdir_x(tl, bdir), by - lengthdir_y(tl, bdir), 3.2 - k * 0.6, false);
    }
    // alone che respira
    draw_set_alpha(0.18 + 0.12 * pulse);
    draw_set_colour(make_colour_rgb(255, 40, 190));
    draw_circle(bx, by, 6 + pulse, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    // corpo: magenta scuro fuori, rosa dentro, bianco al centro
    draw_set_colour(make_colour_rgb(200, 20, 150));
    draw_circle(bx, by, 3.5, false);
    draw_set_colour(make_colour_rgb(255, 110, 215));
    draw_circle(bx, by, 2.5, false);
    draw_set_colour(merge_colour(make_colour_rgb(255, 200, 240), c_white, pulse));
    draw_circle(bx, by, 1.2, false);
}

/// COLPO PARATO: luce azzurra con una scia che segue la curva. Appena parato fa un lampo bianco:
/// il colpo nemico si e' "purificato" ed e' diventato tuo.
/// bx, by = posizione; tr = ultime posizioni; life = fotogrammi di vita; ph = fase della pulsazione
global.draw_pshot = function(bx, by, tr, life, ph) {
    var pulse = 0.5 + 0.5 * dsin(ph);
    gpu_set_blendmode(bm_add);
    var n = array_length(tr);
    for (var i = 0; i < n; i++) {
        var u = (i + 1) / n;   // 0 = la posizione piu' vecchia, 1 = la piu' recente
        draw_set_alpha(0.35 * u);
        draw_set_colour(make_colour_rgb(60, 140, 255));
        draw_circle(tr[i][0], tr[i][1], 0.8 + 2.2 * u, false);
    }
    draw_set_alpha(0.2 + 0.12 * pulse);
    draw_set_colour(make_colour_rgb(110, 190, 255));
    draw_circle(bx, by, 6 + pulse, false);
    if (life < 8) {   // il lampo della parata
        draw_set_alpha(1 - life / 8);
        draw_set_colour(c_white);
        draw_circle(bx, by, 9 - life, false);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(70, 150, 255));
    draw_circle(bx, by, 3.5, false);
    draw_set_colour(make_colour_rgb(180, 230, 255));
    draw_circle(bx, by, 2.5, false);
    draw_set_colour(c_white);
    draw_circle(bx, by, 1.2, false);
}

/// DISEGNO A PEZZI: i nemici nello spazio sono sprite tagliate in pezzi che si muovono (come mecha e alieni di terra).
/// spr = sprite; parts = lista di pezzi; px, py = posizione; rot = rotazione di tutto il nemico; sc = grandezza.
/// Ogni pezzo: [sinistra, alto, larghezza, altezza, perno x, perno y, rotazione attorno al perno, spostamento x, spostamento y]
/// (tutte le misure sono dentro lo sprite originale, prima di girarlo)
global.draw_parts = function(spr, parts, px, py, rot, sc) {
    var ox = sprite_get_xoffset(spr), oy = sprite_get_yoffset(spr);
    for (var i = 0; i < array_length(parts); i++) {
        var p = parts[i];
        var a = p[6];
        // centro del pezzo rispetto al perno, ruotato del suo angolo
        var cx = p[0] + p[2] / 2 - p[4];
        var cy = p[1] + p[3] / 2 - p[5];
        var cl = point_distance(0, 0, cx, cy), cd = point_direction(0, 0, cx, cy) + a;
        var vx = (lengthdir_x(cl, cd) + p[4] - ox + p[7]) * sc;
        var vy = (lengthdir_y(cl, cd) + p[5] - oy + p[8]) * sc;
        // poi tutto il nemico girato di rot
        var vl = point_distance(0, 0, vx, vy), vd = point_direction(0, 0, vx, vy) + rot;
        var wx = px + lengthdir_x(vl, vd);
        var wy = py + lengthdir_y(vl, vd);
        // draw_sprite_general ruota attorno all'angolo in alto a sinistra: lo ricavo dal centro
        var hw = p[2] / 2 * sc, hh = p[3] / 2 * sc;
        var dd = point_direction(0, 0, -hw, -hh) + rot + a;
        var dl = point_distance(0, 0, hw, hh);
        draw_sprite_general(spr, 0, p[0], p[1], p[2], p[3],
            wx + lengthdir_x(dl, dd), wy + lengthdir_y(dl, dd), sc, sc, rot + a,
            c_white, c_white, c_white, c_white, draw_get_alpha());
    }
}

/// Disegna il fotogramma k di una striscia (fotogrammi quadrati, larghi quanto la striscia e' alta),
/// centrato in (px, py), girato di rot e ingrandito di sc.
global.draw_frame = function(spr, k, px, py, rot, sc) {
    var fw = sprite_get_height(spr);
    var hw = fw / 2 * sc;
    // draw_sprite_general ruota attorno all'angolo in alto a sinistra: lo ricavo dal centro
    var dd = point_direction(0, 0, -hw, -hw) + rot;
    var dl = point_distance(0, 0, hw, hw);
    draw_sprite_general(spr, 0, k * fw, 0, fw, fw,
        px + lengthdir_x(dl, dd), py + lengthdir_y(dl, dd), sc, sc, rot,
        c_white, c_white, c_white, c_white, draw_get_alpha());
}

/// Esplosione di una navetta nemica: la sua animazione "Destruction" del pacchetto Kla'ed (ricolorata
/// verde acido), girata e grande come la navetta, cosi' le crepe si aprono proprio sopra lo scafo.
/// Si chiama SOLO quando un nemico viene ucciso (non quando esce dallo schermo).
global.enemy_boom = function(e) {
    var s = -1, first = 0, r = 0, bsc = 1;
    switch (e.object_index) {
        case obj_moth:    s = spr_boom_fighter; first = 1; r = e.dir - 90;  break;   // Falena = Fighter
        case obj_spear:   s = spr_boom_frigate; first = 2; r = 180;         break;   // Lancia = Frigate
        case obj_stalker: s = spr_boom_support; first = 2; r = e.face - 90; break;   // Inseguitore = Support ship
        case obj_laser:   s = spr_boom_bomber;  first = 1; r = 180; bsc = 2;   break;   // Nave laser = Bomber, grande il doppio
    }
    if (s == -1) return;   // torrette e Custode hanno gia' la loro fine
    var b = instance_create_layer(e.x, e.y, "Instances", obj_boom);
    b.spr = s;
    b.f = first;           // si parte dalle prime crepe, non dalla nave intera
    b.last = sprite_get_width(s) / sprite_get_height(s);
    b.sc = bsc;
    b.rot = r;
}

/// SUTRA DEL CONTINUE: a ogni ripartenza dopo un game over compare a schermo uno di questi testi.
/// Sono 8 (circa 5 game over di un giocatore medio + 3 di scorta). Escono in ordine casuale
/// ma senza ripetersi finche' non sono usciti tutti. Traduzioni nostre, brevi, dall'originale.
if (!variable_global_exists("continues")) global.continues = 0;
if (!variable_global_exists("sutra_bag")) global.sutra_bag = [];
sutras = [
    ["Form is emptiness,\nemptiness is form.", "- Heart Sutra"],
    ["No old age and death,\nand no end of old age and death.", "- Heart Sutra"],
    ["Gone, gone, gone beyond,\ngone all the way beyond.\nAwake!", "- Heart Sutra"],
    ["All conditioned things are like a dream, an illusion, a bubble, a shadow, like dew or a flash of lightning.", "- Diamond Sutra"],
    ["The past mind cannot be grasped. The present mind cannot be grasped. The future mind cannot be grasped.", "- Diamond Sutra"],
    ["Originally there is not a single thing.\nWhere could the dust fall?", "- Huineng, Platform Sutra"],
    ["The Great Way is not difficult for those who have no preferences.", "- Sengcan, Xinxin Ming"],
    ["To study the self\nis to forget the self.", "- Dogen, Genjokoan"]
];
sutra = -1;          // quale sutra si vede ora (-1 = nessuno)
sutra_timer = 0;
if (global.continues > 0) {
    // il sacchetto vuoto si riempie di nuovo e si mescola
    if (array_length(global.sutra_bag) == 0) {
        for (var si = 0; si < array_length(sutras); si++) array_push(global.sutra_bag, si);
        for (var si = array_length(global.sutra_bag) - 1; si > 0; si--) {
            var sj = irandom(si);
            var tmp = global.sutra_bag[si];
            global.sutra_bag[si] = global.sutra_bag[sj];
            global.sutra_bag[sj] = tmp;
        }
    }
    sutra = array_pop(global.sutra_bag);
    sutra_timer = 300;     // 5 secondi a schermo
    spawn_timer = 300;     // la prima ondata aspetta che il testo sia sparito
}
if (!instance_exists(obj_sky)) instance_create_layer(0, 0, "Instances", obj_sky);
if (!instance_exists(obj_starfield)) instance_create_layer(0, 0, "Instances", obj_starfield);
if (!instance_exists(obj_player)) instance_create_layer(room_width / 2, room_height - 80, "Instances", obj_player);

/// Crea una formazione di Falene.
/// _form: 1 serpente, 2 V, 3 anello, 4 tenaglia.  _n: quante.  _cx: centro.  _amp: ampiezza del serpente.
spawn_formation = function(_form, _n, _cx, _amp, _shape) {
    for (var i = 0; i < _n; i++) {
        var m = instance_create_layer(-100, -100, "Instances", obj_moth);
        m.form = _form;
        m.idx = i;
        m.n = _n;
        m.cx = _cx;
        m.amp = _amp;
        m.shape = is_undefined(_shape) ? 0 : _shape;   // solo per le formazioni aeree (form 3)
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

/// Navi laser: si fermano in alto, una accanto all'altra, dopo _wait fotogrammi.
/// Se sono due, mirano una a sinistra e una a destra di te: i due raggi fanno una gabbia.
spawn_lasers = function(_k, _wait) {
    for (var i = 0; i < _k; i++) {
        var lz = instance_create_layer(room_width * (i + 1) / (_k + 1), -70, "Instances", obj_laser);
        lz.wait = _wait + i * 40;
        lz.offs = (_k == 1) ? 0 : ((i == 0) ? -60 : 60);
        lz.stop_y = 76 + (i mod 2) * 18;
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
///   ["delta", quante, centro x, verso]      squadriglia a CUNEO (triangolo, max 10) che scende serpeggiando
///   ["diamond", quante, centro x, verso]    squadriglia a ROMBO (max 9)
///   ["echelon", quante, centro x, verso]    squadriglia a SCAGLIONE (diagonale, max 8): si apre verso l'esterno
///                                           (verso 1 o -1: due squadriglie serpeggiano a specchio)
///   ["pincer", quante]                      tenaglia dai lati
///   ["corridor", quante]                    corridoio laterale
///   ["spears", quante]                      Lance in fila in alto
///   ["stalkers", quante, attesa]            Inseguitori dai lati dopo "attesa" fotogrammi
///   ["laser", quante, attesa]               Navi laser (raggio continuo, non si para) dopo "attesa" fotogrammi
///   ["wall", attesa]                        muro di colpi dopo "attesa" fotogrammi
///   ["bigship"]                             la nave enorme con le torrette (un'ondata da sola)
/// Per cambiare il gioco basta cambiare questa tabella.
waves = [
    /* 1  */ [["snake", 8, 180, 100]],
    /* 2  */ [["v", 7, 180]],
    /* 3  */ [["snake", 6, 110, 50], ["wall", 220]],                        // primo muro: da solo, per impararlo
    /* 4  */ [["pincer", 10]],
    /* 5  */ [["spears", 2], ["corridor", 10]],
    /* 6  */ [["delta", 10, 180], ["stalkers", 1, 300], ["wall", 240]],                 // primo cuneo
    /* 7  */ [["snake", 7, 100, 70], ["snake", 7, 260, -70]],
    /* 8  */ [["v", 8, 180], ["wall", 150], ["wall", 300]],
    /* 9  */ [["bigship"]],   // INTERLUDIO: la nave enorme passa; si spengono le torrette (obj_bigship)
    /* 10 */ [["laser", 1, 60], ["corridor", 10], ["stalkers", 2, 330]],                 // prima nave laser, dopo il checkpoint
    /* 11 */ [["echelon", 6, 140, 1], ["echelon", 6, 220, -1], ["wall", 200]],             // due scaglioni: una V grande che si apre e si chiude
    /* 12 */ [["pincer", 16], ["wall", 180], ["wall", 320], ["laser", 1, 420]],             // la tenaglia da sola: il serpente in mezzo la tagliava; il laser dopo i muri
    /* 13 */ [["spears", 4], ["corridor", 12], ["wall", 250]],
    /* 14 */ [["snake", 9, 100, 70], ["snake", 9, 260, -70], ["stalkers", 2, 300], ["wall", 120], ["wall", 280], ["laser", 2, 360]],   // due laser: la gabbia
    /* 15 */ [["diamond", 9, 90, 1], ["diamond", 9, 270, -1], ["stalkers", 2, 330], ["wall", 200], ["wall", 340]],   // due rombi a specchio
    /* 16 */ [["spears", 4], ["corridor", 14], ["stalkers", 3, 300], ["wall", 150], ["wall", 300], ["wall", 420]],   // corridoio sotto le Lance, non in mezzo
    /* 17 */ [["snake", 12, 90, 60], ["snake", 12, 270, -60], ["stalkers", 4, 360], ["wall", 160], ["wall", 320], ["wall", 460], ["laser", 2, 520]]   // due serpenti a specchio
];
boss_wave = array_length(waves);   // dopo l'ultima ondata arriva il boss

/// Quante Falene, Lance, Inseguitori e Navi laser ci sono nell'ondata "wave" (serve all'anteprima).
wave_contents = function() {
    var res = [0, 0, 0, 0];
    var cmds = waves[wave - 1];
    for (var i = 0; i < array_length(cmds); i++) {
        var k = cmds[i][0];
        if (k == "spears") res[1] += cmds[i][1];
        else if (k == "stalkers") res[2] += cmds[i][1];
        else if (k == "laser") res[3] += cmds[i][1];
        else if (k != "wall" && k != "bigship") res[0] += cmds[i][1];
    }
    return res;
}

/// Anteprima: le sagome dell'ondata salgono dal basso sullo sfondo.
/// In testa le Navi laser e le Lance, poi le Falene a file da 6, in coda gli Inseguitori.
spawn_preview = function() {
    var c = wave_contents();
    var p = instance_create_layer(room_width / 2, room_height + 30, "Instances", obj_preview);
    p.spd = 3.5;
    var rows = [[spr_enemy_laser, c[3]], [spr_enemy_spear, c[1]], [spr_enemy_moth, min(c[0], 24)], [spr_enemy_stalker, c[2]]];
    var ry = 0;
    for (var r = 0; r < array_length(rows); r++) {
        var spr = rows[r][0];
        var cnt = rows[r][1];
        for (var i = 0; i < cnt; i++) {
            var line = i div 6;
            var in_row = min(6, cnt - line * 6);
            array_push(p.items, [spr, ((i mod 6) - (in_row - 1) / 2) * 22, ry + line * 20, 0.6, 1]);
        }
        if (cnt > 0) ry += ceil(cnt / 6) * 20 + 8;
    }
    // l'interludio: davanti a tutto sale la sagoma dello scafo della nave enorme
    var cmds_p = waves[wave - 1];
    for (var ci = 0; ci < array_length(cmds_p); ci++) {
        if (cmds_p[ci][0] == "bigship") { array_push(p.items, [spr_bigship_hull, 0, -60, 1, 1]); ry = max(ry, 40); }
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
            case "delta":
            case "square":   // vecchio nome
            case "ring":     spawn_formation(3, c[1], c[2], (array_length(c) > 3) ? c[3] : 1, 0); break;
            case "diamond":  spawn_formation(3, c[1], c[2], (array_length(c) > 3) ? c[3] : 1, 1); break;
            case "echelon":  spawn_formation(3, c[1], c[2], (array_length(c) > 3) ? c[3] : 1, 2); break;
            case "pincer":   spawn_formation(4, c[1], 0, 0); break;
            case "corridor": spawn_formation(5, c[1], 0, 0); break;
            case "spears":   spawn_spears(c[1]); break;
            case "stalkers": spawn_stalkers(c[1], c[2]); break;
            case "laser":    spawn_lasers(c[1], c[2]); break;
            case "wall":     array_push(walls, c[1]); break;
            case "bigship":  instance_create_layer(room_width / 2, -90, "Instances", obj_bigship); break;
        }
    }
}

/// MURO: due fregate scendono insieme al centro, si separano (una a sinistra, una a destra)
/// e posano una fila di colpi dal centro fino ai bordi, senza varchi. Poi cabrano ed escono in alto.
/// Quando sono andate via i colpi scendono tutti insieme. La navicella non puo' schivarlo:
/// bisogna diventare mecha e tagliarlo.
spawn_wall = function() {
    var gap = 12;
    var spd_f = 4;   // abbastanza lente da vedere la scia che lasciano
    var left = [], right = [];
    for (var wx = 6; wx < room_width; wx += gap) {
        if (wx < room_width / 2) array_push(left, wx); else array_push(right, wx);
    }
    // tempo: picchiata (circa 70 px) + corsa fino al bordo + un po' di margine per la cabrata
    var total = ceil((70 + room_width / 2 + 20) / spd_f) + 30;
    var f1 = instance_create_layer(room_width / 2 - 10, -40, "Instances", obj_frigate);
    f1.side = -1; f1.spd = spd_f; f1.total = total; f1.slots = [];
    for (var i = array_length(left) - 1; i >= 0; i--) array_push(f1.slots, left[i]);   // dal centro verso sinistra
    var f2 = instance_create_layer(room_width / 2 + 10, -40, "Instances", obj_frigate);
    f2.side = 1; f2.spd = spd_f; f2.total = total; f2.slots = right;                      // dal centro verso destra
    f1.bspd = 1.5 + min(wave, 16) * 0.03;
    f2.bspd = f1.bspd;
    audio_play_sound(snd_menu, 6, false);   // segnale provvisorio: arriva un muro
}
