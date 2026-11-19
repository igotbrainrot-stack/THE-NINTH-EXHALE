#!/usr/bin/env python3
"""Two original 07.7 location loops from synthesis, no borrowed samples."""
from pathlib import Path
import numpy as np,wave,subprocess
ROOT=Path(__file__).resolve().parents[2]
RATE=22050

def compose(name,bpm,roots,seed,wet):
    bars=8;beat=60.0/bpm;n=int(bars*4*beat*RATE)
    out=np.zeros(n,dtype=np.float64);rng=np.random.default_rng(seed)
    def add(t0,dur,signal):
        i=int(t0*RATE);length=min(len(signal),n-i,int(dur*RATE));
        if length>0:out[i:i+length]+=signal[:length]
    def synth(f,t0,dur,vol=0.05,detune=0.0):
        size=int(dur*RATE);t=np.arange(size)/RATE
        env=(1-np.exp(-70*t))*np.exp(-2.6*t/max(dur,0.01))
        sig=np.sin(2*np.pi*f*t)+.2*np.sin(2*np.pi*2.01*f*t)+.1*np.sin(2*np.pi*3.03*f*t)
        if detune:sig+=.4*np.sin(2*np.pi*(1+detune)*f*t)
        add(t0,dur,vol*sig*env)
    def beat_sound(t0,kind):
        dur=0.20 if kind=='kick' else .13
        t=np.arange(int(dur*RATE))/RATE
        if kind=='kick':
            freq=43+105*np.exp(-20*t)
            sig=np.sin(2*np.pi*np.cumsum(freq)/RATE)*np.exp(-21*t)*.20
        elif kind=='snare':
            sig=rng.normal(0,1,len(t))*np.exp(-37*t)*.05
        else:
            sig=rng.normal(0,1,len(t))*np.exp(-75*t)*.014
        add(t0,dur,sig)
    for b in range(bars):
        t=b*4*beat;root=roots[(b//2)%len(roots)]
        for o in [0,2.2]: beat_sound(t+o*beat,'kick')
        for o in [1,3]: beat_sound(t+o*beat,'snare')
        for o in np.arange(0,4,0.5):beat_sound(t+o*beat,'hat')
        for off,mult in [(0,1),(1.5,1.5),(3,1.125)]:synth(root*mult,t+off*beat,1.0*beat,.080 if not wet else .065)
        for off,semi in [(0.75,7),(2.75,10)]:
            synth(root*4*2**(semi/12),t+off*beat,.6*beat,.022,0.005)
    hiss=rng.normal(0,1,n)
    out+=np.convolve(hiss,np.ones(13)/13,'same')*.004
    out=np.tanh(out*1.3)*.59
    fade=int(.012*RATE);out[:fade]*=np.linspace(0,1,fade);out[-fade:]*=np.linspace(1,0,fade)
    pcm=np.stack([out,np.roll(out,127)*.97],axis=1)
    wpath=ROOT/'art/tools/.tmp_077.wav'
    with wave.open(str(wpath),'wb') as wav:
        wav.setnchannels(2);wav.setsampwidth(2);wav.setframerate(RATE)
        wav.writeframes((pcm*32767).astype('<i2').tobytes())
    dest=ROOT/'assets/music'/name
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(wpath),'-c:a','libvorbis','-q:a','4',str(dest)],check=True)
    wpath.unlink()
    print(dest.name,'%.1f s' % (n/RATE))

compose('orchard_wet_lattice_077.ogg',83,[47.0,52.6,42.0,55.0],7711,True)
compose('barracks_order_zero_077.ogg',103,[41.2,46.2,38.9,51.9],7722,False)
