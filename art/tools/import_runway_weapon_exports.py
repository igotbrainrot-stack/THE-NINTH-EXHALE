#!/usr/bin/env python3
"""Replace the four interim 06.4 weapon viewmodels using exported original Runway PNGs.
The actual source image must be downloaded from the connected Runway workspace.
Usage: python3 art/tools/import_runway_weapon_exports.py --source ~/Downloads/ninth_runway
Expected filenames: covenant.png, coil.png, nail.png, choir.png (partial allowed).
"""
from PIL import Image
from pathlib import Path
import argparse, shutil, numpy as np
parser=argparse.ArgumentParser();parser.add_argument('--source',type=Path,required=True)
a=parser.parse_args();root=Path(__file__).resolve().parents[2]
dest=root/'assets/weapons';dest.mkdir(parents=True,exist_ok=True)
orig=root/'art/production_sources/runway_weapons_064';orig.mkdir(parents=True,exist_ok=True)
count=0
for key in ('covenant','coil','nail','choir'):
    path=a.source/(key+'.png')
    if not path.is_file():print('Missing (skipped):',path);continue
    source=Image.open(path).convert('RGBA');shutil.copy2(path,orig/(key+'.png'))
    pix=np.array(source);rgb=pix[:,:,:3].astype(np.float32)
    dist=np.sqrt((255-rgb[:,:,0])**2+rgb[:,:,1]**2+(255-rgb[:,:,2])**2)
    pix[:,:,3]=np.clip((dist-20)*255/84,0,255).astype(np.uint8)
    img=Image.fromarray(pix,'RGBA');bb=img.getchannel('A').getbbox()
    if bb is None:raise ValueError('No foreground found in '+str(path))
    img=img.crop(bb)
    scale=min(430/img.width,320/img.height)
    size=(max(1,round(img.width*scale)),max(1,round(img.height*scale)))
    img=img.resize(size,Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(640,400),(0,0,0,0))
    out.alpha_composite(img,(640-size[0],405-size[1]))
    out.save(dest/(key+'_idle.png'))
    print('Imported',key,size)
    count+=1
print('Imported',count,'weapon(s); open Godot to reimport textures.')
