#!/usr/bin/env python3
"""Deterministic original municipal assembly textures. No source IP assets.

Produces 512px repeated-friendly materials for The Ninth Exhale 07.8.
"""
import random
from pathlib import Path
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[2]/'assets'/'textures'
ROOT.mkdir(parents=True,exist_ok=True)
R=random.Random(78018)
SIZE=512

# An old public parquet made from numbered and replaced slate rectangles.
img=Image.new('RGB',(SIZE,SIZE),'#6c7169')
d=ImageDraw.Draw(img)
for gy in range(0,SIZE,64):
    for gx in range(0,SIZE,64):
        n=R.randrange(-8,11)
        tile=(max(0,112+n),max(0,116+n),max(0,107+n))
        d.rectangle((gx+2,gy+2,gx+61,gy+61),fill=tile)
        d.line((gx+2,gy+2,gx+61,gy+2),fill=(155,154,136),width=2)
        d.line((gx+4,gy+60,gx+60,gy+60),fill=(54,60,55),width=2)
        if R.random()<0.27:
            x=gx+R.randint(12,48);y=gy+R.randint(13,44)
            d.line((x-6,y-4,x+10,y+5),fill=(85,76,66),width=2)
        for _ in range(3):
            x=gx+R.randint(6,58);y=gy+R.randint(6,58)
            d.point((x,y),fill=(78,84,78))
    # Cross-hall vote register inlay; four separated brass dashes, not a logo.
    for x in range(0,SIZE,128):
        d.rectangle((x+46,gy+29,x+62,gy+34),fill=(169,128,72))
        d.rectangle((x+46,gy+35,x+62,gy+36),fill=(88,73,50))
img.save(ROOT/'assembly_floor_078.png')

# Modular bureaucratic filing wall: dull enamel, small metal hinges and vents.
img=Image.new('RGB',(SIZE,SIZE),'#464f4a');d=ImageDraw.Draw(img)
for y in range(0,SIZE,128):
    for x in range(0,SIZE,128):
        d.rectangle((x+3,y+3,x+124,y+124),fill=(116+R.randrange(-4,6),130+R.randrange(-5,5),120+R.randrange(-5,5)),outline=(49,59,55),width=3)
        d.rectangle((x+14,y+13,x+113,y+33),fill=(75,87,80),outline=(166,151,109),width=2)
        for slot in range(5):
            yy=y+49+slot*12
            d.rectangle((x+17,yy,x+71,yy+4),fill=(52,62,60))
            d.line((x+19,yy+1,x+68,yy+1),fill=(147,148,129),width=1)
        d.rectangle((x+88,y+49,x+111,y+98),fill=(69,79,74),outline=(42,52,49),width=2)
        d.line((x+98,y+59,x+98,y+88),fill=(177,135,86),width=2)
        for bx,by in [(8,8),(119,8),(8,119),(119,119)]:
            d.ellipse((x+bx-2,y+by-2,x+bx+2,y+by+2),fill=(198,156,100))
img.save(ROOT/'assembly_wall_078.png')
print('Assembly textures:',*[str(ROOT/x) for x in ('assembly_floor_078.png','assembly_wall_078.png')],sep='\n')
