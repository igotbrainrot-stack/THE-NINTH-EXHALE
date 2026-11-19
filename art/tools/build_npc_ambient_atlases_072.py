#!/usr/bin/env python3
"""Add deterministic restrained idle motion to all 5 NPCs × 8 directions.

A real four-frame idle atlas, not 4 duplicated files. Upper-body cloth moves
~1px while foot anchors remain EXACTLY fixed. This is source-level procedural
motion, not independently hand-painted full walk cycles.
"""
from PIL import Image
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'assets/sprites/directional8'
OUT=ROOT/'assets/sprites/npc_idle_072'
NPCS=['sela','brin','ossa','oren','clerk']

def make_atlas(image:Image.Image)->Image.Image:
    src=image.convert('RGBA')
    w,h=src.size
    out=Image.new('RGBA',(w*4,h))
    for frame in range(4):
        cell=src.copy()
        if frame in (1,3):
            # Slight upper-body cloth motion, *not* a whole-body jump.
            band=cell.crop((0,round(h*.12),w,round(h*.62)))
            cell.paste(Image.new('RGBA',(w,band.height)),(0,round(h*.12)))
            shift=1 if frame==1 else -1
            cell.alpha_composite(band,(shift,round(h*.12)))
        out.alpha_composite(cell,(frame*w,0))
    return out

if __name__=='__main__':
    OUT.mkdir(exist_ok=True,parents=True)
    n=0
    for actor in NPCS:
        for direction in range(1,9):
            path=SRC/f'{actor}_{direction}.png'
            with Image.open(path) as image:
                atlas=make_atlas(image)
            atlas.save(OUT/f'{actor}_{direction}.png',optimize=True)
            n+=1
    print(f'Generated {n} 4-frame NPC idle strips, preserving feet at fixed anchor')
