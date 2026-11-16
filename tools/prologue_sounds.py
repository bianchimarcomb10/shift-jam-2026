# Suoni dell'accerchiamento nel prologo, generati dal codice: nessun file di terzi.
#   snd_wind       vento tra le rovine, 12 s, si ripete senza scatti (stereo)
#   snd_swarm      lo sciame: chele che ticchettano e un ronzio da insetti, 6 s, si ripete senza scatti (stereo)
#   snd_heartbeat  un battito cupo (lub-dub), un colpo solo: il gioco lo ripete sempre piu' in fretta (mono)
# I loop sono costruiti "in cerchio": rumore fatto in frequenza, toni con giri interi, grani che girano
# attorno alla fine del file. Cosi' l'ultimo campione si attacca al primo.
# Uso: python3 tools/prologue_sounds.py CARTELLA   (dalla radice del repo: python3 tools/prologue_sounds.py shift-jam/sounds)
import sys, os, wave
import numpy as np

sr = 44100
rng = np.random.default_rng(1116)
OUT = sys.argv[1] if len(sys.argv) > 1 else '.'

def save(name, x):
    """x: (n,) mono o (n, 2) stereo, gia' normalizzato. Scrive CARTELLA/nome/nome.wav se la cartella del suono c'e', se no CARTELLA/nome.wav"""
    path = os.path.join(OUT, name, name + '.wav') if os.path.isdir(os.path.join(OUT, name)) else os.path.join(OUT, name + '.wav')
    ch = 1 if x.ndim == 1 else 2
    w = wave.open(path, 'wb'); w.setnchannels(ch); w.setsampwidth(2); w.setframerate(sr)
    w.writeframes((np.clip(x, -1, 1) * 32767).astype('<i2').tobytes()); w.close()
    print(name, round(len(x) / sr, 3), 's,', ch, 'canali ->', path)

def noise_fft(n, shape):
    """rumore circolare (si ripete senza scatti) con lo spettro dato da shape(frequenze)"""
    fr = np.fft.rfftfreq(n, 1 / sr)
    mag = shape(np.maximum(fr, 1.0)); mag[0] = 0
    X = mag * np.exp(2j * np.pi * rng.random(len(fr)))
    x = np.fft.irfft(X, n)
    return x / np.sqrt((x ** 2).mean())

def lfo(n, cycles, depth=1.0):
    """curva lenta e liscia con giri interi nel file: somma di sinusoidi a fase casuale"""
    t = np.arange(n) / n
    y = np.zeros(n)
    for c in cycles:
        y += np.sin(2 * np.pi * c * t + rng.random() * 2 * np.pi) / c
    y /= np.abs(y).max()
    return y * depth

def band(fc, q):
    return lambda f: 1 / np.sqrt(1 + (q * (f / fc - fc / f)) ** 2)

# ---------- VENTO ----------
# rumore che passa per un filtro risonante che si sposta (il fischio sale con le raffiche), piu' un rombo sotto.
# Il filtro cambia nel tempo: lavoro a finestre sovrapposte, in cerchio, cosi' il loop resta senza scatti.
n = 12 * sr
def moving_band(x, fc, q, g, N=2048, hop=512):
    win = np.sqrt(np.hanning(N + 1)[:N])
    out = np.zeros(n)
    fr = np.maximum(np.fft.rfftfreq(N, 1 / sr), 1)
    for k in range(n // hop):
        idx = (k * hop + np.arange(N)) % n
        c = (k * hop + N // 2) % n
        X = np.fft.rfft(x[idx] * win) * band(fc[c], q[c])(fr) * g[c]
        out[idx] += np.fft.irfft(X, N) * win
    return out / 2
def wind_ch(seed_shift):
    u = 0.5 + 0.5 * lfo(n, [1, 2, 3, 5])                                                     # raffiche (0..1)
    u = np.roll(u, seed_shift)
    pink = noise_fft(n, lambda f: 1 / np.sqrt(f))
    gust = moving_band(pink, 260 * 2 ** (1.7 * u), 1.2 + 2.5 * u, 0.35 + 0.65 * u ** 1.5)    # 260 -> 850 Hz
    rumble = noise_fft(n, lambda f: 1 / (1 + (f / 90) ** 4)) * (0.7 + 0.3 * u)               # rombo sotto i 90 Hz
    return gust / np.sqrt((gust ** 2).mean()) + 0.6 * rumble
L, R = wind_ch(0), wind_ch(int(0.7 * sr))
wind = np.stack([0.8 * L + 0.2 * R, 0.2 * L + 0.8 * R], 1)
wind = wind / np.abs(wind).max() * 0.5

# ---------- SCIAME ----------
n = 6 * sr
sw = np.zeros((n, 2))
hi = noise_fft(n, band(3800, 1.6))          # il materiale dei ticchettii (chele, mandibole)
mid = noise_fft(n, band(1300, 2.5))         # le zampe sul terreno
def grain(src, at, dur, amp, pan, decay):
    m = int(dur * sr)
    idx = (at + np.arange(m)) % n
    env = np.exp(-np.arange(m) / (decay * sr)) * (1 - np.exp(-np.arange(m) / (0.0004 * sr)))
    g = src[(int(rng.integers(n)) + np.arange(m)) % n] * env * amp
    sw[idx, 0] += g * np.sqrt(1 - pan); sw[idx, 1] += g * np.sqrt(pan)
# trilli di chele: 3-7 scatti ravvicinati
for _ in range(260):
    at = int(rng.integers(n)); pan = rng.random(); a = rng.uniform(0.3, 1.0)
    gap = rng.uniform(0.018, 0.04)
    for k in range(int(rng.integers(3, 8))):
        grain(hi, at + int(k * gap * sr * rng.uniform(0.85, 1.15)), 0.02, a * rng.uniform(0.6, 1), pan, rng.uniform(0.002, 0.005))
# zampette: tanti tocchi leggeri
for _ in range(900):
    grain(mid, int(rng.integers(n)), 0.03, rng.uniform(0.1, 0.35), rng.random(), 0.006)
# ronzio: voci a dente di sega con ali che battono, filtrate come un insetto
t = np.arange(n) / sr
buzz = np.zeros((n, 2))
for v in range(7):
    f0 = round(rng.uniform(150, 260) * 6) / 6                 # giri interi in 6 s
    vib = 3 * np.sin(2 * np.pi * round(rng.uniform(4, 9) * 6) / 6 * t + rng.random() * 6)
    ph = 2 * np.pi * np.cumsum(f0 + vib) / sr
    ph *= round(ph[-1] / (2 * np.pi)) * 2 * np.pi / ph[-1]     # chiusura del giro
    saw = np.zeros(n)
    for h in range(1, 14):
        saw += np.sin(h * ph) / h
    am = 0.5 + 0.5 * np.clip(lfo(n, [1, 2, 3]), 0, None)       # ogni voce va e viene
    pan = rng.random()
    buzz[:, 0] += saw * am * np.sqrt(1 - pan); buzz[:, 1] += saw * am * np.sqrt(pan)
for c in range(2):                                             # forma da insetto: risonanze a 900 e 2200 Hz
    X = np.fft.rfft(buzz[:, c]); fr = np.maximum(np.fft.rfftfreq(n, 1 / sr), 1)
    X *= band(900, 3)(fr) + 0.6 * band(2200, 4)(fr)
    buzz[:, c] = np.fft.irfft(X, n)
buzz /= np.abs(buzz).max()
sw /= np.abs(sw).max()
swarm = sw * 0.8 + buzz * 0.32
swarm = swarm / np.abs(swarm).max() * 0.7

# ---------- BATTITO ----------
def thump(f_hi, f_lo, dur, amp):
    m = int(dur * sr); tt = np.arange(m) / sr
    f = f_lo + (f_hi - f_lo) * np.exp(-tt / 0.03)
    ph = 2 * np.pi * np.cumsum(f) / sr
    env = (1 - np.exp(-tt / 0.003)) * np.exp(-tt / (dur / 4))
    x = np.sin(ph) * env
    x = np.tanh(2.2 * x) / np.tanh(2.2)                       # un po' saturo: si sente anche dalle casse piccole
    return x * amp
beat = np.zeros(int(0.6 * sr))
lub = thump(95, 48, 0.22, 1.0); dub = thump(110, 56, 0.16, 0.7)
beat[:len(lub)] += lub
o = int(0.17 * sr); beat[o:o + len(dub)] += dub
beat = beat / np.abs(beat).max() * 0.8

save('snd_wind', wind)
save('snd_swarm', swarm)
save('snd_heartbeat', beat)
for nm, x in (('vento', wind), ('sciame', swarm)):
    print(nm, 'salto alla cucitura', np.abs(x[0] - x[-1]).max().round(4), 'passo massimo', np.abs(np.diff(x, axis=0)).max().round(4))
