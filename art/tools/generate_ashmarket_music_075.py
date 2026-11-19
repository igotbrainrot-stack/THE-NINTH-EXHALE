#!/usr/bin/env python3
"""Original procedural noir-phonk instrumental loop for Ashmarket.
No samples, vocals, borrowed melody, or recording of existing music.
"""
from pathlib import Path
import numpy as np,wave,subprocess
ROOT=Path(__file__).resolve().parents[2]
rate=22050;bpm=96;beat=60/bpm;bars=8
seconds=bars*4*beat;n=int(seconds*rate)
track=np.zeros(n,dtype=np.float64)
rng=np.random.default_rng(7519)

def tone(freq,t0,dur,vol,warm=0.25,decay=3.0):
    i=int(t0*rate);size=min(int(dur*rate),n-i)
    if size<=0:return
    t=np.arange(size)/rate
    env=(1-np.exp(-70*t))*np.exp(-decay*t)
    wave=np.sin(2*np.pi*freq*t)+warm*np.sin(2*np.pi*freq*2*t)+0.10*np.sin(2*np.pi*freq*3*t)
    track[i:i+size]+=vol*wave*env

def kick(t0):
    i=int(t0*rate);size=min(int(0.28*rate),n-i)
    if size<=0:return
    t=np.arange(size)/rate
    freq=48+110*np.exp(-24*t)
    sig=np.sin(2*np.pi*np.cumsum(freq)/rate)*np.exp(-17*t)
    track[i:i+size]+=0.23*sig

def snare(t0):
    i=int(t0*rate);size=min(int(0.17*rate),n-i)
    if size<=0:return
    t=np.arange(size)/rate
    noise=rng.standard_normal(size)
    sig=0.60*noise+0.4*np.sin(2*np.pi*186*t)
    track[i:i+size]+=0.080*sig*np.exp(-27*t)

def hat(t0):
    i=int(t0*rate);size=min(int(0.09*rate),n-i)
    if size<=0:return
    t=np.arange(size)/rate
    noise=rng.standard_normal(size)
    track[i:i+size]+=0.014*noise*np.exp(-48*t)
# Eight bars, original simple F minor / dark ledger motif and cowbell rhythm.
for bar in range(bars):
    t0=bar*4*beat
    roots=[43.65,51.91,38.89,46.25]
    root=roots[(bar//2)%4]
    for offset in [0,2.25]:kick(t0+offset*beat)
    for offset in [1,3]:snare(t0+offset*beat)
    for offset in np.arange(0,4,0.5):hat(t0+offset*beat)
    for off,dur,mult in [(0,1.35,1),(1.5,.7,1),(2.5,1.2,1.5)]:
        tone(root*mult,t0+off*beat,dur*beat,0.082,0.33,decay=2.2)
    # A muted, uneven low-volume brass counting chime, not stock cowbell samples.
    for off,rel in [(0.75,8),(2.75,7),(3.5,12)]:
        tone(220*2**(rel/12),t0+off*beat,0.27*beat,0.020,0.38,decay=11)
# Analogue hiss + tremolo from synthesized noise only.
noise=rng.standard_normal(n)
smoothed=np.convolve(noise,np.ones(21)/21,'same')
track+=smoothed*0.0045
track=np.tanh(track*1.8)*0.54
# 10ms loop-seam fade; no hard clicks.
fade=int(.012*rate);track[:fade]*=np.linspace(0,1,fade);track[-fade:]*=np.linspace(1,0,fade)
# subtle original stereo early reflection
left=track;right=0.97*np.roll(track,117)+0.03*np.roll(track,1600)
pcm=np.clip(np.stack([left,right],axis=1),-0.95,0.95)
output=ROOT/'assets/music/ashmarket_bonded_hours.ogg'
tmp=ROOT/'art/tools/.ashmarket_075_tmp.wav'
with wave.open(str(tmp),'wb') as w:
    w.setnchannels(2);w.setsampwidth(2);w.setframerate(rate)
    w.writeframes((pcm*32767).astype('<i2').tobytes())
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(tmp),'-c:a','libvorbis','-q:a','4',str(output)],check=True)
tmp.unlink()
print('Written original loop',output,seconds,'sec')
