# snd_siren: sirena d'allarme (stile antiaereo: sale, resta, scende), generata dal codice: nessun file di terzi.
# Il file e' un giro intero e si ripete senza scatti: la fase finisce dove comincia.
import numpy as np, wave
sr = 44100
P = 4.8                                     # un giro: sale 1,6 s, resta 0,8 s, scende 2,4 s
n = int(P * sr)
t = np.arange(n) / sr
def shape(t):
    u = np.zeros_like(t)
    a = t < 1.6; u[a] = 0.5 - 0.5 * np.cos(np.pi * t[a] / 1.6)
    b = (t >= 1.6) & (t < 2.4); u[b] = 1
    c = t >= 2.4; u[c] = 0.5 + 0.5 * np.cos(np.pi * (t[c] - 2.4) / 2.4)
    return u
u = shape(t)
f = 300 + 440 * u
cyc = f.sum() / sr
f *= round(cyc) / cyc                        # giri interi in un periodo: il loop non scatta
def tone(f, det):
    ph = 2 * np.pi * np.cumsum(f * det) / sr
    out = np.zeros(n)
    for h in range(1, 8):
        out += np.sin(h * ph) / h ** 1.25
    return out
# due rotori leggermente stonati: il battimento meccanico della sirena vera
# (il secondo con giri interi anche lui)
det = 1.012; c2 = (f * det).sum() / sr; det *= round(c2) / c2
x = tone(f, 1.0) + 0.7 * tone(f, det)
x *= 0.35 + 0.65 * u ** 0.7                 # piu' forte in cima
# passa basso morbido (taglia lo stridio) in frequenza, circolare
X = np.fft.rfft(x); fr = np.fft.rfftfreq(n, 1 / sr)
X *= 1 / (1 + (fr / 2600) ** 4)
x = np.fft.irfft(X, n)
# lontana: un po' di riverbero circolare (il giro dopo riceve la coda di quello prima)
y = x.copy()
for d, g in ((0.031, 0.5), (0.047, 0.42), (0.071, 0.36), (0.113, 0.3), (0.173, 0.24), (0.29, 0.18)):
    y += g * np.roll(x, int(d * sr))
y = y / np.abs(y).max() * 0.7
# lanciare dalla radice del repo
w = wave.open('shift-jam/sounds/snd_siren/snd_siren.wav', 'wb'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
w.writeframes((y * 32767).astype(np.int16).tobytes()); w.close()
# controllo: la cucitura del loop
print('len', n / sr, 'seam jump', abs(y[0] - y[-1]), 'max step', np.abs(np.diff(y)).max())
