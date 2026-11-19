#!/usr/bin/env python3
"""Original deterministic Ashmarket tile textures and Collector directional art.
Collector is a documented painted derivative of the existing 07.4 enforcer
rig, not a separately commissioned eight-view painting.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np,random
ROOT=Path(__file__).resolve().parents[2]
R=random.Random(750517)
T=ROOT/'assets/textures';T.mkdir(parents=True,exist_ok=True)
S=512

def grain(base,scale=10):
    arr=np.zeros((S,S,4),dtype=np.uint8)
    # periodic diffuse mineral grain generated from a fixed seamless blend
    rng=np.random.default_rng(750517+int(base[0]))
    field=rng.integers(-scale,scale+1,(S,S),dtype=np.int16)
    for i,c in enumerate(base):arr[:,:,i]=np.clip(c+field,0,255).astype(np.uint8)
    arr[:,:,3]=255
    return Image.fromarray(arr,'RGBA')

im=grain((113,107,96),9);d=ImageDraw.Draw(im,'RGBA')
for y in range(0,S,64):
    d.line((0,y,S,y),fill=(38,41,40,190),width=4)
    for x in range(-64 if (y//64)%2 else 0,S,128):
        d.line((x,y,x,y+64),fill=(44,42,36,185),width=4)
        d.line((x+8,y+12,x+74,y+12),fill=(171,149,116,30),width=2)
for _ in range(185):
    x,y=R.randrange(S),R.randrange(S)
    w=R.randrange(2,28)
    d.ellipse((x,y,x+w,y+R.randrange(1,5)),fill=R.choice([(47,45,43,65),(170,115,70,50),(186,172,146,30)]))
im.save(T/'ashmarket_floor_075.png')

im=grain((107,103,90),11);d=ImageDraw.Draw(im,'RGBA')
for x in range(0,S,128):
    d.rectangle((x+4,6,x+119,505),outline=(40,47,42,170),width=5)
    d.line((x+15,14,x+112,14),fill=(182,147,105,130),width=3)
    d.line((x+13,495,x+113,495),fill=(36,42,41,170),width=3)
    for y in range(46,460,89):
        d.rectangle((x+20,y,x+105,y+7),fill=(31,40,37,165))
        d.rectangle((x+25,y+12,x+99,y+50),fill=(162,151,126,90))
        d.line((x+27,y+17,x+95,y+17),fill=(210,185,142,85),width=2)
for _ in range(200):
    x,y=R.randrange(S),R.randrange(S)
    d.point((x,y),fill=(42,49,46,105))
im.save(T/'ashmarket_ledger_wall_075.png')

im=grain((131,68,51),9);d=ImageDraw.Draw(im,'RGBA')
for y in range(0,S,48):
    d.rectangle((0,y+4,S,y+11),fill=(81,48,40,120))
    d.line((0,y+34,S,y+34),fill=(192,122,81,90),width=3)
    for x in range(0,S,64):
        d.line((x,y,x+11,y+17),fill=(31,29,25,75),width=2)
im.save(T/'ashmarket_awning_075.png')

# Turn the existing *eight actual* camera views of an enforcer into a distinct
# legal-bureau service officer. Each 4x3 animated atlas retains exactly 12 frames.
source=ROOT/'assets/sprites/enemies_074';output=ROOT/'assets/sprites/enemies_075'
output.mkdir(exist_ok=True,parents=True)
for face in range(1,9):
    original=Image.open(source/f'enforcer_{face}.png').convert('RGBA')
    a=np.asarray(original,dtype=np.uint8).copy()
    alpha=a[:,:,3].copy();rgb=a[:,:,:3].astype(np.float32)
    # old black-green security uniform => warmer parchment/oak civic fabric
    greenish=(rgb[:,:,1] >= rgb[:,:,0]*0.87) & (rgb[:,:,0]<115) & (rgb[:,:,2]<110) & (alpha>0)
    red=rgb[:,:,0].copy(); green=rgb[:,:,1].copy();blue=rgb[:,:,2].copy()
    rgb[:,:,0][greenish]=np.clip(red[greenish]*0.85+green[greenish]*0.32+26,0,255)
    rgb[:,:,1][greenish]=np.clip(green[greenish]*0.75+13,0,255)
    rgb[:,:,2][greenish]=np.clip(blue[greenish]*0.65+7,0,255)
    for ch in range(3):a[:,:,ch]=rgb[:,:,ch].astype(np.uint8)
    a[:,:,3]=alpha
    atlas=Image.fromarray(a,'RGBA')
    # A set of docket / bronze clip badges placed consistently relative to torso
    # in each 192x256 cell; side/rear views have no front-facing fake receipt.
    overlay=Image.new('RGBA',atlas.size,(0,0,0,0));d=ImageDraw.Draw(overlay,'RGBA')
    for index in range(12):
        cx=(index%4)*192;cy=(index//4)*256
        if face in [1,2,8]:
            d.rectangle((cx+99,cy+100,cx+117,cy+122),fill=(178,151,102,210),outline=(43,38,30,220),width=2)
            d.line((cx+103,cy+106,cx+113,cy+106),fill=(80,73,55,200),width=1)
            d.line((cx+103,cy+111,cx+111,cy+111),fill=(80,73,55,200),width=1)
        elif face in [4,5,6]:
            d.rectangle((cx+86,cy+94,cx+104,cy+104),fill=(48,48,44,210),outline=(155,117,65,170),width=2)
    atlas=Image.alpha_composite(atlas,overlay)
    atlas.save(output/f'collector_{face}.png',compress_level=6)
print('3 original material textures and 8 Collector directional animation atlases exported')
