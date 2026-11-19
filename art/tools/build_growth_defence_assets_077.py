#!/usr/bin/env python3
"""Deterministic ORIGINAL municipal textures + recognisable interim actor overlays.

Source images already in the project remain available; the two district
antagonists use repainted *existing* eight-angle rigs until newly commissioned
individual source turnarounds are reviewed. Do not describe them as final art.
"""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import numpy as np, random, math, json
ROOT=Path(__file__).resolve().parents[2]
TEX=ROOT/'assets/textures'
SP=ROOT/'assets/sprites'
DIR=SP/'directional8'
ENE=SP/'enemies_077'
ENE.mkdir(exist_ok=True,parents=True)


def texture(name, c1, c2, mode):
    rng=random.Random('NINTH_077_'+name)
    a=np.empty((256,256,3),np.uint8)
    for y in range(256):
        for x in range(256):
            n=rng.randrange(-11,12)
            level=0.48+0.07*math.sin(x/17.0)+0.05*math.cos(y/15.0)
            a[y,x]=[int(max(0,min(255,c1[k]+level*(c2[k]-c1[k])+n))) for k in range(3)]
    im=Image.fromarray(a,'RGB')
    d=ImageDraw.Draw(im,'RGBA')
    if mode=='orchardglass':
        for x in range(0,256,64):
            d.line((x,0,x,255),fill=(25,57,51,180),width=4)
            d.line((x+4,0,x+4,255),fill=(205,220,190,100),width=2)
        for y in range(0,256,64):
            d.line((0,y,255,y),fill=(25,57,51,180),width=4)
            d.line((0,y+5,255,y+5),fill=(217,233,194,100),width=2)
        for i in range(22):
            x=rng.randrange(0,248);y=rng.randrange(0,248)
            d.ellipse((x,y,x+4,y+4),fill=(60,114,83,140))
    elif mode=='orchardfloor':
        for y in range(0,256,32):
            d.line((0,y,255,y),fill=(23,66,44,130),width=3)
        for x in range(0,256,32):
            d.line((x,0,x,255),fill=(55,82,57,130),width=3)
        for i in range(100):
            x=rng.randrange(256);y=rng.randrange(256)
            d.ellipse((x,y,x+2,y+5),fill=(43,85,51,rng.randrange(45,110)))
    elif mode=='barrackswall':
        for x in range(0,256,64):
            d.line((x,0,x,255),fill=(27,36,32,160),width=4)
        for y in range(0,256,85):
            d.line((0,y,255,y),fill=(51,55,50,145),width=3)
        for x in range(9,256,64):
            for y in range(9,256,85):
                d.ellipse((x-2,y-2,x+2,y+2),fill=(188,150,92,210))
    else:
        for x in range(0,256,48):
            d.line((x,0,x,255),fill=(52,54,49,115),width=2)
        for y in range(0,256,48):
            d.line((0,y,255,y),fill=(52,54,49,125),width=3)
        for i in range(90):
            x=rng.randrange(256);y=rng.randrange(256)
            d.rectangle((x,y,x+rng.randrange(2,9),y+2),fill=(111,81,55,rng.randrange(30,125)))
    out=TEX/(name+'.png')
    im.save(out)
    return out

textures={
 'orchard_glass_077':((45,95,79),(142,201,165),'orchardglass'),
 'orchard_floor_077':((49,92,74),(146,160,121),'orchardfloor'),
 'barracks_wall_077':((57,70,66),(152,155,132),'barrackswall'),
 'barracks_floor_077':((65,68,63),(155,147,129),'barracksfloor'),
}
for name,args in textures.items(): texture(name,*args)


def shift_rgb(img,scale):
    a=np.asarray(img.convert('RGBA'), dtype=np.float32).copy()
    for i,v in enumerate(scale): a[:,:,i]=np.clip(a[:,:,i]*v,0,255)
    return Image.fromarray(a.astype('uint8'),'RGBA')

# Distinct role silhouette overlays atop verified 8-angle original base rigs.
for person,base,scales in [('venn','oren',(1.13,1.10,0.76)),('kest','sela',(0.84,0.86,0.82))]:
    for angle in range(1,9):
        path=DIR/f'{base}_{angle}.png'
        if person=='kest':
            path=SP/'enemies_074'/f'enforcer_{angle}.png'
            source=Image.open(path).convert('RGBA').crop((0,0,192,256))
            canvas=Image.new('RGBA',(192,280),(0,0,0,0))
            canvas.alpha_composite(source,(0,24))
        else:
            canvas=Image.open(path).convert('RGBA')
        canvas=shift_rgb(canvas,scales)
        d=ImageDraw.Draw(canvas,'RGBA')
        if person=='venn':
            # Painted ochre apron, visible free-opening cage at the hip.
            d.polygon([(73,100),(111,100),(119,191),(71,192)],fill=(191,145,58,112))
            d.rounded_rectangle((115,158,157,198),radius=5,outline=(163,133,100,255),width=3)
            for bar in range(122,155,10): d.line((bar,160,bar,196),fill=(120,94,85,180),width=2)
            d.ellipse((128,148,143,158),fill=(122,91,137,180))
        else:
            # White cracked service faceplate and double namestrip on chest.
            d.rounded_rectangle((78,24,113,71),radius=4,fill=(209,210,193,220),outline=(92,96,93,240),width=2)
            d.line((94,44,90,62),fill=(77,76,69,210),width=2)
            d.rectangle((77,99,116,109),fill=(190,188,164,210),outline=(68,64,55,230),width=1)
            d.rectangle((82,102,116,106),fill=(105,110,93,215))
        canvas.save(DIR/f'{person}_{angle}.png')
        if angle==1: canvas.save(SP/f'{person}.png')

# Full 8-way combat frame atlases retain existing pose and proportions.
for name,source,scales in [('gardener','millwright',(0.83,1.18,0.84)),('commandant','millwright',(1.01,0.93,0.78))]:
    for angle in range(1,9):
        img=Image.open(SP/'enemies_074'/f'{source}_{angle}.png').convert('RGBA')
        img=shift_rgb(img,scales)
        d=ImageDraw.Draw(img,'RGBA')
        for frame in range(12):
            x=(frame%4)*192
            y=(frame//4)*256
            # Unique service structure in every animation cell.
            if name=='gardener':
                d.arc((x+65,y+48,x+122,y+138),200,325,fill=(106,215,118,185),width=3)
                d.ellipse((x+49,y+54,x+64,y+73),fill=(123,207,123,165))
                d.arc((x+124,y+61,x+165,y+130),160,330,fill=(108,180,112,160),width=3)
            else:
                d.rectangle((x+63,y+65,x+117,y+89),outline=(208,185,138,175),width=3)
                for yy in [76,82]: d.line((x+65,y+yy,x+115,y+yy),fill=(69,76,70,140),width=2)
        img.save(ENE/f'{name}_{angle}.png')

manifest={'build':'07.7','original_textures':sorted(textures),'new_actor_directions':{'venn':8,'kest':8},'temporary_antagonist_atlases':{'gardener':'repainted millwright physical 8-direction rig, not final uniquely modelled sprite','commandant':'repainted millwright physical 8-direction rig, not final uniquely modelled sprite'},'note':'Production placeholder art is local and included. No new Runway originals claimed.'}
(ROOT/'art/BUILD_077_ASSET_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('generated',len(textures),'textures and 32 directional assets')
