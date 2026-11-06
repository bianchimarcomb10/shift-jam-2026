# Terra di "Shift into Silence" disegnata dal codice: 360x2880, vista dall'alto
# (leggermente obliqua: si vedono le facce sud). Luce bassa di tramonto da nord-ovest,
# ombre lunghe verso sud-est. Nessun asset esterno.
import sys
import numpy as np
from PIL import Image, ImageDraw

W, H = 360, 2880
OUT = sys.argv[1]

def hx(s):
    return np.array([int(s[i:i + 2], 16) for i in (1, 3, 5)], float)

B4 = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
BAY = np.tile(B4, (H // 4 + 1, W // 4 + 1))[:H, :W]
YY, XX = np.mgrid[0:H, 0:W]

def noise(scale, seed):
    r = np.random.default_rng(seed)
    gh, gw = H // scale + 3, W // scale + 3
    g = r.random((gh, gw)).astype(np.float32)
    im = Image.fromarray(g, 'F').resize((gw * scale, gh * scale), Image.BICUBIC)
    return np.array(im)[:H, :W]

def fbm(seed, scales=(96, 48, 24, 12, 6), w=(0.4, 0.25, 0.17, 0.11, 0.07)):
    n = sum(wi * noise(s, seed + i * 11) for i, (s, wi) in enumerate(zip(scales, w)))
    return (n - n.min()) / (n.max() - n.min())

def hsh(a, b, seed):
    v = (a.astype(np.int64) * 73856093) ^ (b.astype(np.int64) * 19349663) ^ (seed * 83492791)
    v = (v ^ (v >> 13)) * 1274126177
    return ((v >> 8) & 0xffff) / 65535.0

def q(val, n):
    return np.clip(np.floor(val * (n - 1) + BAY), 0, n - 1).astype(int)

def lut(cols):
    return np.array([hx(c) for c in cols])

def newmask():
    return Image.new('L', (W, H), 0)

def m_of(im):
    return np.array(im) > 0

C = np.zeros((H, W, 3))
rng = np.random.default_rng(11)

# ---------------- palette ----------------
EARTH = lut(['#21152a', '#2b1c31', '#35243a', '#412c42', '#4e364b'])
GRASS = lut(['#14212a', '#19292f', '#1e3234', '#253d3b', '#2d4942'])
STONE = lut(['#2a2539', '#38334b', '#46405c', '#57506e', '#6d6585', '#8a7f9a'])
PALE = lut(['#3b3446', '#5a5066', '#706479', '#86798b', '#a1909c'])
LEAF = lut(['#0e1d24', '#13282e', '#1a3638', '#224642', '#2d584d', '#3d6d58'])
RIM = hx('#d8945a')
FLAG = lut(['#2a2436', '#3b354d', '#453f59', '#4f4864', '#625a78', '#7a6f8c'])
PINE = lut(['#0b1921', '#0f222c', '#152e38', '#1c3b44', '#254c50', '#2f5d5b'])
LINE = hx('#0b141a')
WATER = lut(['#141b33', '#18223f', '#1d2a4c', '#243459'])
RUST = lut(['#4a1d22', '#6b2a2a', '#8f3a32', '#ad5040'])
SAND = lut(['#4c465c', '#5a536b', '#675f78'])
GLOW = hx('#ffb066')

# ---------------- 1. terreno di base ----------------
base = fbm(3)
grass_n = fbm(41, (64, 32, 16, 8, 4), (0.35, 0.25, 0.2, 0.12, 0.08))
C[:] = EARTH[q(base * 0.8 + 0.1, 5)]
gm = grass_n + (BAY - 0.5) * 0.08 > 0.34
gv = np.clip((grass_n - 0.4) * 2.2 + (base - 0.5) * 0.5 + 0.3, 0, 1)
C[gm] = GRASS[q(gv, 5)][gm]

def tufts(mask, n, seed, cols=('#2b4d43', '#365a4a', '#7a6e48')):
    r = np.random.default_rng(seed)
    ys, xs = np.nonzero(mask)
    if len(ys) == 0:
        return
    idx = r.choice(len(ys), size=min(n, len(ys)), replace=False)
    for i in idx:
        x, y = xs[i], ys[i]
        c = hx(cols[r.integers(0, 2)]) if r.random() > 0.12 else hx(cols[2])
        for dx, dy in ((0, 0), (-1, -1), (1, -1)):
            if 0 <= x + dx < W and 0 <= y + dy < H:
                C[y + dy, x + dx] = c

tufts(gm, 2600, 5)
# sassolini sulla terra nuda
ys, xs = np.nonzero(~gm)
for i in rng.choice(len(ys), 900, replace=False):
    x, y = xs[i], ys[i]
    C[y, x] = STONE[3]
    if y + 1 < H:
        C[y + 1, x] = STONE[0]

# ---------------- 2. lastricati ----------------
def slabs(mask, sw, sh, pal, miss, seed, crack=0.0):
    row = YY // sh
    col = (XX + (row % 2) * (sw // 2)) // sw
    lx = (XX + (row % 2) * (sw // 2)) % sw
    ly = YY % sh
    h = hsh(row, col, seed)
    tone = 1 + (h * 3).astype(int)
    tone = np.clip(tone + (q(base, 3) - 1), 1, len(pal) - 2)
    idx = tone.copy()
    idx[(lx == 0) | (ly == 0)] = np.minimum(tone + 1, len(pal) - 1)[(lx == 0) | (ly == 0)]
    idx[(lx == sw - 1) | (ly == sh - 1)] = 0
    gone = hsh(row, col, seed + 5) < miss
    m = mask & ~gone
    C[m] = pal[idx][m]
    # muschio tra le pietre
    moss = mask & (fbm(seed + 9, (24, 12, 6), (0.5, 0.3, 0.2)) > 0.62) & ((lx == sw - 1) | (ly == sh - 1) | gone)
    C[moss] = GRASS[3]
    # pietre mancanti: erba
    g2 = mask & gone
    C[g2] = GRASS[q(base, 5)][g2]
    tufts(g2, int(g2.sum() * 0.05), seed + 3)
    if crack > 0:
        r = np.random.default_rng(seed + 7)
        ys, xs = np.nonzero(m)
        for i in r.choice(len(ys), int(len(ys) * crack / 400) + 1, replace=False):
            x, y = int(xs[i]), int(ys[i])
            for s in range(r.integers(5, 16)):
                if 0 <= x < W and 0 <= y < H and m[y, x]:
                    C[y, x] = pal[0]
                x += r.integers(-1, 2)
                y += r.integers(0, 2) if r.random() > 0.5 else 0
                x += 1 if r.random() > 0.6 else 0

def flags(mask, cell, pal, seed, miss=0.06, crack=0.0, moss=0.62):
    """Lastre irregolari (celle di Voronoi) con bordo smussato: luce in alto a sinistra."""
    ys, xs = np.nonzero(mask)
    if not len(ys):
        return
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    yy, xx = np.mgrid[y0:y1, x0:x1]
    gy, gx = yy // cell, xx // cell
    d1 = np.full(yy.shape, 1e9); d2 = np.full(yy.shape, 1e9)
    id1 = np.zeros(yy.shape, np.int64); c1x = np.zeros(yy.shape); c1y = np.zeros(yy.shape)
    for oy in (-1, 0, 1):
        for ox in (-1, 0, 1):
            cy_, cx_ = gy + oy, gx + ox
            px = (cx_ + 0.1 + 0.8 * hsh(cx_, cy_, seed)) * cell
            py = (cy_ + 0.1 + 0.8 * hsh(cx_, cy_, seed + 1)) * cell
            d = np.hypot(xx - px, (yy - py) * 1.2)
            cl = d < d1
            d2 = np.where(cl, d1, np.minimum(d2, d)); d1 = np.where(cl, d, d1)
            id1 = np.where(cl, cy_ * 100003 + cx_, id1)
            c1x = np.where(cl, px, c1x); c1y = np.where(cl, py, c1y)
    e = d2 - d1
    n = len(pal)
    tone = 2 + np.floor(hsh(id1, id1 // 7, seed + 2) * 2.0 + (base[y0:y1, x0:x1] - 0.5) * 1.2).astype(int)
    tone = np.clip(tone, 1, n - 2)
    vx, vy = xx - c1x, yy - c1y
    lit = (vx * -0.6 + vy * -0.8) / (np.hypot(vx, vy) + 1e-6)
    idx = tone.copy()
    idx = np.where((e < 3.2) & (lit > 0.45), np.minimum(tone + 1, n - 1), idx)
    idx = np.where((e < 3.2) & (lit < -0.45), np.maximum(tone - 1, 1), idx)
    idx = np.where(e < 1.4, 0, idx)
    gone = hsh(id1, id1 // 3, seed + 5) < miss
    sub = C[y0:y1, x0:x1]
    mm = mask[y0:y1, x0:x1]
    m = mm & ~gone
    sub[m] = pal[idx][m]
    mo = mm & (fbm(seed + 9, (24, 12, 6), (0.5, 0.3, 0.2))[y0:y1, x0:x1] > moss) & ((e < 2.0) | gone)
    sub[mo] = GRASS[3]
    g2 = mm & gone
    sub[g2] = GRASS[q(base, 5)[y0:y1, x0:x1]][g2]
    if crack > 0:
        r = np.random.default_rng(seed + 7)
        ly, lx = np.nonzero(m)
        for i in r.choice(len(ly), int(len(ly) * crack / 500) + 1, replace=False):
            x, y = int(lx[i]), int(ly[i])
            for _ in range(r.integers(4, 12)):
                if 0 <= y < y1 - y0 and 0 <= x < x1 - x0 and m[y, x] and e[y, x] > 1.4:
                    sub[y, x] = pal[0] * 0.5 + sub[y, x] * 0.5
                x += r.integers(-1, 2); y += 1 if r.random() > 0.4 else 0

def path_mask(pts, w):
    im = newmask()
    d = ImageDraw.Draw(im)
    d.line(pts, fill=255, width=w, joint='curve')
    for x, y in pts:
        d.ellipse((x - w / 2, y - w / 2, x + w / 2, y + w / 2), fill=255)
    return m_of(im)

# piazza dell'arena (in fondo, quella che si vede di piu')
plaza = np.zeros((H, W), bool)
im = newmask(); d = ImageDraw.Draw(im)
d.rounded_rectangle((26, 2316, 334, 2872), radius=18, fill=255)
plaza = m_of(im)
erode = fbm(77, (32, 16, 8), (0.5, 0.3, 0.2))
edge = np.minimum.reduce([XX - 26, 334 - XX, YY - 2316, 2872 - YY]).astype(float)
plaza &= ~((edge < 22) & (erode + edge / 60 < 0.62))
flags(plaza, 15, FLAG, 21, miss=0.05, crack=1.0)

# enso intarsiato nella piazza: anello di pietra chiara, aperto in alto a destra
cx, cy, R = 180, 2604, 104
ang = (np.degrees(np.arctan2(YY - cy, XX - cx)) + 360 + 90) % 360   # 0 = in alto, senso orario
dist = np.hypot(XX - cx, YY - cy)
t = ang / 330.0
wid = np.where(t < 1, 4 + 7 * np.sin(np.clip(t, 0, 1) * np.pi) ** 0.6, 0)
ring = (np.abs(dist - R) < wid) & (ang > 18) & (ang < 345) & plaza
flags(ring, 15, PALE, 21, miss=0.03, crack=0.5, moss=0.7)
# sporcizia sopra l'enso (muschio a macchie)
dirt = ring & (fbm(91, (16, 8, 4), (0.5, 0.3, 0.2)) > 0.66)
C[dirt] = PALE[1]

# sentiero dei pellegrini, dalla piazza fino al tempio
PATH = [(180, 2330), (176, 2200), (126, 2070), (128, 1930), (196, 1820), (232, 1690),
        (236, 1560), (232, 1440), (204, 1350), (186, 1240), (182, 1080), (150, 960),
        (148, 860), (178, 760), (182, 650), (180, 566)]
pm = path_mask(PATH, 26) & ~plaza
pm &= ~((fbm(61, (16, 8), (0.6, 0.4)) > 0.7) & ~path_mask(PATH, 14))
flags(pm, 8, FLAG, 31, miss=0.1, crack=0.6)

# strada trasversale in citta'
rd = path_mask([(-20, 2004), (120, 1996), (250, 2010), (380, 2000)], 20)
rd &= ~((fbm(63, (16, 8), (0.6, 0.4)) > 0.62))
slabs(rd & ~pm, 12, 8, STONE, 0.2, 33, crack=1.0)

# ---------------- 3. fiume ----------------
rc = 1500 + 46 * np.sin(XX / 70.0) - (XX - 180) * 0.32
rw = 30 + 6 * np.sin(XX / 33.0 + 1)
river = np.abs(YY - rc) < rw
bank = (np.abs(YY - rc) < rw + 4) & ~river
C[bank] = EARTH[1]
bank_hi = (np.abs(YY - (rc - rw - 2)) < 1.2)
C[bank_hi] = EARTH[4]
wv = fbm(71, (48, 24, 12), (0.5, 0.3, 0.2))
C[river] = WATER[q(wv * 0.9, 4)][river]
rip = river & (((YY + (3 * np.sin(XX / 6.0)).astype(int)) % 7) == 0) & (hsh(XX // 9, YY // 7, 3) > 0.45)
C[rip] = WATER[3] + 18
# riflessi del tramonto: trattini caldi
r = np.random.default_rng(17)
ys, xs = np.nonzero(river & (np.abs(YY - rc) < rw - 6))
for i in r.choice(len(ys), 160, replace=False):
    x, y = xs[i], ys[i]
    L = r.integers(2, 7)
    col = hx('#d68a5e') if r.random() > 0.3 else hx('#f2b47c')
    for k in range(L):
        if x + k < W and river[y, x + k]:
            C[y, x + k] = col * 0.85 + C[y, x + k] * 0.15
# canne lungo le rive
ys, xs = np.nonzero(bank)
for i in r.choice(len(ys), 260, replace=False):
    x, y = xs[i], ys[i]
    for k in range(r.integers(2, 5)):
        if y - k >= 0:
            C[y - k, x] = LEAF[4] if k < 2 else LEAF[5]

# ---------------- 4. terrazze coltivate ----------------
for ty0, ty1, gold in [(1110, 1186, False), (1192, 1266, True), (1272, 1330, False), (1030, 1104, True)]:
    band = (YY >= ty0) & (YY < ty1) & ~pm
    soil = band & (((YY - ty0) % 6) >= 3)
    crop = band & (((YY - ty0) % 6) < 3)
    C[soil] = EARTH[1]
    cc = lut(['#273c36', '#33493d', '#76683f', '#8e7a48']) if gold else lut(['#1b302f', '#223b37', '#2b483f', '#355448'])
    v = fbm(ty0, (24, 12, 4), (0.4, 0.3, 0.3))
    C[crop] = cc[q(v, 4)][crop]
    C[band & (((XX + (YY // 6) * 3) % 4) == 0) & crop] = cc[0]

# ---------------- 5. giardino zen (sabbia rastrellata) ----------------
gz = np.zeros((H, W), bool)
gz[338:470, 20:146] = True
rocks = [(52, 380, 9), (110, 430, 6), (92, 366, 4)]
dmin = np.full((H, W), 999.0)
for x, y, rr in rocks:
    dmin = np.minimum(dmin, np.hypot(XX - x, (YY - y) * 1.1) - rr)
lines = np.where(dmin < 22, (dmin.astype(int) % 4) == 0, ((YY - 338) % 4) == 0)
C[gz] = SAND[1]
C[gz & lines] = SAND[0]
C[gz & ((YY - 338) % 4 == 1) & (dmin >= 22)] = SAND[2]
C[gz & (dmin < 22) & (dmin.astype(int) % 4 == 1)] = SAND[2]

# ---------------- oggetti (prima le ombre, poi i corpi) ----------------
SHV = np.array([0.5, 0.95])   # ombra per unita' di altezza (x, y)
shadow = np.zeros((H, W), bool)
objs = []

def shadow_poly(pts):
    im = newmask()
    ImageDraw.Draw(im).polygon([tuple(p) for p in pts], fill=255)
    return m_of(im)

def hull(pts):
    pts = sorted(set(map(tuple, pts)))
    def cr(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
    lo, up = [], []
    for p in pts:
        while len(lo) >= 2 and cr(lo[-2], lo[-1], p) <= 0: lo.pop()
        lo.append(p)
    for p in reversed(pts):
        while len(up) >= 2 and cr(up[-2], up[-1], p) <= 0: up.pop()
        up.append(p)
    return lo[:-1] + up[:-1]

class Block:
    """Blocco estruso: impronta (x, y, w, d) a terra, alto h. broken = cima spezzata a gradini."""
    def __init__(s, x, y, w, d, h, broken=0.0, seed=0, top=STONE, face=STONE, vines=0.3, roof=None, thick=0):
        s.x, s.y, s.w, s.d, s.h, s.thick = x, y, w, d, h, thick
        s.seed, s.top, s.face, s.vines, s.roof = seed, top, face, vines, roof
        r = np.random.default_rng(seed)
        s.hc = np.full(w, h, int)
        if broken > 0:
            k = 0
            while k < w:
                run = r.integers(2, 6)
                drop = int(h * broken * r.random()) if r.random() < 0.6 else 0
                s.hc[k:k + run] = max(2, h - drop)
                k += run
        s.ybase = y + d
    def cast(s):
        m = np.zeros((H, W), bool)
        for k in range(s.w):
            hh = s.hc[k]
            x = s.x + k
            pts = [(x, s.y), (x + 1, s.y), (x + 1, s.y + s.d), (x, s.y + s.d)]
            off = SHV * hh
            if s.thick:
                pts = [(px + off[0], py + off[1]) for px, py in pts]
            else:
                pts = hull(pts + [(px + off[0], py + off[1]) for px, py in pts])
            m |= shadow_poly(pts)
        return m
    def draw(s):
        r = np.random.default_rng(s.seed + 1)
        for k in range(s.w):
            x = s.x + k
            if not 0 <= x < W:
                continue
            hh = s.hc[k]
            t0, t1 = s.y - hh, s.y + s.d - hh          # faccia superiore
            f0, f1 = s.y + s.d - hh, s.y + s.d          # faccia sud
            if s.thick:
                f1 = f0 + s.thick
            for y in range(max(t0, 0), min(t1, H)):
                c = s.top[3] if (y + x // 3) % 5 else s.top[2]
                if y == t0 or (k > 0 and s.hc[k - 1] < hh and y < t0 + 2):
                    c = RIM * 0.8 + s.top[-1] * 0.2       # bordo illuminato dal tramonto
                if k == 0 or k == s.w - 1:
                    c = s.top[2] if y != t0 else c
                C[y, x] = c
            for y in range(max(f0, 0), min(f1, H)):
                ly = y - f0
                c = s.face[1]
                if ly % 3 == 2 or ((x + (ly // 3) * 3) % 7 == 0):
                    c = s.face[0]
                if ly == 0:
                    c = s.face[2]
                C[y, x] = c
            # rampicanti che scendono dalla cima
            if r.random() < s.vines * 0.25:
                L = r.integers(1, max(2, s.h))
                for y in range(max(f0, 0), min(f0 + L, f1, H)):
                    C[y, x] = LEAF[3] if (y + x) % 3 else LEAF[4]
            if f1 <= H and 0 < f1:
                C[f1 - 1, x] = s.face[0]
        if s.roof == 'solar':
            draw_panels(s.x + 3, s.y - s.h + 3, s.w - 6, s.d - 6)

def draw_panels(x, y, w, d):
    pw, ph = 7, 5
    for py in range(y, y + d - ph + 1, ph + 2):
        for px in range(x, x + w - pw + 1, pw + 1):
            for yy in range(py, py + ph):
                for xx in range(px, px + pw):
                    if 0 <= xx < W and 0 <= yy < H:
                        c = hx('#1a2444')
                        if (xx - px) % 3 == 2 or yy == py + ph - 1:
                            c = hx('#2c3c66')
                        if yy == py:
                            c = hx('#5a6f9a')
                        C[yy, xx] = c
            if 0 <= px + 1 < W and 0 <= py + 1 < H:
                C[py + 1, px + 1] = hx('#c7a37a')   # riflesso del sole

class Tree:
    def __init__(s, cx, cy, r, seed, hgt=None, pal=None):
        s.cx, s.cy, s.r, s.seed = cx, cy, r, seed
        s.pal = pal if pal is not None else (PINE if seed % 3 == 0 else LEAF)
        g = np.random.default_rng(seed)
        n = 5 + int(r / 6)
        s.blobs = [(cx, cy, r * 0.62)]
        for i in range(n):
            a = g.random() * 6.283
            dd = g.random() * r * 0.42
            s.blobs.append((cx + np.cos(a) * dd, cy + np.sin(a) * dd * 0.9, r * (0.32 + g.random() * 0.25)))
        s.hgt = hgt if hgt else r * 1.1
        s.ybase = cy + r * 0.5
    def field(s, ox=0, oy=0):
        x0, x1 = int(s.cx - s.r * 1.2 + min(ox, 0)) - 2, int(s.cx + s.r * 1.2 + max(ox, 0)) + 2
        y0, y1 = int(s.cy - s.r * 1.2 + min(oy, 0)) - 2, int(s.cy + s.r * 1.2 + max(oy, 0)) + 2
        x0, y0, x1, y1 = max(x0, 0), max(y0, 0), min(x1, W), min(y1, H)
        yy, xx = np.mgrid[y0:y1, x0:x1]
        best = np.full(yy.shape, 9.0); nx = np.zeros(yy.shape); ny = np.zeros(yy.shape)
        for bx, by, br in s.blobs:
            dx = (xx - bx - ox) / br; dy = (yy - by - oy) / br
            d = np.hypot(dx, dy)
            upd = d < best
            best[upd] = d[upd]; nx[upd] = dx[upd]; ny[upd] = dy[upd]
        return (y0, y1, x0, x1), best, nx, ny
    def cast(s):
        m = np.zeros((H, W), bool)
        off = SHV * s.hgt
        (y0, y1, x0, x1), best, _, _ = s.field(off[0], off[1])
        m[y0:y1, x0:x1] = best < 1.0
        return m
    def draw(s):
        (y0, y1, x0, x1), best, nx, ny = s.field()
        inside = best < 1.0
        nz = np.sqrt(np.clip(1 - nx ** 2 - ny ** 2, 0, 1))
        L = np.array([-0.4, -0.75, 0.55]); L /= np.linalg.norm(L)
        sh = nx * L[0] + ny * L[1] + nz * L[2]
        yy, xx = np.mgrid[y0:y1, x0:x1]
        leaf = hsh(xx // 2, yy // 2, s.seed) - 0.5
        v = np.clip((sh + 0.35) / 1.25 + leaf * 0.22, 0, 1)
        idx = np.clip(np.floor(v * 5 + BAY[y0:y1, x0:x1]), 0, 5).astype(int)
        col = s.pal[idx]
        rim = inside & (sh > 0.8) & (best > 0.74)
        col[rim] = RIM * 0.7 + s.pal[5] * 0.3
        # contorno scuro
        pad = np.pad(inside, 1)
        ring = (~inside) & (pad[:-2, 1:-1] | pad[2:, 1:-1] | pad[1:-1, :-2] | pad[1:-1, 2:])
        sub = C[y0:y1, x0:x1]
        sub[inside] = col[inside]
        sub[ring] = LINE

class Roof:
    """Tetto a padiglione visto dall'alto, sollevato di h. Facce: nord chiara, sud scura."""
    def __init__(s, x, y, w, d, h, pal, seed=0, hole=None):
        s.x, s.y, s.w, s.d, s.h, s.pal, s.hole = x, y, w, d, h, pal, hole
        s.ybase = y + d
    def cast(s):
        off = SHV * s.h * 1.4
        pts = [(s.x, s.y), (s.x + s.w, s.y), (s.x + s.w, s.y + s.d), (s.x, s.y + s.d)]
        return shadow_poly(hull(pts + [(a + off[0], b + off[1]) for a, b in pts]))
    def draw(s):
        x0, y0 = s.x, s.y - s.h
        # muro sotto la gronda (facciata sud in ombra)
        for yy in range(s.y + s.d - s.h, s.y + s.d):
            for xx in range(s.x + 4, s.x + s.w - 4):
                if 0 <= yy < H and 0 <= xx < W:
                    C[yy, xx] = RUST[0] if (xx - s.x) % 12 > 1 else hx('#2a1418')
        for yy in range(y0, y0 + s.d):
            for xx in range(x0, x0 + s.w):
                if not (0 <= yy < H and 0 <= xx < W):
                    continue
                dn, ds = yy - y0, y0 + s.d - 1 - yy
                dw, de = xx - x0, x0 + s.w - 1 - xx
                m = min(dn, ds, dw, de)
                if m == dn:
                    c = s.pal[3]; stripe = dn % 3 == 2
                elif m == ds:
                    c = s.pal[1]; stripe = ds % 3 == 2
                elif m == dw:
                    c = s.pal[2]; stripe = dw % 3 == 2
                else:
                    c = s.pal[1]; stripe = de % 3 == 2
                if stripe:
                    c = c * 0.78
                if m == 0:
                    c = s.pal[0]
                ridge = abs(yy - (y0 + s.d // 2)) < 1 and dw > s.d // 2 - 2 and de > s.d // 2 - 2
                if ridge or (dn == dw or dn == de) and m > 0:
                    c = RIM * 0.55 + s.pal[3] * 0.45 if ridge else s.pal[4]
                if (ds == dw or ds == de) and m > 0:
                    c = s.pal[0]
                C[yy, xx] = c
        for (cx, cy) in [(x0, y0), (x0 + s.w - 1, y0), (x0, y0 + s.d - 1), (x0 + s.w - 1, y0 + s.d - 1)]:
            for k in range(3):
                xx = cx + (-k if cx == x0 else k); yy = cy + (-k if cy == y0 else k)
                if 0 <= xx < W and 0 <= yy < H:
                    C[yy, xx] = s.pal[4]
        if s.hole:
            hx0, hy0, hw, hd = s.hole
            r = np.random.default_rng(5)
            for yy in range(hy0, hy0 + hd):
                for xx in range(hx0, hx0 + hw):
                    e = min(yy - hy0, hy0 + hd - 1 - yy, xx - hx0, hx0 + hw - 1 - xx)
                    if e > r.integers(0, 3):
                        C[yy, xx] = hx('#120a16') if (xx + yy) % 5 else hx('#2a1d24')

ROOF = lut(['#1c1d2c', '#2b2d42', '#3a3d58', '#4f5373', '#7b7e9c'])

class Lantern:
    def __init__(s, x, y):
        s.b = Block(x - 3, y - 3, 6, 5, 9, top=STONE, face=STONE, vines=0)
        s.x, s.y, s.ybase = x, y, y + 2
    def cast(s):
        return s.b.cast()
    def draw(s):
        s.b.draw()
        gx, gy = s.x, s.y
        C[gy - 1:gy + 1, gx - 1:gx + 1] = GLOW
    def glow(s):
        d = np.hypot(XX[s.y - 30:s.y + 30, :] - s.x, YY[s.y - 30:s.y + 30, :] - s.y)
        a = np.clip(1 - d / 26, 0, 1) ** 2 * 0.32
        sub = C[s.y - 30:s.y + 30, :]
        sub += (GLOW - sub * 0.4) * a[..., None]

class Torii:
    def __init__(s, cx, y, w):
        s.posts = [Block(cx - w // 2 - 2, y - 2, 4, 4, 24, top=RUST, face=RUST, vines=0),
                   Block(cx + w // 2 - 2, y - 2, 4, 4, 24, top=RUST, face=RUST, vines=0)]
        s.nuki = Block(cx - w // 2 - 5, y - 1, w + 10, 2, 18, top=RUST, face=RUST, vines=0, thick=2)
        s.kasa = Block(cx - w // 2 - 11, y - 2, w + 22, 4, 26, top=RUST, face=RUST, vines=0, thick=3)
        s.kasa.hc[:2] += 2; s.kasa.hc[-2:] += 2
        s.ybase = y + 3
    def cast(s):
        return s.posts[0].cast() | s.posts[1].cast() | s.kasa.cast()
    def draw(s):
        for p in s.posts: p.draw()
        s.nuki.draw(); s.kasa.draw()
        for k in range(s.kasa.w):
            x = s.kasa.x + k
            y = s.kasa.y - s.kasa.hc[k]
            if 0 <= x < W: C[y, x] = hx('#1e1012')

class Pillar:
    """Colonna caduta: cilindro disteso est-ovest."""
    def __init__(s, x, y, L, r):
        s.x, s.y, s.L, s.r = x, y, L, r
        s.ybase = y + r
    def cast(s):
        return shadow_poly(hull([(s.x, s.y - s.r), (s.x + s.L, s.y - s.r), (s.x + s.L, s.y + s.r), (s.x, s.y + s.r),
                                 (s.x + 4, s.y + s.r + 8), (s.x + s.L + 4, s.y + s.r + 8)]))
    def draw(s):
        for yy in range(s.y - s.r, s.y + s.r):
            t = (yy - (s.y - s.r)) / (2 * s.r)
            c = PALE[4] if t < 0.18 else PALE[3] if t < 0.45 else PALE[2] if t < 0.75 else PALE[1]
            for xx in range(s.x, s.x + s.L):
                cc = c * (0.85 if (xx - s.x) % 9 == 0 else 1)
                if (xx - s.x) in (0, s.L - 1): cc = PALE[0]
                C[yy, xx] = cc
        # rottura irregolare a una estremita'
        r = np.random.default_rng(3)
        for yy in range(s.y - s.r, s.y + s.r):
            for k in range(r.integers(0, 5)):
                C[yy, s.x + s.L - 1 - k] = C[yy, s.x + s.L + 2] if s.x + s.L + 2 < W else C[yy, s.x + s.L - 1]
        for k in range(10):
            C[s.y + s.r + r.integers(0, 4), s.x + s.L + r.integers(-2, 8)] = PALE[2]

def room(x, y, w, d, h, seed, gaps=0.3, broken=0.7):
    """Rovina: quattro muri spessi 4 px, con varchi."""
    g = np.random.default_rng(seed)
    out = []
    t = 4
    def seg(x, y, w, d):
        # spezza il muro con varchi
        if w >= d:
            k = 0
            while k < w:
                run = g.integers(8, 26)
                if g.random() > gaps:
                    out.append(Block(x + k, y, min(run, w - k), d, h, broken=broken, seed=int(g.integers(1e6))))
                k += run + (g.integers(4, 10) if g.random() < 0.5 else 0)
        else:
            k = 0
            while k < d:
                run = g.integers(8, 26)
                if g.random() > gaps:
                    out.append(Block(x, y + k, w, min(run, d - k), h, broken=broken, seed=int(g.integers(1e6))))
                k += run + (g.integers(4, 10) if g.random() < 0.5 else 0)
    seg(x, y, w, t); seg(x, y + d - t, w, t); seg(x, y, t, d); seg(x + w - t, y, t, d)
    # pavimento interno: piastrelle scure
    fm = np.zeros((H, W), bool)
    fm[max(y + t, 0):y + d - t, max(x + t, 0):min(x + w - t, W)] = True
    fm &= fbm(seed % 997, (16, 8), (0.6, 0.4)) > 0.38
    slabs(fm, 8, 8, STONE * 0.8, 0.25, seed % 991)
    return out

# ---- arena (fondo) ----
objs += room(-14, 2300, 58, 150, 18, 101)
objs += room(-10, 2520, 46, 120, 14, 102)
objs += room(318, 2330, 60, 120, 16, 103)
objs += room(322, 2600, 50, 170, 20, 104)
objs += [Tree(20, 2470, 24, 1), Tree(344, 2486, 26, 2), Tree(14, 2860, 30, 3), Tree(350, 2810, 22, 4),
         Tree(300, 2316, 18, 5), Tree(46, 2700, 16, 6)]
objs += [Pillar(232, 2452, 56, 6), Pillar(70, 2800, 38, 5)]
# cespugli e alberelli ai bordi della piazza: incorniciano l'arena senza invadere il centro
objs += [Tree(x, y, r, 200 + i, hgt=r * 0.7) for i, (x, y, r) in enumerate(
    [(64, 2296, 10), (110, 2290, 12), (250, 2292, 11), (330, 2440, 12), (10, 2620, 12), (352, 2600, 10),
     (40, 2580, 9), (330, 2700, 13), (300, 2868, 14), (90, 2874, 12), (200, 2878, 10), (8, 2330, 14),
     (130, 2250, 16), (240, 2236, 18), (34, 2208, 20), (330, 2230, 16)])]
objs += [Block(84, 2390, 14, 10, 12, broken=0.5, seed=7, top=PALE, face=PALE, vines=0.4),
         Block(262, 2770, 12, 10, 10, broken=0.5, seed=8, top=PALE, face=PALE, vines=0.4)]
lanterns = [Lantern(152, 2340), Lantern(208, 2340)]

# ---- citta' in rovina ----
objs += room(16, 2080, 92, 76, 16, 111)
objs += room(246, 2060, 100, 90, 18, 112, gaps=0.2)
objs += room(18, 1690, 104, 86, 20, 113)
objs += room(262, 1720, 96, 80, 16, 114)
objs += [Block(250, 1870, 74, 50, 14, seed=115, roof='solar', vines=0.6),
         Block(30, 1880, 64, 58, 12, seed=116, roof='solar', vines=0.6),
         Block(262, 2180, 60, 38, 10, seed=117, roof='solar', vines=0.4)]
objs += [Tree(x, y, r, 20 + i) for i, (x, y, r) in enumerate(
    [(70, 1990, 20), (300, 1960, 18), (20, 1800, 22), (340, 1640, 26), (206, 2120, 16),
     (110, 2210, 14), (60, 1650, 18), (300, 1820, 14), (150, 1780, 12)])]
lanterns += [Lantern(214, 1700), Lantern(254, 1700)]

# ---- fiume: ponte spezzato ----
for k, yy in enumerate(range(1420, 1600, 7)):
    if 1488 <= yy <= 1520:
        continue
    objs.append(Block(222, yy, 28, 7, 5, seed=300 + k, top=STONE, face=STONE, vines=0.1))
objs += [Tree(x, y, r, 40 + i) for i, (x, y, r) in enumerate(
    [(40, 1420, 22), (110, 1450, 16), (320, 1380, 20), (300, 1600, 18), (20, 1590, 16), (150, 1600, 14)])]

# ---- terrazze e bosco ----
for i, yy in enumerate([1104, 1186, 1266, 1330]):
    for xs0, xs1 in [(-4, 166), (198, 364)]:
        objs.append(Block(xs0, yy - 2, xs1 - xs0, 4, 6, broken=0.3, seed=400 + i * 7 + xs0, vines=0.5))
forest = [(30, 980, 26), (90, 930, 22), (60, 870, 30), (20, 790, 22), (100, 790, 18), (40, 700, 24),
          (110, 690, 20), (250, 960, 26), (310, 920, 30), (280, 850, 22), (340, 820, 20), (230, 780, 18),
          (300, 740, 26), (240, 680, 20), (330, 650, 24), (20, 620, 20), (90, 600, 22), (270, 600, 18),
          (340, 1010, 18), (200, 1010, 14), (120, 1000, 12)]
objs += [Tree(x, y, r, 60 + i) for i, (x, y, r) in enumerate(forest)]
# bosco fitto: alberi casuali lontani dal sentiero
pmw = path_mask(PATH, 52)
g = np.random.default_rng(808)
placed = [(x, y, r) for x, y, r in forest]
for _ in range(400):
    x, y, r = int(g.integers(0, W)), int(g.integers(560, 1030)), int(g.integers(9, 22))
    if pmw[y, x] or any((x - a) ** 2 + (y - b) ** 2 < (r + c) ** 2 * 0.55 for a, b, c in placed):
        continue
    placed.append((x, y, r))
    objs.append(Tree(x, y, r, 600 + len(placed)))

# ---- tempio ----
# scalinata
for k, yy in enumerate(range(474, 566, 6)):
    objs.append(Block(164, yy, 32, 6, 3, seed=500 + k, top=STONE, face=STONE, vines=0.05))
# muro di cinta con varco
objs.append(Block(4, 326, 150, 6, 10, broken=0.4, seed=510, vines=0.6))
objs.append(Block(206, 326, 150, 6, 10, broken=0.4, seed=511, vines=0.6))
objs.append(Torii(180, 508, 36))
objs.append(Roof(90, 150, 180, 120, 12, ROOF, hole=(224, 166, 30, 26)))
objs.append(Tree(240, 176, 18, 90, hgt=26))      # albero cresciuto dentro il tetto crollato
objs += [Roof(26, 80, 52, 52, 22, ROOF), Roof(33, 87, 38, 38, 30, ROOF), Roof(40, 94, 24, 24, 38, ROOF)]
objs += [Tree(310, 110, 40, 91), Tree(320, 250, 22, 92), Tree(40, 260, 20, 93), Tree(196, 60, 26, 94),
         Tree(110, 40, 22, 95)]
lanterns += [Lantern(156, 330), Lantern(204, 330), Lantern(150, 410), Lantern(210, 410), Lantern(156, 470),
             Lantern(204, 470)]
# cortile del tempio lastricato
cm = np.zeros((H, W), bool); cm[280:326, 70:290] = True
cm |= path_mask([(180, 290), (180, 470)], 30)
cm &= ~gz
slabs(cm, 12, 8, STONE, 0.06, 520, crack=0.4)

objs += lanterns

# ---------------- ombre ----------------
for o in objs:
    shadow |= o.cast()
shadow &= ~(YY < 0)
tint = hx('#100818')
C[shadow] = C[shadow] * 0.52 + tint * 0.48

# ---------------- corpi, dal fondo verso l'alto (chi e' piu' in basso copre) ----------------
for o in sorted(objs, key=lambda o: o.ybase):
    o.draw()

# ---------------- atmosfera ----------------
# ombre di nuvole che passano
cl = fbm(201, (160, 80, 40), (0.55, 0.3, 0.15))
cs = np.clip((cl - 0.55) * 5, 0, 1) * 0.22
C *= (1 - cs)[..., None]
# luce calda del tramonto, piu' forte verso il tempio
warm = hx('#ff9a62')
k = (0.09 + 0.08 * (1 - YY / H))[..., None]
C = C * (1 - k) + warm * k * (C.mean(axis=2, keepdims=True) / 90 + 0.3)
for l in lanterns:
    l.glow()
# bordi laterali piu' scuri: l'azione resta al centro
vx = np.clip(1 - np.minimum(XX, W - 1 - XX) / 34, 0, 1) ** 2 * 0.28
C *= (1 - vx)[..., None]

Image.fromarray(np.clip(C, 0, 255).astype(np.uint8), 'RGB').save(OUT)
print('ok', OUT)
