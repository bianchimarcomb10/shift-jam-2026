# tools/mecha_palette.py - ricolora il mecha coi materiali della navicella (16-11-2026).
# Input: gli sprite ORIGINALI dello sketch (quelli del commit della PR #55); sugli sprite gia' ricolorati non fa niente.
# Uso: python3 tools/mecha_palette.py <cartella sprites originale> <cartella di uscita> [wing|silver] [visor 1|0] [edges 1|0]
# Scrive spr_mecha_body/<frame>.png e spr_mecha_scythe/<frame>.png: poi vanno copiati anche in layers/<frame>/<layer>.png.
# Ricolora gli sprite del mecha (sketch di Francesco "Rocketbird" Passero) coi materiali della navicella.
# Le forme non cambiano: cambia solo il colore di ogni pixel, scelto per materiale e zona.
#   mantello      -> blu-lilla delle ali (ombra, base, piega chiara)
#   veste         -> piega chiara delle ali  (robe='wing')  oppure argento della fusoliera (robe='silver')
#   cappello      -> argento del muso, righe come i pannelli
#   spalline      -> acciaio chiaro (come i pugni e l'asta)
#   gambe         -> acciaio scuro dei motori, con l'ugello azzurro in fondo
#   fiamme, lama  -> azzurro dei motori (70,190,255) con le luci (215,250,255)
#   asta          -> acciaio blu con l'anima chiara (150,170,200), come l'asta disegnata dal codice
# Opzioni: visor = occhio azzurro sotto la tesa (l'abitacolo della navicella), edges = bordo d'attacco chiaro
# in alto e bordo d'uscita azzurro in basso sul mantello, come sulle ali.
import sys, os, glob, numpy as np
from PIL import Image
A = (12, 10, 24); K = (14, 12, 22)
B = (172, 172, 172); C = (128, 128, 132); D = (83, 94, 97); E = (86, 92, 104); F = (56, 63, 66)
G = (28, 50, 108); H = (41, 73, 152); I = (60, 68, 168); J = (85, 96, 226)
L = (149, 216, 240); LL = (205, 245, 255)
CY = (70, 190, 255); CY_L = (215, 250, 255); CY_G = (40, 140, 255)
WING = {G: (45, 51, 94), H: (78, 92, 168), I: (94, 110, 184), J: (110, 128, 200)}
SILVER_ROBE = {I: (150, 166, 176), J: (196, 210, 214)}
HAT = {B: (214, 226, 222), C: (150, 166, 176), D: (118, 130, 146), E: (124, 136, 156), F: (70, 80, 104)}
STEEL = {B: (214, 226, 222), C: (170, 186, 206), D: (112, 126, 152), E: (124, 140, 170), F: (70, 80, 104)}
LEGS = {B: (150, 170, 200), C: (124, 140, 170), D: (70, 80, 104), E: (86, 98, 128), F: (52, 58, 80)}
FLAME = {L: CY, LL: CY_L, B: (150, 225, 255), C: CY_G, D: CY_G, E: CY_G, F: (30, 90, 200)}
SHAFT = {F: (70, 80, 104), E: (150, 170, 200), D: (130, 150, 184), C: (170, 186, 206), B: (214, 226, 222)}
BLADE = {L: CY, LL: CY_L, B: CY_L, C: (150, 225, 255), E: (120, 170, 220), D: (120, 170, 220), F: (70, 120, 200)}

def body(im, robe='wing', visor=True, edges=True):
    a = np.array(im.convert('RGBA')); o = a.copy()
    h, w = a.shape[:2]
    def at(y, x): return tuple(int(v) for v in a[y, x, :3])
    for y in range(h):
        for x in range(w):
            if a[y, x, 3] == 0: continue
            c = at(y, x)
            if c in (A, K): continue
            if y >= 74: m = FLAME
            elif c in WING: m = SILVER_ROBE if (robe == 'silver' and c in SILVER_ROBE) else WING
            elif y < 19: m = HAT
            elif y > 59: m = LEGS
            else: m = STEEL
            if c in m: o[y, x, :3] = m[c]
            elif c in (L, LL): o[y, x, :3] = FLAME[c]
    # ugello: l'ultima riga di metallo di ogni gamba diventa azzurra
    for x in range(w):
        for y in range(73, 59, -1):
            if a[y, x, 3] and at(y, x) in (D, E, F, C, B):
                o[y, x, :3] = CY; break
    if edges:
        # come le ali: bordo d'attacco chiaro sul profilo alto del mantello, bordo d'uscita azzurro sull'orlo.
        # Un pixel per colonna (il piu' alto e il piu' basso del mantello), cosi' la linea resta pulita.
        cloth = lambda y, x: a[y, x, 3] > 0 and at(y, x) in (G, H)
        empty = lambda y, x: a[y, x, 3] == 0 or at(y, x) in (A, K)
        for x in range(w):
            ys = [y for y in range(1, h - 1) if cloth(y, x)]
            if not ys: continue
            top, bot = ys[0], ys[-1]
            if top < 28 and empty(top - 1, x): o[top, x, :3] = (200, 214, 250)
            if bot > 50 and empty(bot + 1, x): o[bot, x, :3] = CY
    if visor:
        # sotto la tesa: i pixel chiari del centro nella riga 17 diventano l'occhio azzurro
        for x in range(w):
            if a[17, x, 3] and at(17, x) == B: o[17, x, :3] = CY
        xs = [x for x in range(w) if a[17, x, 3] and at(17, x) == B]
        if xs: o[17, xs[len(xs) // 2], :3] = CY_L
    return Image.fromarray(o)

def scythe(im):
    a = np.array(im.convert('RGBA')); o = a.copy()
    h, w = a.shape[:2]
    cy = np.zeros((h, w), bool)
    isL = (a[:, :, 0] == L[0]) & (a[:, :, 1] == L[1]) & (a[:, :, 2] == L[2])
    # la lama: L e i pixel grigi che le stanno a 2 pixel o meno
    near = isL.copy()
    for _ in range(2):
        n2 = near.copy()
        n2[1:, :] |= near[:-1, :]; n2[:-1, :] |= near[1:, :]; n2[:, 1:] |= near[:, :-1]; n2[:, :-1] |= near[:, 1:]
        near = n2
    for y in range(h):
        for x in range(w):
            if a[y, x, 3] == 0: continue
            c = tuple(int(v) for v in a[y, x, :3])
            if c in (A, K): continue
            m = BLADE if near[y, x] else SHAFT
            if c in m: o[y, x, :3] = m[c]
    return Image.fromarray(o)

if __name__ == '__main__':
    src, dst = sys.argv[1], sys.argv[2]
    robe = sys.argv[3] if len(sys.argv) > 3 else 'wing'
    visor = (sys.argv[4] if len(sys.argv) > 4 else '1') == '1'
    edges = (sys.argv[5] if len(sys.argv) > 5 else '1') == '1'
    for d in ('spr_mecha_body', 'spr_mecha_scythe'):
        os.makedirs(os.path.join(dst, d), exist_ok=True)
        for f in sorted(glob.glob(os.path.join(src, d, '*.png'))):
            im = Image.open(f)
            r = body(im, robe, visor, edges) if d == 'spr_mecha_body' else scythe(im)
            r.save(os.path.join(dst, d, os.path.basename(f)))
    print('ok', dst)
