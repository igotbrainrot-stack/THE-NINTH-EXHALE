"""Deterministically generate seven ORIGINAL public-domain-by-author-claim service-machine sounds.
No sampled game audio, instruments, voices or copyrighted material.
Run `python3 art/tools/generate_sfx_066.py` from anywhere.
"""
from pathlib import Path
import wave, math, random, struct
OUT = Path(__file__).resolve().parents[2] / "assets" / "audio"
OUT.mkdir(parents=True, exist_ok=True)
RATE = 22050

def render(name, duration, frequencies, noise=0.0, tumble=0.0, volume=0.44):
    rng=random.Random(name)
    raw=bytearray()
    for i in range(int(RATE*duration)):
        t=i/RATE
        decay=math.exp(-5.2*t/max(duration,0.02))
        attack=min(1.0,t/0.008)
        phase=2*math.pi*(frequencies[0]*t + tumble*t*t)
        tone=(math.sin(phase) + 0.35*math.sin(2*math.pi*frequencies[1]*t))/1.35
        hiss=rng.uniform(-1,1)
        v=max(-1,min(1,volume*(tone*(1-noise)+hiss*noise)*decay*attack))
        raw+=struct.pack('<h',round(v*32767))
    with wave.open(str(OUT/name),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(RATE);f.writeframes(raw)

render('pressure_warning.wav',0.38,(490,750),noise=0.11,tumble=170,volume=0.50)
render('metal_hit.wav',0.25,(245,795),noise=0.55,tumble=-240,volume=0.57)
render('covenant_fire.wav',0.27,(128,650),noise=0.72,tumble=-440,volume=0.76)
render('coil_fire.wav',0.46,(70,330),noise=0.64,tumble=-90,volume=0.81)
render('nail_fire.wav',0.10,(330,830),noise=0.46,tumble=-300,volume=0.69)
render('choir_fire.wav',0.36,(530,720),noise=0.19,tumble=-230,volume=0.60)
render('mechanical_reload.wav',0.28,(370,875),noise=0.42,tumble=125,volume=0.41)
render('valve_steam.wav',0.65,(130,290),noise=0.84,tumble=-25,volume=0.48)
print(f'Wrote 8 deterministic original sounds to {OUT}')
