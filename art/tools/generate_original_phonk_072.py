#!/usr/bin/env python3
"""Deterministic, original, sample-free 8-bar phonk-inspired game music sketches.

These are embedded FALLBACK loops; finished Runway compositions live in the
connected Runway workspace until exported. No recordings, purchased samples,
pre-existing songs, or copyrighted melodies are used.
"""
from pathlib import Path
import numpy as np
import math, subprocess, wave, tempfile

SR=32000
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/music'
OUT.mkdir(parents=True,exist_ok=True)

TRACKS={
    'hearth_night_intake':dict(bpm=90,seed=9021,roots=[41,37,39,36],bass=0.73,drums=0.61,cow=0.22,flavor=0),
    'sootworks_service_debt':dict(bpm=102,seed=4421,roots=[40,43,36,38],bass=0.82,drums=0.74,cow=0.40,flavor=1),
    'basilica_submerged_choir':dict(bpm=78,seed=3390,roots=[38,34,41,36],bass=0.66,drums=0.32,cow=0.17,flavor=2),
    'pressure_breach_combat':dict(bpm=132,seed=7213,roots=[41,39,36,43],bass=0.95,drums=0.97,cow=0.63,flavor=3),
}

def freq(midi):return 440.0*2.0**((midi-69.0)/12.0)

def main():
    for name,cfg in TRACKS.items():
        bpm=cfg['bpm']; beat=60.0/bpm; dur=beat*4*8
        count=round(dur*SR)
        out=np.zeros((count,2),dtype=np.float32)
        rng=np.random.default_rng(cfg['seed'])
        def add(t,signal,pan=0.0,vol=1.0):
            at=round(t*SR)
            if at<0 or at>=count:return
            n=min(len(signal),count-at)
            pan=float(np.clip(pan,-0.9,0.9))
            out[at:at+n,0]+=signal[:n]*vol*(1.0-pan*.28)
            out[at:at+n,1]+=signal[:n]*vol*(1.0+pan*.28)
        # FM organ pad/chord, strictly authored four-chord 8-bar progression.
        for bar in range(8):
            root=cfg['roots'][bar%4]
            chord=[root+12,root+19,root+22 if cfg['flavor']!=2 else root+20]
            for nidx,note in enumerate(chord):
                length=4*beat*.99
                t=np.arange(round(length*SR),dtype=np.float32)/SR
                f=freq(note)
                wobble=(0.018+0.007*nidx)*np.sin(2*np.pi*0.19*t+bar*0.7)
                wave_a=np.sin(2*np.pi*f*t+0.17*np.sin(2*np.pi*(f/2)*t))
                wave_b=np.sin(2*np.pi*(f*0.997)*t)
                env=(1-np.exp(-t*5.0))*(1-np.exp(-(length-t)*3.5))
                texture=(wave_a*.45+wave_b*.45+0.1*np.sin(2*np.pi*f*2*t))*env*(1+wobble)
                add(bar*4*beat,texture,pan=(-.5+nidx*.5),vol=0.075 if cfg['flavor']!=2 else .093)
        # Elastic tuned 808 bass pattern, varied per 8-bar form.
        for bar in range(8):
            root=cfg['roots'][bar%4]
            offsets=[0,0,7,0,0,3,7,0] if cfg['flavor']==3 else [0,0,7,0]
            steps=8 if cfg['flavor']==3 else 4
            for step in range(steps):
                if cfg['flavor']!=3 and step==1 and bar%2:continue
                when=bar*4*beat+step*(4*beat/steps)
                length=0.43 if cfg['flavor']==3 else 0.59
                t=np.arange(round(length*SR),dtype=np.float32)/SR
                pitch=freq(root-12+offsets[step%len(offsets)])
                phase=2*np.pi*pitch*(t+0.008*(1-np.exp(-t*30.0)))
                sig=np.sin(phase)+0.16*np.sin(2*phase)
                decay=np.exp(-t*(3.4 if cfg['flavor']==3 else 2.9))
                add(when,np.tanh(sig*1.5)*decay,pan=-.05,vol=0.26*cfg['bass'])
        # 90s sampled-feel kicks and cracked snare all synthesized from noise.
        for bar in range(8):
            base=bar*4*beat
            kickbeats=[0,2.0,2.75] if cfg['flavor']==3 else ([0,2] if cfg['flavor']!=2 else [0])
            for k in kickbeats:
                t=np.arange(round(.29*SR),dtype=np.float32)/SR
                ph=2*np.pi*(53*t+92*(1-np.exp(-t*24))/24)
                kick=(np.sin(ph)*np.exp(-t*26)+0.28*np.sin(ph/2)*np.exp(-t*11))*0.88
                add(base+k*beat,np.tanh(kick*1.4),vol=.55*cfg['drums'])
            for k in ([1.0,3.0] if cfg['flavor']!=2 else [2.0]):
                t=np.arange(round(.19*SR),dtype=np.float32)/SR
                noise=rng.normal(0,1,len(t)).astype(np.float32)
                smooth=noise-np.convolve(noise,np.ones(19)/19,mode='same')
                sn=(smooth*.50+.13*np.sin(2*np.pi*184*t))*np.exp(-t*25)
                add(base+k*beat,sn,vol=.24*cfg['drums'])
            # closed hats with deterministic swing and slight variation
            count_hats=16 if cfg['flavor']==3 else (8 if cfg['flavor']!=2 else 4)
            for h in range(count_hats):
                note_time=base+(h*4*beat/count_hats)+((h%2)*.013)
                t=np.arange(round(.045*SR),dtype=np.float32)/SR
                noise=rng.normal(0,1,len(t)).astype(np.float32)
                hi=(noise-np.convolve(noise,np.ones(7)/7,mode='same'))*np.exp(-t*100)
                add(note_time,hi,pan=(.20 if h%2 else -.20),vol=(0.055+0.025*(h%4==0))*cfg['drums'])
            # metallic cowbell texture, not a pre-existing riff
            hits=[0.5,2.5] if cfg['flavor']!=2 else [2.5]
            if cfg['flavor']==3:hits=[0.5,1.5,2.5,3.25]
            for h in hits:
                t=np.arange(round(.24*SR),dtype=np.float32)/SR
                tone=(.62*np.sin(2*np.pi*580*t)+.38*np.sin(2*np.pi*840*t))
                env=np.exp(-t*20)
                add(base+h*beat,np.tanh(tone*1.35)*env,pan=0.35 if h>1 else -0.25,vol=cfg['cow']*.13)
        # sparse original clock-chime lead, low in the mix
        for bar in [1,3,5,7]:
            root=cfg['roots'][bar%4]
            for n,degree in enumerate([12,19,15,12] if cfg['flavor']==3 else [12,15,19]):
                when=(bar*4+(n*.75+0.5))*beat
                t=np.arange(round(.42*SR),dtype=np.float32)/SR
                tone=np.sin(2*np.pi*freq(root+degree)*t+0.3*np.sin(2*np.pi*freq(root+degree)*2*t))
                add(when,tone*np.exp(-t*8.3),pan=(-.3+n*.27),vol=0.038)
        # Small groove grit/lowpass tape noise (mathematically generated).
        t=np.arange(count,dtype=np.float32)/SR
        grain=rng.normal(0,.0007,count).astype(np.float32)
        grain*=0.8+0.2*np.sin(2*np.pi*.17*t)
        out[:,0]+=grain
        out[:,1]+=np.roll(grain,26)
        out=np.tanh(out*1.13)
        # Robust end seam for Godot OGG full-file looping.
        fade=min(round(.060*SR),len(out)//8)
        ramp=np.linspace(0,1,fade,dtype=np.float32)
        out[:fade]*=ramp[:,None]
        out[-fade:]*=ramp[::-1,None]
        peak=max(1.0,float(np.max(np.abs(out)))/.88)
        out=(out/peak*32767).astype('<i2')
        with tempfile.TemporaryDirectory() as tmp:
            wav=Path(tmp)/'temp.wav'
            with wave.open(str(wav),'wb') as w:
                w.setnchannels(2);w.setsampwidth(2);w.setframerate(SR);w.writeframes(out.tobytes())
            dest=OUT/(name+'.ogg')
            cmd=['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(wav),'-c:a','libvorbis','-qscale:a','4',str(dest)]
            subprocess.run(cmd,check=True)
        print(f'{name}: {dur:.1f}s, {dest.stat().st_size//1024} KiB')

if __name__=='__main__':main()
