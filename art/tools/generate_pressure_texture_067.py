"""Original deterministic industrial texture: no third-party sampled material.
Run: python3 art/tools/generate_pressure_texture_067.py
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import random
root=Path(__file__).resolve().parents[2]
out=root/'assets/textures/pressure_vessel_067.png'
rng=random.Random(670017)
sz=256
im=Image.new('RGB',(sz,sz),(68,73,67))
pix=im.load()
for y in range(sz):
    for x in range(sz):
        n=rng.randrange(-10,11)
        streak=(x%24==0)*8+(x%27==1)*3
        corrode=4 if rng.random()<0.05 else 0
        pix[x,y]=(max(12,74+n-streak+corrode),max(14,77+n-streak//2),max(14,69+n-streak//2))
d=ImageDraw.Draw(im)
# Longitudinal cast panel seams and lightly riveted service plating.
for x in range(0,257,64):
    d.rectangle((x,0,x+2,255),fill=(32,35,32))
    d.line((x+4,0,x+4,255),fill=(108,102,80))
for y in range(0,257,85):
    d.rectangle((0,y,255,y+3),fill=(40,42,38))
    d.line((0,y+6,255,y+6),fill=(96,95,79))
for y in (20,66,107,148,195,232):
    for x in (18,81,145,209):
        d.ellipse((x-3,y-3,x+3,y+3),fill=(25,27,25),outline=(155,142,98),width=1)
# Distinctive ochre service warning band, no readable fake text.
d.rectangle((0,114,255,140),fill=(146,88,46))
for x in range(-30,286,30):
    d.polygon([(x,114),(x+11,114),(x+28,140),(x+17,140)], fill=(37,42,39))
d.line((0,113,255,113),fill=(185,153,104),width=2)
d.line((0,141,255,141),fill=(33,35,31),width=2)
# Circular inspection outlines are subtle; no mimicked IP logos.
d.ellipse((101,35,156,89),outline=(25,32,31),width=3)
d.arc((108,41,150,83),0,300,fill=(113,130,121),width=2)
out.parent.mkdir(parents=True,exist_ok=True)
im.save(out,optimize=True)
print(out,'bytes',out.stat().st_size)
