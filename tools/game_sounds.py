# Suoni della partita generati dal codice (17-11), al posto dei segnaposto: nessun file di terzi.
# Sono nello stile degli effetti di Chelios (onde quadre e rumore, salite e discese di tono, alla sfxr).
#   snd_heart       cuore preso: lo scafo si ripara (arpeggio che sale, caldo)
#   snd_powerup     arma speciale presa (razzi, laser, ventaglio): la salita a scalini dei potenziamenti
#   snd_rockets     una salva di razzi: uno sbuffo di rumore che scende, piano
#   snd_drill_full  la trivella e' carica: due rintocchi alti, "pronta"
#   snd_drill_get   la trivella si pianta nel mecha: un colpo di metallo e la punta che prende giri
#   snd_beads       i grani d'oro del boss: campanelli che si sgranano
#   snd_pause       pausa (due note che scendono)
#   snd_resume      si riparte (due note che salgono)
# Tutti mono, 44,1 kHz, 16 bit. Uso, dalla radice del repo: python3 tools/game_sounds.py shift-jam/sounds
import sys, os, wave
import numpy as np

sr = 44100
OUT = sys.argv[1] if len(sys.argv) > 1 else '.'
rng = np.random.default_rng(1117)

def save(name, x, rms_db):
    """porta il suono al volume medio rms_db (misurato sulla parte che suona) e lo scrive"""
    x = x - x.mean()
    act = np.abs(x) > 0.02 * np.abs(x).max()
    rms = np.sqrt((x[act] ** 2).mean())
    x = x * (10 ** (rms_db / 20) / rms)
    pk = np.abs(x).max()
    if pk > 0.95: x *= 0.95 / pk
    # 3 ms di dissolvenza in fondo: niente clic
    f = int(0.003 * sr); x[-f:] *= np.linspace(1, 0, f)
    path = os.path.join(OUT, name, name + '.wav') if os.path.isdir(os.path.join(OUT, name)) else os.path.join(OUT, name + '.wav')
    w = wave.open(path, 'wb'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
    w.writeframes((np.clip(x, -1, 1) * 32767).astype('<i2').tobytes()); w.close()
    print(f'{name:15s} {len(x) / sr:.3f} s  picco {np.abs(x).max():.2f} -> {path}')

def t_(d): return np.arange(int(d * sr)) / sr

def phase(freq):
    """fase (in giri) da una frequenza che puo' cambiare nel tempo"""
    return np.cumsum(np.broadcast_to(freq, freq.shape if np.ndim(freq) else (1,)) / sr)

def square(freq, duty=0.5):
    return np.where((phase(freq) % 1) < duty, 1.0, -1.0)

def tri(freq):
    p = phase(freq) % 1
    return 4 * np.abs(p - 0.5) - 1

def saw(freq):
    return 2 * (phase(freq) % 1) - 1

def sine(freq):
    return np.sin(2 * np.pi * phase(freq))

def pnoise(freq):
    """rumore "a tono" come quello di sfxr: un valore a caso per ogni mezzo giro"""
    p = np.floor(phase(freq) * 2).astype(int)
    vals = rng.uniform(-1, 1, p.max() + 2)
    return vals[p]

def lowpass(x, fc):
    a = np.exp(-2 * np.pi * np.broadcast_to(fc, x.shape) / sr)
    y = np.zeros_like(x); s = 0.0
    for i in range(len(x)):
        s = a[i] * s + (1 - a[i]) * x[i]; y[i] = s
    return y

def env(n, att, dec, sus=0.0, punch=0.0):
    """attacco, tenuta, discesa (in secondi), come sfxr; punch alza l'inizio della tenuta"""
    a, s = int(att * sr), int(sus * sr)
    d = n - a - s
    e = np.concatenate([np.linspace(0, 1, max(a, 1)), np.linspace(1 + punch, 1, max(s, 1)), np.linspace(1, 0, max(d, 1)) ** 1.5])
    return e[:n] if len(e) >= n else np.pad(e, (0, n - len(e)))

def note(f, d, wave_fn, att=0.004, sus=0.0, vib=0.0, vib_hz=6.0, **kw):
    t = t_(d)
    fr = f * (1 + vib * np.sin(2 * np.pi * vib_hz * t))
    return wave_fn(fr, **kw) * env(len(t), att, d - att - sus, sus)

def seq(parts):
    """mette i pezzi uno dopo l'altro; parts = [(inizio_s, segnale), ...]"""
    end = max(int(s * sr) + len(x) for s, x in parts)
    y = np.zeros(end)
    for s, x in parts:
        i = int(s * sr); y[i:i + len(x)] += x
    return y

def hz(n):   # nota MIDI -> Hz
    return 440 * 2 ** ((n - 69) / 12)

# ---------- CUORE: lo scafo si ripara ----------
# La maggiore che sale (La, Do#, Mi, La) in quadra morbida + triangolo, l'ultima nota resta e vibra piano.
parts = []
for i, m in enumerate([69, 73, 76, 81]):
    last = (i == 3)
    d = 0.30 if last else 0.07
    x = 0.6 * note(hz(m), d, tri, sus=0.05 if last else 0.02, vib=0.006 if last else 0) \
      + 0.4 * note(hz(m), d, square, sus=0.05 if last else 0.02, vib=0.006 if last else 0, duty=0.5)
    parts.append((i * 0.06, x))
save('snd_heart', lowpass(seq(parts), 5000), -18.5)

# ---------- ARMA SPECIALE: la salita a scalini ----------
# Quattro salite corte, ognuna parte un po' piu' in alto della precedente (il "repeat" di sfxr).
t = t_(0.42)
step = np.floor(t / 0.09)
fr = 330 * 2 ** (step * 0.25) * (1 + 1.6 * ((t % 0.09) / 0.09))
x = square(fr, 0.3) * env(len(t), 0.003, 0.2, 0.2)
save('snd_powerup', lowpass(x, 7000), -17.5)

# ---------- RAZZI: lo sbuffo ----------
# Rumore che scende di tono (fsss) sopra un colpetto basso che cade.
t = t_(0.24)
hiss = pnoise(3200 * np.exp(-t * 7)) * env(len(t), 0.002, 0.2, 0.02)
thump = square(140 * np.exp(-t * 9), 0.5) * env(len(t), 0.001, 0.08) * 0.5
x = lowpass(hiss, 6000) + np.pad(thump[:int(0.09 * sr)], (0, len(t) - int(0.09 * sr)))
save('snd_rockets', x, -16.0)

# ---------- TRIVELLA CARICA: pronta ----------
# Tre note rapide che salgono, poi un rintocco alto che resta e luccica (quadra sottile + seno un'ottava sopra).
parts = []
for i, m in enumerate([88, 91, 95]):
    parts.append((i * 0.045, 0.5 * note(hz(m), 0.06, square, duty=0.125)))
ring = note(hz(100), 0.42, square, sus=0.08, vib=0.004, vib_hz=11, duty=0.25) * 0.55 \
     + note(hz(112), 0.42, sine, sus=0.05) * 0.35
parts.append((0.135, ring))
save('snd_drill_full', lowpass(seq(parts), 9000), -18.5)

# ---------- TRIVELLA PRESA: colpo di metallo, poi la punta prende giri ----------
d = 1.0
t = t_(d)
clank = (pnoise(np.full(len(t), 2200.0)) * 0.6 + square(np.full(len(t), 310.0), 0.4) * 0.4) * env(len(t), 0.001, 0.12)
clank = lowpass(clank, 4000)
spin_f = 70 * 2 ** (1.9 * np.clip(t / 0.85, 0, 1) ** 1.3)                # da 70 a circa 260 Hz
rot_hz = 8 + 26 * np.clip(t / 0.85, 0, 1)                                    # il giro accelera
rot = 0.6 + 0.4 * np.sin(2 * np.pi * np.cumsum(rot_hz) / sr)
spin = (0.6 * saw(spin_f) + 0.4 * square(spin_f * 2, 0.3)) * rot
spin = lowpass(spin, 2500) * env(len(t), 0.05, 0.25, 0.65)
save('snd_drill_get', 1.1 * clank + spin, -16.0)

# ---------- GRANI D'ORO: campanelli ----------
# Cinque rintocchi brevi, pentatonica alta, in ordine sparso: ogni campanello ha un parziale non armonico.
parts = []
for i, m in enumerate([86, 93, 88, 95, 91]):
    f = hz(m); dd = 0.32
    tt = t_(dd)
    bell = (np.sin(2 * np.pi * f * tt) + 0.35 * np.sin(2 * np.pi * f * 2.76 * tt) * np.exp(-tt * 30)) * np.exp(-tt * 11)
    bell[:int(0.002 * sr)] *= np.linspace(0, 1, int(0.002 * sr))
    parts.append((i * 0.05 + rng.uniform(0, 0.012), bell * (1 - i * 0.08)))
save('snd_beads', seq(parts), -19.0)

# ---------- PAUSA e RIPRESA ----------
save('snd_pause', seq([(0, note(hz(81), 0.06, square, duty=0.5)), (0.065, note(hz(76), 0.09, square, duty=0.5))]), -21.0)
save('snd_resume', seq([(0, note(hz(76), 0.06, square, duty=0.5)), (0.065, note(hz(81), 0.09, square, duty=0.5))]), -21.0)
