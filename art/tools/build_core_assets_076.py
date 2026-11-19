from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np, math, wave, subprocess, json
ROOT=Path(__file__).resolve().parents[2]
T=ROOT/'assets/textures'; T.mkdir(exist_ok=True)
# Both original, seed-stable 512x512 surfaces are generated, not downloaded.
rng=np.random.default_rng(760017)
N=512
im=Image.new('RGB',(N,N))
a=np.zeros((N,N,3),dtype=np.uint8)
for y in range(N):
    for x in range(N):
        c=(84,102,103) if ((x//128 + y//128)%2)==0 else (97,106,99)
        n=int(rng.integers(-8,9))
        a[y,x] = np.clip(np.array(c)+n,0,255)
im=Image.fromarray(a,'RGB');d=ImageDraw.Draw(im)
for x in range(0,N,128):
    d.rectangle((x,0,x+4,N),fill=(40,55,55))
    d.line((x+9,0,x+9,N),fill=(141,137,117),width=2)
for y in range(0,N,128):
    d.rectangle((0,y,N,y+3),fill=(48,58,57))
    d.line((0,y+8,N,y+8),fill=(131,143,135),width=2)
for y in range(64,N,128):
    for x in range(64,N,128):
        d.rectangle((x-6,y-6,x+6,y+6),fill=(42,50,51),outline=(163,148,111),width=2)
        d.ellipse((x-2,y-2,x+2,y+2),fill=(191,179,136))
for _ in range(75):
    x=int(rng.integers(10,N)); y=int(rng.integers(10,N))
    d.line((x,y,x+int(rng.integers(5,23)),y),fill=(155,147,127),width=1)
im.save(T/'core_wall_076.png')

b=np.zeros((N,N,3),dtype=np.uint8)
for y in range(N):
    for x in range(N):
        c=(93,91,83) if ((x//64+y//64)%2)==0 else (104,100,89)
        n=int(rng.integers(-10,11)); b[y,x]=np.clip(np.array(c)+n,0,255)
im=Image.fromarray(b,'RGB');d=ImageDraw.Draw(im)
for k in range(0,N,64):
    d.line((k,0,k,N),fill=(49,58,57),width=4)
    d.line((0,k,N,k),fill=(53,57,52),width=4)
for j in range(0,N,64):
    for k in range(0,N,64):
        if (k//64+j//64)%3==0:
            d.line((k+12,j+18,k+52,j+18),fill=(154,137,111),width=2)
            d.line((k+12,j+24,k+52,j+24),fill=(63,72,66),width=1)
for _ in range(150):
    x=int(rng.integers(0,N));y=int(rng.integers(0,N));r=int(rng.integers(1,7))
    d.ellipse((x,y,x+r,y+r),fill=(73,78,70))
im.save(T/'core_floor_076.png')

source=ROOT/'assets/sprites/enemies_074'
target=ROOT/'assets/sprites/enemies_076'; target.mkdir(parents=True,exist_ok=True)
for face in range(1,9):
    src=Image.open(source/f'edda_machine_{face}.png').convert('RGBA')
    a=np.asarray(src).copy()
    orig=a[...,:3].astype(float)
    # Fixed physically distinct 8-way original texture geometry preserved.
    lum=orig.mean(axis=2)
    # New desaturated cyan/pale-teal enamel/bronze actuator palette.
    out=np.stack([0.66*lum+0.25*orig[...,0],0.80*lum+0.12*orig[...,1],0.75*lum+0.15*orig[...,2]],axis=-1)
    out=np.clip(out+np.array([0,6,8]),0,255).astype(np.uint8)
    a[...,:3]=out
    render=Image.fromarray(a,'RGBA')
    # Thin engraved fixed indicator plate on torso at row 0, if visible.
    # Keep it attached at same local atlas coordinate in each frame.
    draw=ImageDraw.Draw(render,'RGBA')
    for k in range(12):
        fx=(k%4)*192;fy=(k//4)*256
        draw.rectangle((fx+92,fy+69,fx+105,fy+75),fill=(28,44,43,125),outline=(164,137,91,195),width=1)
        draw.rectangle((fx+95,fy+71,fx+98,fy+73),fill=(187,174,110,180))
    render.save(target/f'core_actuator_{face}.png',optimize=True)

# A deterministic original dark phonk/tape ambient bed, no sampled recordings.
# 16 sec, 24 kHz, clear low background level leaves space for action/voices.
sr=24000; seconds=16; t=np.arange(sr*seconds)/sr
# bass 49 Hz, detuned 73.42 Hz; analog filtered sine chord and slight wobble.
sc=np.zeros_like(t)
for hz,volume in [(49.0,.12),(73.416,.075),(146.83,.028),(196.0,.020)]:
    sc+=volume*np.sin(2*np.pi*hz*t+0.035*np.sin(t*1.13))
# restrained industrial subbeat accents at ~90 BPM; gradual in/out envelopes.
beat_len=60/90
for j in range(int(seconds/beat_len)+1):
    start=j*beat_len
    m=(t>=start)&(t<start+.23)
    tt=t[m]-start
    if len(tt):sc[m]+=.16*np.sin(2*np.pi*(64-45*tt)*tt)*np.exp(-tt*20)
    if j%2==1:
        m=(t>=start+.32)&(t<start+.45);tt=t[m]-(start+.32)
        if len(tt):sc[m]+=.05*np.sin(2*np.pi*1760*tt)*np.exp(-tt*35)
# Mechanical pulse, pure synth not samples.
sc += .018*np.sin(2*np.pi*6.67*t)*np.sin(2*np.pi*440*t)
# fixed 300ms click-free crossfade endpoints
sc[:7200] *= np.linspace(0,1,7200)
sc[-7200:] *= np.linspace(1,0,7200)
sc=np.clip(sc,-0.55,0.55)
wav=ROOT/'assets/music/core_first_signature_076_temp.wav'
with wave.open(str(wav),'wb') as w:
    w.setnchannels(1);w.setsampwidth(2);w.setframerate(sr)
    w.writeframes((sc*32767).astype('<i2').tobytes())
ogg=ROOT/'assets/music/core_first_signature_076.ogg'
subprocess.run(['ffmpeg','-nostdin','-loglevel','error','-y','-i',str(wav),'-c:a','libvorbis','-q:a','3',str(ogg)],check=True)
wav.unlink()
print('music:',ogg.stat().st_size, 'atlas count',len(list(target.glob('*.png'))))
# Save reproducible provenance in optional script.
meta={"build":"07.6","sources":{"world_materials":"Deterministic Pillow procedural original; seed 760017","core_actuator":"Original 07.4 Edda triage machine geometry recoloured and given a civic status plate, eight genuinely separate directional base atlases","music":"Deterministic original synthesized stems; no third-party sampling"},"note":"Procedural graphics remain production placeholders; human in-engine art review outstanding."}
(ROOT/'art/BUILD_076_ASSET_PROVENANCE.json').write_text(json.dumps(meta,indent=2)+'\n')
