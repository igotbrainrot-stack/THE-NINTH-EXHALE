#!/usr/bin/env python3
"""Small original deterministic service danger sounds for the source build.
These are original fallback effects. Runway generations are external references.
"""
from pathlib import Path
from math import pi, sin, exp
import random
import wave
import array

ROOT=Path(__file__).resolve().parents[2]
SAMPLE_RATE=22050

def make(name,kind,seed):
    rng=random.Random(seed)
    n=int(SAMPLE_RATE*.75)
    samples=array.array('h')
    previous=0.0
    for i in range(n):
        t=i/SAMPLE_RATE
        env=(min(1,t/.028)*exp(-t*(4.9 if kind=='arc' else 3.5)))
        if kind=='arc':
            carrier=sin(2*pi*(230+1100*t)*t)+0.28*sin(2*pi*127*t)
            noise=(rng.random()*2-1)*0.65
        elif kind=='reed':
            carrier=.70*sin(2*pi*187*t)*sin(2*pi*6.5*t)+.55*sin(2*pi*374*t)
            noise=(rng.random()*2-1)*0.18
        else:
            carrier=.50*sin(2*pi*58*t)+0.35*sin(2*pi*115*t)
            noise=(rng.random()*2-1)*0.6
        previous=0.14*previous + 0.86*(carrier+noise)
        samples.append(max(-32767,min(32767,int(15000*env*previous))))
    destination=ROOT/'assets/audio'/name
    with wave.open(str(destination),'wb') as out:
        out.setnchannels(1);out.setsampwidth(2);out.setframerate(SAMPLE_RATE)
        out.writeframes(samples.tobytes())
    return destination

if __name__=='__main__':
    for name,kind,seed in [('arc_discharge_079.wav','arc',7901),('forge_exhaust_079.wav','steam',7902),('basilica_reed_079.wav','reed',7903)]:
        f=make(name,kind,seed)
        print(f.relative_to(ROOT))
