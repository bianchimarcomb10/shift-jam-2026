/// Controllore della partita: manda le ondate di nemici.
/// Nasce quando il mecha si trasforma (rm_ground) o all'inizio di rm_game.
randomize();
audio_master_gain(0.4);   // volume generale piu' basso
global.hp = 3;          // il giocatore regge 3 colpi
lead = 120;             // 2 secondi prima della prima ondata (5 dopo un continue, col sutra)
wave_t = -1;            // fotogrammi da quando e' iniziata l'ondata attuale (-1 = non ancora)
seq_t = -1;             // fotogrammi da quando e' iniziata la sequenza della trivella (-1 = non ancora)
// CHECKPOINT: superata la nave enorme, dopo un game over si riparte dall'ondata successiva (lo salva obj_bigship).
// Lo azzera obj_ground all'inizio di una partita nuova
if (!variable_global_exists("checkpoint")) global.checkpoint = 0;
wave = global.checkpoint;
cp_timer = 0;           // > 0 mentre si vede la frase del checkpoint (niente parola "CHECKPOINT": una frase sul silenzio)
cp_total = 240;        // la frase dura 4 secondi: 1 per comparire, 2 ferma, 1 per svanire
cp_text = "";          // quale frase: la sceglie chi salva il checkpoint
game_over = false;
boss_spawned = false;
finale = false;         // true durante il finale "Silenzio"
boss_preview = false;   // la sagoma della nave madre e' gia' passata? (la guarda obj_sky)
walls = [];             // muri di colpi in arrivo: [conto alla rovescia, tipo, x della porta]
pending = [];           // comandi dell'ondata che partono piu' tardi (["at", fotogrammi, comando]): [conto alla rovescia, comando]
// TRIVELLA: poco prima del boss scende dal cielo; il mecha la prende e diventa la sua arma
global.has_drill = false;   // si riprende ogni volta (anche ripartendo dal checkpoint del boss)
drill_state = 0;        // 0 = non ancora arrivata, 1 = sta arrivando, 2 = piantata nel mecha
drill_phrase = 0;       // > 0 mentre si vede la frase della trivella
boss_phrase = 0;        // > 0 mentre si vede la frase all'arrivo del boss
// avviso "SHIFT THEN Z/SPACE TO PARRY": compare ai muri finche' il giocatore non para almeno un colpo di un muro.
// E' globale, cosi' resta anche dopo un game over
if (!variable_global_exists("parry_learned")) global.parry_learned = false;
draw_set_font(fnt_main);

/// TRIVELLA disegnata dal codice: un cono che punta in alto, con la spirale che gira.
/// (px, py) = centro della base; sc = grandezza di un "pixel" della trivella; ph = rotazione della spirale;
/// glow = 0..1 alone azzurro (carica piena). E' azzurra come tutto cio' che e' tuo.
global.draw_drill = function(px, py, sc, ph, glow, dn = 1) {
    // dn = 1 punta in alto (in mano al mecha), dn = -1 punta in basso (quando piomba sul mecha).
    // (px, py) e' sempre il centro della base
    var st = max(1, sc);
    var W = 7 * st, H = 20 * st;
    if (glow > 0) {
        gpu_set_blendmode(bm_add);
        draw_set_alpha(glow * (0.35 + 0.15 * dsin(current_time * 0.6)));
        draw_set_colour(make_colour_rgb(40, 140, 255));
        draw_circle(px, py - H * 0.45 * dn, W * 1.7 + 2, false);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
    }
    // contorno scuro sotto
    draw_set_colour(make_colour_rgb(10, 16, 30));
    draw_triangle(px, py - (H + st) * dn, px - W - st, py + st * dn, px + W + st, py + st * dn, false);
    // spirale: 20 righe dalla punta alla base, ogni riga a quadretti di due colori che girano
    var cA0 = make_colour_rgb(30, 90, 150),  cA1 = make_colour_rgb(120, 220, 255);
    var cB0 = make_colour_rgb(60, 70, 100),  cB1 = make_colour_rgb(225, 245, 255);
    for (var j = 0; j < 20; j++) {
        var f = (j + 0.5) / 20;                 // 0 = punta, 1 = base
        var ya = py + (j * st - H) * dn;        // i due bordi della riga (scambiati se la punta e' in basso)
        var yb = py + ((j + 1) * st - H) * dn;
        var y1 = min(ya, yb), y2 = max(ya, yb);
        var hwp = max(1, round(7 * f));         // mezza larghezza della riga, in "pixel"
        for (var i = -hwp; i < hwp; i++) {
            var u = (i + 0.5) / hwp;
            var band = floor((darcsin(u) + ph + f * 160 + 3600) / 30);   // la banda si attorciglia scendendo
            var sh = sqrt(max(0, 1 - u * u));   // il centro e' piu' chiaro dei bordi: e' rotonda
            draw_set_colour((band mod 2 == 0) ? merge_colour(cA0, cA1, sh) : merge_colour(cB0, cB1, sh));
            draw_rectangle(px + i * st, y1, px + (i + 1) * st, y2, false);   // senza -1: celle sovrapposte, nessun buco quando st non e' intero
        }
    }
    // collare d'acciaio alla base
    draw_set_colour(make_colour_rgb(60, 70, 95));
    draw_rectangle(px - W - st, min(py, py + 2 * st * dn), px + W + st, max(py, py + 2 * st * dn), false);
    draw_set_colour(make_colour_rgb(170, 190, 220));
    var yh = py + max(1, st / 2) * dn;   // la riga chiara del collare, attaccata alla trivella
    draw_rectangle(px - W - st, min(py, yh), px + W + st, max(py, yh), false);
    draw_set_colour(c_white);
}

/// Frase ENORME come "SHIFT TO STRUGGLE": entra crescendo, trema, poi sfuma.
/// La grandezza si calcola dalla riga piu' lunga e dall'altezza totale, cosi' non esce mai dallo schermo.
/// txt = testo con \n; tm = frame rimasti; total = durata; c2 = colore che lampeggia col bianco
global.big_phrase = function(txt, tm, total, c2) {
    var gw = display_get_gui_width(), gh = display_get_gui_height();
    var el = total - tm;
    var sc = min((gw - 28) / string_width(txt), (gh * 0.6) / string_height(txt));
    sc *= (el < 12) ? lerp(0.6, 0.97, el / 12) : (0.95 + 0.02 * dsin(current_time * 0.9));
    var sx = random_range(-2, 2), sy = random_range(-2, 2);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(clamp(tm / 40, 0, 1));
    draw_set_colour(c_black);   // ombra, per leggerla sopra a tutto
    draw_text_transformed(gw / 2 + sx + 3, gh * 0.42 + sy + 3, txt, sc, sc, 0);
    draw_set_colour(((current_time div 150) mod 2 == 0) ? c_white : c2);
    draw_text_transformed(gw / 2 + sx, gh * 0.42 + sy, txt, sc, sc, 0);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}

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

/// COLPI A DISEGNO, come in Ikaruga: i nemici non sparano solo verso di te, disegnano figure
/// (anelli, spirali, colonne, corde) sempre uguali, che si imparano a memoria.
/// Sono tutti magenta: tutti si parano col mecha, e i colpi parati tornano contro i nemici.
global.shoot = function(_x, _y, _dir, _spd) {
    var b = instance_create_layer(_x, _y, "Instances", obj_ebullet);
    b.dir = _dir;
    b.spd = _spd;
    return b;
}
/// ANELLO: _n colpi tutt'intorno. _off gira l'anello: due anelli sfalsati di mezzo passo spostano i varchi
global.shoot_ring = function(_x, _y, _n, _spd, _off) {
    for (var i = 0; i < _n; i++) global.shoot(_x, _y, _off + i * 360 / _n, _spd);
}
/// CORDA: _n colpi nella stessa direzione, uno dietro l'altro (velocita' che crescono):
/// una linea che arriva dritta su di te. Non si schiva frenando: ci si sposta di lato
global.shoot_rope = function(_x, _y, _dir, _n, _spd) {
    for (var i = 0; i < _n; i++) global.shoot(_x, _y, _dir, _spd * (1 + i * 0.13));
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
    // PROIETTILE-REGALO del boss spaccato: lascia cadere il suo regalo, con una scintilla
    if (e.object_index == obj_gift) {
        if (e.gift == 0) instance_create_layer(e.x, e.y, "Instances", obj_heart);
        else { var pg = instance_create_layer(e.x, e.y, "Instances", obj_powerup); pg.kind = e.gift; }
        if (instance_exists(obj_player)) array_push(obj_player.sparks, [e.x, e.y, 12]);
        return;
    }
    switch (e.object_index) {
        case obj_moth:    s = spr_boom_fighter; first = 1; r = e.dir - 90;  break;   // Falena = Fighter
        case obj_spear:   s = spr_boom_frigate; first = 2; r = 180;         break;   // Lancia = Frigate
        case obj_stalker: s = spr_boom_support; first = 2; r = e.face - 90; break;   // Inseguitore = Support ship
        case obj_laser:   s = spr_boom_bomber;  first = 1; r = 180; bsc = 2;   break;   // Nave laser = Bomber, grande il doppio
        case obj_carrier: s = spr_boom_fighter; first = 1; r = 0;           break;   // Portatrice: piccola come una Falena
    }
    if (s == -1) return;   // torrette e Custode hanno gia' la loro fine
    // la Lancia bianca e nera lascia il cuore con lo yin-yang
    if (e.object_index == obj_spear && e.special) instance_create_layer(e.x, e.y, "Instances", obj_heart);
    if (e.object_index == obj_carrier) {   // la Portatrice lascia cadere la sua arma speciale
        var pu = instance_create_layer(e.x, e.y, "Instances", obj_powerup);
        pu.kind = e.kind;
    }
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
    lead = 300;            // la prima ondata aspetta che il testo sia sparito
}
if (!instance_exists(obj_sky)) instance_create_layer(0, 0, "Instances", obj_sky);
if (!instance_exists(obj_starfield)) instance_create_layer(0, 0, "Instances", obj_starfield);
if (!instance_exists(obj_player)) instance_create_layer(room_width / 2, room_height - HUD_H - 50, "Instances", obj_player);

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
        m.shape = is_undefined(_shape) ? 0 : _shape;   // formazioni aeree (form 3): la figura; ruota (form 7): come esce
        if (_form == 1) m.delay = i * 12;          // il serpente entra una falena dopo l'altra
        if (_form == 4) {                          // tenaglia: meta' da sinistra, meta' da destra
            m.side = (i mod 2 == 0) ? 1 : -1;
            m.delay = (i div 2) * 14 + ((m.side == -1) ? 7 : 0);   // sfalsate di mezzo passo
        }
        if (_form == 5) {                          // corridoio: prima una fila da sinistra, poi una da destra piu' in basso
            var half = ceil(_n / 2);
            m.side = (i < half) ? 1 : -1;
            m.delay = (i mod half) * 14 + ((m.side == -1) ? 100 : 0);
            m.base_y = (m.side == 1) ? 250 : 340;
        }
        if (_form == 6) {                          // croce: due file dagli angoli in alto, una falena si' e una no
            m.side = (i mod 2 == 0) ? 1 : -1;
            m.delay = (i div 2) * 40 + ((m.side == -1) ? 20 : 0);  // sfalsate: al centro passano a 25 px l'una dall'altra
        }
        if (_form == 8) {                          // risalita: una fila sola, dal lato _amp (1 sinistra, -1 destra)
            m.side = sign(_amp);
            m.delay = 50 + i * 14;                 // 50 fotogrammi per l'avviso verde in basso (Draw)
        }
        // dall'ondata 2 una falena su due spara; dall'ondata 8 spara due colpi
        m.can_shoot = (wave >= 2 && (wave >= 10 || i mod 2 == 0));   // una su due, dalla 10 tutte
        m.fire_timer = 60 + (i * 37) mod 140;   // sempre lo stesso ritmo: si puo' imparare
        m.shots = 1 + wave div 5;   // 1, poi 2 dalla 5, 3 dalla 10, 4 dalla 15
        if (_form == 7) m.can_shoot = false;   // la ruota spara a modo suo: tutte insieme, verso l'esterno
    }
}

/// Lance in fila, a distanza regolare nella fascia alta dello schermo (y 50-100):
/// cosi' non si scontrano tra loro e lasciano libero il centro alle Falene.
/// _pat: come sparano (0 mira, 1 spirale, 2 anello, 3 pioggia: vedi obj_spear).
/// _heart: 1 = quella al centro della fila e' BIANCA E NERA e lascia un cuore (+1 vita)
spawn_spears = function(_k, _pat, _heart, _xs) {
    for (var i = 0; i < _k; i++) {
        var lx = is_array(_xs) ? _xs[i] : room_width * (i + 1) / (_k + 1);   // posizioni scelte a mano, o in fila regolare
        var sp = instance_create_layer(lx, -30, "Instances", obj_spear);
        sp.stop_y = 66 + (i mod 2) * 40;   // a zig-zag, sempre uguale; sotto la rotta delle fregate dei muri (y 26)
        sp.special = (_heart == 1 && i == _k div 2);
        sp.pat = _pat;
        sp.sdir = (sp.x < room_width / 2) ? 1 : -1;   // le spirali di sinistra e di destra girano a specchio
        sp.next = 40 + (i mod 2) * 75;     // la pioggia si alterna: una colonna si chiude mentre l'altra si apre
    }
}

/// PORTATRICE: una piccola nave bianca e nera che attraversa lo schermo in alto e porta un'arma speciale.
/// _kind: 1 razzi, 2 laser, 3 ventaglio.  _wait: fotogrammi di attesa.  _side: 1 da sinistra, -1 da destra
spawn_carrier = function(_kind, _wait, _side, _y) {
    var cr = instance_create_layer(-100, -100, "Instances", obj_carrier);
    cr.kind = _kind;
    cr.wait = _wait;
    cr.side = _side;
    if (_y > 0) cr.base_y = _y;   // la sua corsia: scelta in modo che non incroci gli altri nemici
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
/// _pat: 0 un colpo mirato, 1 una CORDA di 4 colpi in fila
spawn_stalkers = function(_k, _wait, _pat) {
    for (var i = 0; i < _k; i++) {
        var sx = (i mod 2 == 0) ? -30 : room_width + 30;   // uno da sinistra, uno da destra
        var st = instance_create_layer(sx, 230 + (i mod 3) * 55, "Instances", obj_stalker);
        st.fire_timer = 70 + i * 20;
        st.wait = _wait + i * 40;
        st.pat = _pat;
    }
}

/// LE 17 ONDATE, scritte a mano: ogni partita e' uguale, si imparano a memoria.
/// L'idea viene da Ikaruga: ogni ondata ha UN disegno nuovo da imparare, presentato prima da solo
/// e poi mescolato con quelli gia' visti. Tre atti, con la nave enorme in mezzo:
///   1-8   impari le parole: croce, anelli, porta nel muro, ruota, risalita da sotto, muro doppio
///   10-13 lo spazio si stringe: laser, corde, muro a freccia, colonne di pioggia, spirali
///   14-17 tutto insieme, fino al finale
/// Ogni riga e' un comando:
///   ["snake", quante, centro x, ampiezza]   serpente
///   ["v", quante, centro x]                 V che si ferma e picchia
///   ["delta", quante, centro x, verso]      squadriglia a CUNEO (triangolo, max 10) che scende serpeggiando
///   ["diamond", quante, centro x, verso]    squadriglia a ROMBO (max 9)
///   ["echelon", quante, centro x, verso]    squadriglia a SCAGLIONE (diagonale, max 8): si apre verso l'esterno
///                                           (verso 1 o -1: due squadriglie serpeggiano a specchio)
///   ["pincer", quante]                      tenaglia dai lati
///   ["corridor", quante]                    corridoio laterale
///   ["cross", quante]                       CROCE: due file dagli angoli in alto che si incrociano a X
///   ["wheel", quante, centro x, verso, uscita]  RUOTA: cerchio che gira e spara verso l'esterno; poi esce:
///                                           uscita 0 si apre come un fiore, 1 sale intera, 2 scivola fuori dal suo lato
///   ["rise", quante, lato]                  RISALITA: una fila che sale DA SOTTO lungo il bordo (1 sinistra, -1 destra)
///   ["spears", quante, colpo, cuore, [x]]   Lance in fila in alto. colpo: 0 mira, 1 spirale, 2 anello, 3 pioggia.
///                                           [x] (facoltativo): le posizioni, es. [80, 280]
///                                           cuore 1 = una e' bianca e nera e lascia un cuore
///   ["stalkers", quante, attesa, colpo]     Inseguitori dai lati dopo "attesa" fotogrammi. colpo: 0 mirato, 1 corda
///   ["laser", quante, attesa]               Navi laser (raggio continuo, non si para) dopo "attesa" fotogrammi
///   ["wall", attesa, tipo, x]               muro di colpi dopo "attesa" fotogrammi. tipo: 0 pieno, 1 con una PORTA
///                                           larga 52 px in x, 2 a FRECCIA (il centro cade prima), 3 DOPPIO (due file)
///   ["bigship"]                             la nave enorme con le torrette (un'ondata da sola)
///   ["carrier", arma, attesa, lato, y]      PORTATRICE: abbattuta lascia un'arma speciale (1 razzi, 2 laser, 3 ventaglio);
///                                           y (facoltativo) = la sua corsia
///   ["at", fotogrammi, comando]             un comando qualsiasi, ma piu' tardi (es. ["at", 300, ["snake", 8, 90, 60]])
/// Per cambiare il gioco basta cambiare questa tabella. I TEMPI (wave_secs, piu' sotto) non cambiano.
waves = [
    // ATTO I: le parole
    /* 1  */ [["snake", 8, 180, 100]],                                                   // primo contatto
    /* 2  */ [["cross", 10]],                                                            // CROCE: due file a X
    /* 3  */ [["snake", 6, 110, 50], ["wall", 220]],                                     // primo muro: da solo, per impararlo
    /* 4  */ [["pincer", 10]],
    /* 5  */ [["spears", 2, 2, 1], ["corridor", 8]],                                     // ANELLI: i varchi si spostano a ogni anello. Cuore
    /* 6  */ [["delta", 10, 180], ["stalkers", 1, 300, 0], ["wall", 240, 1, 270]],      // il muro ha una PORTA a destra: passi o pari
    /* 7  */ [["wheel", 8, 180, 1], ["carrier", 1, 0, 1, 45]],                         // RUOTA; prima Portatrice: i RAZZI, sopra la ruota
    /* 8  */ [["rise", 7, 1], ["at", 90, ["rise", 7, -1]], ["wall", 250, 3]],            // RISALITA da sotto, poi MURO DOPPIO: due parate a tempo
    // INTERLUDIO
    /* 9  */ [["bigship"]],   // la nave enorme passa; si spengono le torrette (obj_bigship)
    // ATTO II: lo spazio si stringe
    /* 10 */ [["cross", 12], ["laser", 1, 300], ["at", 380, ["rise", 6, 1]], ["stalkers", 2, 480, 1]],   // prima la CROCE, poi la prima nave laser; RISALITA sotto il raggio; Inseguitori a CORDA
    /* 11 */ [["echelon", 6, 120, 1], ["echelon", 6, 240, -1], ["wall", 200, 2]],      // due scaglioni; muro a FRECCIA
    /* 12 */ [["spears", 4, 3, 0], ["pincer", 12], ["wall", 380, 1, 180], ["laser", 1, 560], ["carrier", 2, 330, -1, 160]],   // PIOGGIA: corsie che si aprono e chiudono. Portatrice del LASER, sotto le Lance
    /* 13 */ [["spears", 2, 1, 1], ["corridor", 10]],                                   // SPIRALI a specchio. Cuore
    // ATTO III: tutto insieme
    /* 14 */ [["wheel", 8, 110, 1, 2], ["wheel", 8, 250, -1, 2], ["wall", 440, 2], ["stalkers", 2, 420, 1], ["laser", 2, 540]],   // due ruote che girano al contrario ed escono di lato; poi la gabbia
    /* 15 */ [["diamond", 9, 90, 1], ["diamond", 9, 270, -1], ["at", 260, ["spears", 2, 2, 0]], ["wall", 380, 3]],     // due rombi a specchio; dietro di loro gli anelli
    /* 16 */ [["spears", 3, 0, 1], ["rise", 8, -1], ["wall", 150, 1, 90], ["wall", 300, 1, 270], ["wall", 480, 1, 90], ["carrier", 3, 40, 1, 150]],   // SLALOM: tre porte alternate. Cuore. Portatrice del VENTAGLIO
    /* 17 */ [["cross", 12], ["at", 330, ["spears", 2, 1, 0, [80, 280]]], ["wall", 300, 1, 180], ["at", 330, ["wheel", 8, 180, -1, 1]], ["wall", 600, 3], ["stalkers", 2, 640, 1], ["laser", 2, 760]]   // il finale: tutto quello che hai imparato
];
boss_wave = array_length(waves);   // dopo l'ultima ondata arriva il boss

/// SCALETTA FISSA, come in Ikaruga: ogni ondata dura SEMPRE questi secondi, anche se abbatti tutti prima.
/// Allo scadere i nemici rimasti si ritirano (retreat_all) e parte l'ondata dopo.
/// Cosi' la partita ha sempre gli stessi tempi e la musica delle ondate e' un brano unico scritto su questi.
/// Ogni durata comprende i 3,5 s in cui salgono le sagome, prima dei nemici veri.
/// Totale: 2 s di attesa + 244 s di ondate = 4:06. Poi 15 s di trivella (seq_t) e il boss a 4:21.
/// Se cambi un numero qui, cambia anche la musica: avvisa il musicista.
wave_secs = [11, 11, 12, 9, 11, 14, 11, 12, 24, 16, 13, 18, 12, 18, 16, 16, 20];
seq_len = 900;    // la sequenza della trivella: 15 secondi esatti

/// Tempo scaduto: i nemici rimasti smettono di combattere e se ne vanno, verso il bordo piu' vicino
/// (su o giu'). Li muove la Begin Step di obj_enemy. Il boss e le torrette della nave enorme restano.
retreat_all = function() {
    with (obj_enemy) {
        if (object_index == obj_boss || object_index == obj_turret || retreat) continue;
        retreat = true;
        rspd = 0;
        rdir = (y > room_height * 0.5) ? 270 : 90;
        if (object_index == obj_spear) charge = 0;   // l'occhio si spegne
        if (object_index == obj_laser) { state = 5; t = 0; }   // niente piu' linea d'avviso: se ne va
    }
}

/// Quante Falene, Lance, Inseguitori e Navi laser ci sono nell'ondata "wave" (serve all'anteprima).
wave_contents = function() {
    var res = [0, 0, 0, 0];
    var cmds = waves[wave - 1];
    for (var i = 0; i < array_length(cmds); i++) {
        var c = cmds[i];
        if (c[0] == "at") c = c[2];   // un comando che arriva piu' tardi conta lo stesso
        var k = c[0];
        if (k == "spears") res[1] += c[1];
        else if (k == "stalkers") res[2] += c[1];
        else if (k == "laser") res[3] += c[1];
        else if (k != "wall" && k != "bigship" && k != "carrier") res[0] += c[1];
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
    for (var i = 0; i < array_length(cmds); i++) spawn_cmd(cmds[i]);
}

/// Esegue un comando della tabella (vedi sopra). I numeri che mancano valgono 0.
spawn_cmd = function(c) {
    var a = function(_c, _i) { return (array_length(_c) > _i) ? _c[_i] : 0; };
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
        case "cross":    spawn_formation(6, c[1], 0, 0); break;
        case "wheel":    spawn_formation(7, c[1], c[2], (array_length(c) > 3) ? c[3] : 1, a(c, 4)); break;
        case "rise":     spawn_formation(8, c[1], 0, (array_length(c) > 2) ? c[2] : 1); break;
        case "spears":   spawn_spears(c[1], a(c, 2), a(c, 3), a(c, 4)); break;
        case "stalkers": spawn_stalkers(c[1], c[2], a(c, 3)); break;
        case "laser":    spawn_lasers(c[1], c[2]); break;
        case "wall":     array_push(walls, [c[1], a(c, 2), a(c, 3)]); break;
        case "bigship":  instance_create_layer(room_width / 2, -90, "Instances", obj_bigship); break;
        case "carrier":  spawn_carrier(c[1], c[2], c[3], a(c, 4)); break;
        case "at":       array_push(pending, [c[1], c[2]]); break;
    }
}

/// MURO: due fregate scendono insieme al centro, si separano (una a sinistra, una a destra)
/// e posano una fila di colpi dal centro fino ai bordi, senza varchi. Poi cabrano ed escono in alto.
/// Quando sono andate via i colpi scendono tutti insieme. La navicella non puo' schivarlo:
/// bisogna diventare mecha e tagliarlo.
/// _type: 0 PIENO; 1 con una PORTA larga 52 px centrata in _gx (ci passi con la navicella, o lo pari);
///        2 a FRECCIA (il centro cade piu' in fretta dei bordi: la parata va presa in tempi diversi);
///        3 DOPPIO (una seconda fila parte 40 fotogrammi dopo la prima: due parate a tempo)
spawn_wall = function(_type, _gx) {
    var gap = 12;
    var spd_f = 4;   // abbastanza lente da vedere la scia che lasciano
    var left = [], right = [];
    for (var wx = 6; wx < room_width; wx += gap) {
        if (_type == 1 && abs(wx - _gx) < 26) continue;   // la porta: qui le fregate non posano niente
        if (wx < room_width / 2) array_push(left, wx); else array_push(right, wx);
    }
    // tempo: picchiata (circa 70 px) + corsa fino al bordo + un po' di margine per la cabrata
    var total = ceil((70 + room_width / 2 + 20) / spd_f) + 30;
    var f1 = instance_create_layer(room_width / 2 - 16, -40, "Instances", obj_frigate);   // 32 px tra le due: non si toccano
    f1.side = -1; f1.spd = spd_f; f1.total = total; f1.slots = [];
    for (var i = array_length(left) - 1; i >= 0; i--) array_push(f1.slots, left[i]);   // dal centro verso sinistra
    var f2 = instance_create_layer(room_width / 2 + 16, -40, "Instances", obj_frigate);
    f2.side = 1; f2.spd = spd_f; f2.total = total; f2.slots = right;                      // dal centro verso destra
    f1.bspd = 1.5 + min(wave, 16) * 0.03;
    f2.bspd = f1.bspd;
    f1.wtype = _type;
    f2.wtype = _type;
    audio_play_sound(snd_menu, 6, false);   // segnale provvisorio: arriva un muro
}
