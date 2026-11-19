#!/usr/bin/env python3
"""Reproducibly build Godot production runtime assets from named ORIGINAL source PNGs.
Run from the project root. Requires Pillow and NumPy.
All sources belong to The Ninth Exhale production; no external IP assets.
"""
from pathlib import Path
import json, os
import numpy as np
from PIL import Image, ImageFilter
ROOT=Path(__file__).resolve().parents[2]
SOURCES=ROOT/'art'/'production_sources'/'new_pass'
TEX=ROOT/'assets'/'textures'; SPR=ROOT/'assets'/'sprites'; PROPS=SPR/'props'; FACES=SPR/'directional'
for p in [TEX,SPR,PROPS,FACES]:p.mkdir(exist_ok=True,parents=True)
TILES={'ward_enamel':'ward_enamel_v4.png','ward_floor':'ward_floor_v4.png','soot_wall':'soot_wall_v4.png','soot_floor':'soot_floor_v4.png','basilica_stone':'basilica_stone_v4.png'}
NPCS=['sela','brin','ossa','oren','clerk']; AREAS=['hearth','sootworks','basilica']

def chroma(im):
    """Calculate conservative smooth alpha from source magenta keyed render."""
    img=np.asarray(im.convert('RGB'),dtype=np.float32)
    r,g,b=[img[:,:,i] for i in range(3)]
    # Synthetic magenta is R/B high, G near zero; preserve dark gray and skin.
    magenta=np.minimum(r,b)-g
    removable=np.clip((magenta-67.0)/62.0,0,1)*np.clip((r-130)/70,0,1)*np.clip((b-120)/70,0,1)
    # Strongly colored backdrop must become fully transparent.
    alpha=(255*(1-removable)).astype(np.uint8)
    arr=np.dstack([img.astype(np.uint8),alpha]); arr[alpha==0,:3]=0
    return Image.fromarray(arr,'RGBA')

def tile(src,dest):
    image=Image.open(src).convert('RGB').resize((512,512),Image.Resampling.LANCZOS)
    a=np.asarray(image,dtype=np.float32).copy()
    # Correct minor source seam discrepancies with 24px edge cross-fading.
    # Blend boundaries to same pixel values at opposite sides of x/y.
    n=26
    for axis in [1,0]:
        if axis==1:
            l=a[:,:n,:].copy(); r=a[:,-n:,:].copy()
            for k in range(n):
                w=(k+1)/n
                avg=0.5*(l[:,k,:]+r[:,k,:]);
                a[:,k,:]=l[:,k,:]*w+avg*(1-w)
                a[:,-1-k,:]=r[:,-1-k,:]*w+avg*(1-w)
        else:
            l=a[:n,:,:].copy();r=a[-n:,:,:].copy()
            for k in range(n):
                w=(k+1)/n;avg=0.5*(l[k,:,:]+r[k,:,:]);
                a[k,:,:]=l[k,:,:]*w+avg*(1-w)
                a[-1-k,:,:]=r[-1-k,:,:]*w+avg*(1-w)
    # Force seam border pixel equal along opposite edges, preserve internal texture.
    seam=(a[:,0,:]+a[:,-1,:])/2; a[:,0,:]=seam;a[:,-1,:]=seam
    seam=(a[0,:,:]+a[-1,:,:])/2; a[0,:,:]=seam;a[-1,:,:]=seam
    out=Image.fromarray(np.uint8(np.clip(a,0,255)),'RGB')
    out.save(dest,optimize=True)

def clean_crop(img,pad=2):
    alpha=img.getchannel('A'); mask=alpha.point(lambda x:255 if x>36 else 0)
    bb=mask.getbbox()
    if bb is None:raise ValueError('No visible pixels')
    bb=(max(bb[0]-pad,0),max(bb[1]-pad,0),min(bb[2]+pad,img.width),min(bb[3]+pad,img.height))
    return img.crop(bb)

def npc_split(src,stem):
    image=chroma(Image.open(src)); w,h=image.size
    names=['front','right','left','back']; crops=[]
    for idx in range(4):
        box=(idx%2*w//2,idx//2*h//2,(idx%2+1)*w//2,(idx//2+1)*h//2)
        crops.append(clean_crop(image.crop(box)))
    max_height=max(c.height for c in crops);max_width=max(c.width for c in crops)
    factor=min(257/max_height,180/max_width)
    out_paths=[]
    for name,cut in zip(names,crops):
        new_w=max(1,round(cut.width*factor));new_h=max(1,round(cut.height*factor))
        cut=cut.resize((new_w,new_h),Image.Resampling.LANCZOS)
        frame=Image.new('RGBA',(192,280),(0,0,0,0)); frame.alpha_composite(cut,((192-new_w)//2,274-new_h))
        dest=FACES/f'{stem}_{name}.png';frame.save(dest,optimize=True);out_paths.append(str(dest.relative_to(ROOT)))
    return out_paths

def props(src,stem):
    image=chroma(Image.open(src));w,h=image.size;out=[]
    for idx in range(9):
        x=idx%3;y=idx//3;cut=clean_crop(image.crop((x*w//3,y*h//3,(x+1)*w//3,(y+1)*h//3)))
        factor=min(250/max(cut.width,cut.height),1.5)
        cut=cut.resize((round(cut.width*factor),round(cut.height*factor)),Image.Resampling.LANCZOS)
        canvas=Image.new('RGBA',(256,256),(0,0,0,0));canvas.alpha_composite(cut,((256-cut.width)//2,250-cut.height))
        path=PROPS/f'{stem}_{idx+1:02d}.png';canvas.save(path,optimize=True);out.append(str(path.relative_to(ROOT)))
    return out

def weapon(src):
    image=chroma(Image.open(src));image=image.resize((600,450),Image.Resampling.LANCZOS)
    image.save(SPR/'covenant_pistol.png',optimize=True)

manifest={'source':'original image-generation art created for The Ninth Exhale by the user/assistant','tiles':{},'npcs':{},'props':{},'weapon':'assets/sprites/covenant_pistol.png'}
for key,name in TILES.items():
    path=SOURCES/(key+'.png')
    if path.exists():tile(path,TEX/name); manifest['tiles'][key]=str((TEX/name).relative_to(ROOT))
for stem in NPCS:
    path=SOURCES/(stem+'.png')
    if path.exists():manifest['npcs'][stem]=npc_split(path,stem)
for stem in AREAS:
    path=SOURCES/(stem+'_props.png')
    if path.exists():manifest['props'][stem]=props(path,stem)
p=SOURCES/'covenant_pistol.png'
if p.exists():weapon(p)
(ROOT/'art'/'RUNTIME_ASSET_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Imported',len(manifest['tiles']),'tiles,',len(manifest['npcs']),'NPC turnarounds,',sum(map(len,manifest['props'].values())),'props; weapon=',p.exists())
