import numpy as np, wave

SR, DUR = 44100, 60.0
N = int(SR * DUR)
rng = np.random.default_rng(7)
OUT = "/sessions/serene-gracious-turing/mnt/outputs/audio"
FREQS = np.fft.rfftfreq(N, 1 / SR)

# Every generator below works on exactly N samples in the frequency domain.
# An inverse FFT of length N is periodic with period N by construction, so the
# loop is sample-perfect with no crossfade and no seam. Anything added in the
# time domain (raindrops, fire crackle) is wrapped around the boundary to
# preserve that property.

def noise(exponent):
    spec = np.fft.rfft(rng.normal(0, 1, N))
    f = FREQS.copy(); f[0] = f[1]
    out = np.fft.irfft(spec / f ** (exponent / 2.0), N)
    return out / np.max(np.abs(out))

def shape(x, lo=None, hi=None):
    spec = np.fft.rfft(x)
    if lo: spec *= (FREQS / lo) ** 2 / (1 + (FREQS / lo) ** 2)
    if hi: spec *= 1 / (1 + (FREQS / hi) ** 2)
    return np.fft.irfft(spec, N)

def transients(count, decay, lo, hi, amp):
    out = np.zeros(N)
    for p, L in zip(rng.integers(0, N, count),
                    rng.integers(int(SR * 0.004), int(SR * decay), count)):
        env = np.exp(-np.linspace(0, 9, L)) * rng.uniform(0.25, 1.0)
        idx = (np.arange(p, p + L)) % N          # wrap, keeping the loop seamless
        out[idx] += rng.normal(0, 1, L) * env
    out = shape(out, lo, hi)
    m = np.max(np.abs(out))
    return out / m * amp if m else out

def lfo(cycles, phase=0.0):
    """Frequency locked to an integer number of cycles per loop, so it repeats."""
    return np.sin(2 * np.pi * cycles * np.arange(N) / N + phase)

def write(name, x):
    x = x / np.max(np.abs(x)) * 0.89
    with wave.open(f"{OUT}/{name}.wav", "w") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"  {name}")

write("rain",        shape(noise(1.0), 300, 9000) * 0.75 + transients(5200, 0.05, 900, 8000, 0.42))
write("ocean",       shape(noise(2.0), hi=1400) * (0.55 + 0.30*lfo(5) + 0.12*lfo(2, 1.7) + 0.06*lfo(1, 0.4)))
write("fireplace",   shape(noise(2.0), hi=900) * 0.8 + transients(900, 0.09, 1200, 6500, 0.55))
write("white_noise", shape(noise(0.0), hi=15000))
write("pink_noise",  noise(1.0))
write("brown_noise", noise(2.0))
