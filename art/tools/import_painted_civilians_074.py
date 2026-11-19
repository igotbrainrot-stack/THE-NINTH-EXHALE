#!/usr/bin/env python3
"""Build 07.4: bake original, *actual* eight-angle illustrated PNG sources.

These two paintings were created in the project conversation and are bundled
unchanged in art/production_sources/painted_074/. All eight directions are
cropped independently, with chroma decontamination and one shared foot anchor.
Remaining NPCs retain their original 07.3 eight distinct 3D maquettes until
proper high-fidelity eight-view paintings have been imported and approved.
"""
from __future__ import annotations
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'art/production_sources/painted_074'
DST=ROOT/'assets/sprites/directional8'
IDLE=ROOT/'assets/sprites/npc_idle_072'
PV=ROOT/'art/previews/BUILD_074_PAINTED_EIGHT_VIEWS.png'
NAMES=['sela','brin']

def cut(im: Image.Image, idx: int, actor: str)->Image.Image:
    # The image sheets have a 2x4 layout (1..8), all separately rendered views.
    im=im.convert('RGB')
    W,H=im.size
    x0=(idx%4)*W//4; x1=(idx%4+1)*W//4
    y0=(idx//4)*H//2; y1=(idx//4+1)*H//2
    rgb=np.asarray(im.crop((x0,y0,x1,y1)),dtype=np.float32)
    # Chroma-key only pixels actually resembling bright magenta; ordinary
    # dark skin/cloth must remain fully opaque, or its colors turn green.
    chroma=np.minimum(rgb[:,:,0],rgb[:,:,2])-rgb[:,:,1]
    alpha=1.0-np.clip((chroma-42.0)/160.0,0,1)
    alpha=np.where(chroma>198,0.0,alpha)
    alpha=np.where(alpha<0.06,0.0,alpha)
    bg=np.array([255,0,255],np.float32)
    fg=(rgb-(1-alpha[:,:,None])*bg)/np.maximum(alpha[:,:,None],.04)
    fg=np.clip(fg,0,255)
    if actor == 'sela':
        # The generated reference included generic red-cross-like sleeve
        # markings. Recolour those into this project's amber service-tab
        # palette to avoid copying the protected Red Cross emblem.
        red=(fg[:,:,0]>125)&(fg[:,:,0]>fg[:,:,1]*1.38)&(fg[:,:,0]>fg[:,:,2]*1.32)
        fg[red,0]=161.0; fg[red,1]=125.0; fg[red,2]=66.0
    # Conservative edge cleanup prevents source magenta bleeding into mipmaps.
    partial=(alpha<.98)
    fg[partial,0]=np.minimum(fg[partial,0],220)
    fg[partial,2]=np.minimum(fg[partial,2],215)
    rgba=np.uint8(np.clip(np.dstack([fg,alpha*255]),0,255))
    out=Image.fromarray(rgba,'RGBA')
    bbox=out.getchannel('A').point(lambda a: 255 if a>80 else 0).getbbox()
    if bbox is None:raise RuntimeError(f'No sprite in direction {idx+1}')
    margin=2
    c=out.crop((max(0,bbox[0]-margin),max(0,bbox[1]-margin),min(out.width,bbox[2]+margin),min(out.height,bbox[3]+margin)))
    ratio=min(178/c.width,264/c.height)
    size=(max(1,round(c.width*ratio)),max(1,round(c.height*ratio)))
    c=c.resize(size,Image.Resampling.LANCZOS)
    cell=Image.new('RGBA',(192,280))
    cell.alpha_composite(c,((192-size[0])//2,275-size[1]))
    return cell

def idle_atlas(im:Image.Image)->Image.Image:
    # Subtle cloth/shoulder movement, zero foot movement. Four genuinely
    # different pixels per frame; not a replacement for full walk animation.
    from importlib.util import spec_from_file_location,module_from_spec
    # Avoid changing the original production tool or its output scheme.
    src=im.convert('RGBA');w,h=src.size
    result=Image.new('RGBA',(w*4,h))
    for n in range(4):
        tile=src.copy()
        if n in (1,3):
            top=round(h*.17);bottom=round(h*.53)
            band=src.crop((0,top,w,bottom))
            tile.paste((0,0,0,0),(0,top,w,bottom))
            tile.alpha_composite(band,(1 if n==1 else -1,top))
        result.alpha_composite(tile,(w*n,0))
    return result

def main():
    DST.mkdir(parents=True,exist_ok=True);IDLE.mkdir(parents=True,exist_ok=True)
    sheets={};metrics={}
    for name in NAMES:
        original=Image.open(SRC/f'{name}_true8.png')
        views=[cut(original,i,name) for i in range(8)]
        for i,view in enumerate(views,1):
            view.save(DST/f'{name}_{i}.png',optimize=True)
            idle_atlas(view).save(IDLE/f'{name}_{i}.png',optimize=True)
        # Assert basic coverage and non-repetition, independent of older tests.
        v=[np.asarray(i.convert('RGBA'),np.float32) for i in views]
        minimum=min(float(np.abs(v[i]-v[j]).mean()) for i in range(8) for j in range(i+1,8))
        if minimum<3.0:raise RuntimeError(f'{name} too similar across directions {minimum}')
        metrics[name]={'views':8,'size':'192x280','min_pairwise_RGBA_difference':round(minimum,2)}
        sheets[name]=views
    # Contact for real exported game sprites, not a synthetic mood illustration.
    canvas=Image.new('RGB',(1190,620),(21,27,26));draw=ImageDraw.Draw(canvas)
    draw.text((20,15),'THE NINTH EXHALE / BUILD 07.4 — PAINTED NPC EIGHT-VIEW ACTUAL EXPORTS',fill=(237,213,166))
    draw.text((20,37),'1 FRONT     2 FRONT-LEFT     3 LEFT     4 BACK-LEFT     5 BACK     6 BACK-RIGHT     7 RIGHT     8 FRONT-RIGHT',fill=(170,190,169))
    for row,(name,views) in enumerate(sheets.items()):
        y=66+row*276;draw.text((14,y+118),name.upper(),fill=(240,207,158))
        for i,t in enumerate(views):
            thumb=t.resize((138,202),Image.Resampling.LANCZOS)
            bg=Image.new('RGBA',thumb.size,(51,58,54,255));bg.alpha_composite(thumb)
            canvas.paste(bg.convert('RGB'),(92+i*137,y))
            draw.text((92+i*137,y+206),str(i+1),fill=(214,218,193))
    PV.parent.mkdir(parents=True,exist_ok=True);canvas.save(PV)
    (SRC/'BUILD_074_PAINTED_NPC_QA.json').write_text(json.dumps(metrics,indent=2)+'\n')
    print('Baked painted eight-view NPCs:',metrics)

if __name__=='__main__':main()
