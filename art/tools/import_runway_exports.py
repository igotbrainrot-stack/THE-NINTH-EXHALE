#!/usr/bin/env python3
"""Optional offline importer for Runway image downloads.

Example:
  python3 art/tools/import_runway_exports.py --brin ~/Downloads/brin.png \
    --pistol ~/Downloads/covenant.png --hearth ~/Downloads/ward_panel.png
The game runs without this step using the included hand-built art.
This script never makes network calls and saves originals under art/reference.
"""
import argparse
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[2]
REF=ROOT/'art'/'reference'
TEX=ROOT/'assets'/'textures'
SPR=ROOT/'assets'/'sprites'

def import_material(src: Path, output: Path):
    original=Image.open(src).convert('RGB')
    w,h=original.size
    d=min(w,h)
    tile=original.crop(((w-d)//2,(h-d)//2,(w+d)//2,(h+d)//2))
    tile=tile.resize((256,256),Image.Resampling.LANCZOS)
    # Authentic pixel-art nearest-neighbour display at limited colour depth.
    tile=tile.quantize(colors=80,method=Image.Quantize.MEDIANCUT).convert('RGB')
    tile.save(output,optimize=True)
    print(f'Game material installed: {output.relative_to(ROOT)}')

def import_sprite(src: Path, output: Path, target):
    image=Image.open(src).convert('RGBA')
    image.thumbnail((640,640),Image.Resampling.LANCZOS)
    # Runway prompt requests a uniform cutout background. Flood fill only
    # edge-connected pixels; internal similar colour on the object is protected.
    ImageDraw.floodfill(image,(0,0),(0,0,0,0),thresh=42)
    for pos in [(image.width-1,0),(0,image.height-1),(image.width-1,image.height-1)]:
        if image.getpixel(pos)[3]>0:
            ImageDraw.floodfill(image,pos,(0,0,0,0),thresh=42)
    area=image.getchannel('A').getbbox()
    if not area:
        raise ValueError('Could not isolate sprite foreground; check image background')
    cropped=image.crop(area)
    frame=Image.new('RGBA',target,(0,0,0,0))
    ratio=min((target[0]-5)/cropped.width,(target[1]-3)/cropped.height)
    sz=(max(1,round(cropped.width*ratio)),max(1,round(cropped.height*ratio)))
    reduced=cropped.resize(sz,Image.Resampling.LANCZOS)
    # Pixels are output at fixed size; preserve alpha transparency.
    x=(target[0]-sz[0])//2
    y=target[1]-sz[1]
    frame.alpha_composite(reduced,(x,y))
    frame.save(output,optimize=True)
    print(f'Game sprite installed: {output.relative_to(ROOT)}; review transparency and orientation in Godot')

def main():
    parser=argparse.ArgumentParser(description='Import manually downloaded Runway art into Build 05')
    for key in ('brin','pistol','hearth','sootworks'):
        parser.add_argument('--'+key,type=Path)
    args=parser.parse_args()
    for key,destination in {
        'brin':SPR/'brin.png','pistol':SPR/'covenant_pistol.png',
        'hearth':TEX/'ward_enamel_v2.png','sootworks':TEX/'furnace_facing_v2.png',
    }.items():
        src=getattr(args,key)
        if src is None: continue
        if not src.is_file(): parser.error(f'{key}: missing image: {src}')
        REF.mkdir(parents=True,exist_ok=True)
        # Separate archival copy, not a claim that the image is production-ready.
        copy=REF/f'runway_{key}_full{src.suffix.lower()}'
        import shutil
        shutil.copy2(src,copy)
        if key=='brin':import_sprite(src,destination,(96,128))
        elif key=='pistol':import_sprite(src,destination,(256,144))
        else:import_material(src,destination)
    print('Finished. Reimport in Godot, inspect seams, silhouettes, masks and collision before treating art as final.')
if __name__=='__main__':main()
