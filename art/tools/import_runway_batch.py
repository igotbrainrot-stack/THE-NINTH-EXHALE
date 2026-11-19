#!/usr/bin/env python3
"""Convert user-exported Runway PNGs into tileable Godot assets & character sprite angles.

Expected input files are renamed to the labels in RUNWAY_BATCH_MANIFEST.json:
    ward_enamel.png, ward_floor.png, ..., sela.png, brin.png, ...

Runway images are generated remotely and not assumed to be inside a ZIP.
The tool never downloads from signed private Runway URLs or creates new assets by itself.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image
import argparse, json, math, shutil
import numpy as np

PROJECT=Path(__file__).resolve().parents[2]
TEX_TARGETS={
 'ward_enamel':'ward_enamel_v2.png',
 'ward_floor':'floor_grid.png',
 'ward_ceiling':'ward_ceiling_v3.png',
 'soot_wall':'soot_wall_v3.png',
 'soot_floor':'soot_floor_v3.png',
 'soot_furnace':'furnace_facing_v2.png',
 'basilica_stone':'basilica_stone.png',
 'basilica_floor':'basilica_floor_v3.png',
}
NPCS=('sela','brin','ossa','oren','clerk','ninth_turnaround')
EQUIPMENT=('covenant_pistol','coil_shotgun','nail_storm','choirbreaker','cinder_lung','hearthkeeper_armour','brass_union_armour')

def seam_correct(image: Image.Image, output_size: int = 128) -> Image.Image:
    # Artists must still inspect the four-way repetition for strong motif shifts.
    arr=np.array(image.convert('RGB').resize((output_size,output_size),Image.Resampling.LANCZOS),dtype=np.float32)
    n=output_size; band=max(5,n//12)
    for k in range(band):
        weight=(1.0-k/band)**2
        left=arr[:,k,:].copy(); right=arr[:,n-1-k,:].copy()
        avg=(left+right)*0.5
        arr[:,k,:]=left*(1-weight)+avg*weight
        arr[:,n-1-k,:]=right*(1-weight)+avg*weight
    for k in range(band):
        weight=(1.0-k/band)**2
        top=arr[k,:,:].copy(); bot=arr[n-1-k,:,:].copy()
        avg=(top+bot)*0.5
        arr[k,:,:]=top*(1-weight)+avg*weight
        arr[n-1-k,:,:]=bot*(1-weight)+avg*weight
    return Image.fromarray(np.uint8(np.clip(arr,0,255)),'RGB')

def remove_matte(img: Image.Image)-> Image.Image:
    img=img.convert('RGBA')
    arr=np.array(img,dtype=np.uint8)
    r,g,b=arr[:,:,0],arr[:,:,1],arr[:,:,2]
    # A pure-magenta background is specified at generation time. No magenta outfits.
    key=((r.astype(int)>145)&(b.astype(int)>130)&(r.astype(int)>g.astype(int)*1.42)&(b.astype(int)>g.astype(int)*1.38))
    arr[:,:,3][key]=0
    return Image.fromarray(arr,'RGBA')

def make_views(im:Image.Image,out:Path,stem:str)->None:
    im=remove_matte(im)
    W,H=im.size;mid_x=W//2;mid_y=H//2
    parts={'front':(0,0,mid_x,mid_y),'left':(mid_x,0,W,mid_y),'right':(0,mid_y,mid_x,H),'back':(mid_x,mid_y,W,H)}
    crops={}
    for face,area in parts.items():
        cr=im.crop(area)
        a=cr.getchannel('A').point(lambda v:255 if v>35 else 0)
        bbox=a.getbbox()
        if bbox is None:raise ValueError(f'No opaque sprite detected: {stem} {face}')
        crops[face]=cr.crop(bbox)
    scale=min(254/max(a.height for a in crops.values()),178/max(a.width for a in crops.values()))
    out.mkdir(parents=True,exist_ok=True)
    for face,cr in crops.items():
        imsize=(max(1,int(cr.width*scale)),max(1,int(cr.height*scale)))
        cr=cr.resize(imsize,Image.Resampling.LANCZOS)
        canvas=Image.new('RGBA',(192,280))
        canvas.alpha_composite(cr,((192-cr.width)//2,275-cr.height))
        canvas.save(out/f'{stem}_{face}.png',optimize=True)

def make_equipment(im:Image.Image,out:Path,stem:str)->None:
    cut=remove_matte(im)
    bbox=cut.getchannel('A').getbbox()
    if not bbox: raise ValueError(f'Empty equipment image {stem}')
    cut=cut.crop(bbox)
    # Equipment pickups use 192x192 portrait and a lower-right weapon HUD pose.
    is_weapon=stem in EQUIPMENT[:4]
    target_size=(256,168) if is_weapon else (192,192)
    safe_width=target_size[0]-8;safe_height=target_size[1]-8
    scale=min(safe_width/cut.width,safe_height/cut.height)
    cut=cut.resize((max(1,round(cut.width*scale)),max(1,round(cut.height*scale))),Image.Resampling.LANCZOS)
    canvas=Image.new('RGBA',target_size)
    x=(target_size[0]-cut.width)//2
    y=target_size[1]-cut.height-3 if is_weapon else (target_size[1]-cut.height)//2
    canvas.alpha_composite(cut,(x,y))
    out.mkdir(parents=True,exist_ok=True)
    canvas.save(out/f'{stem}.png',optimize=True)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',required=True,type=Path,help='Directory of exported Runway images, renamed to manifest labels (label.png)')
    p.add_argument('--target',default=PROJECT,type=Path,help='Destination Godot project root')
    args=p.parse_args()
    tex_out=args.target/'assets'/'textures';spr_out=args.target/'assets'/'sprites';dir_out=spr_out/'directional'
    tex_out.mkdir(parents=True,exist_ok=True)
    spr_out.mkdir(parents=True,exist_ok=True)
    dir_out.mkdir(parents=True,exist_ok=True)
    raw_out=args.target/'art'/'runway_source';raw_out.mkdir(parents=True,exist_ok=True)
    processed=[];missing=[]
    for label in list(TEX_TARGETS)+list(NPCS)+list(EQUIPMENT):
        source=args.source/(label+'.png')
        if not source.exists():
            missing.append(label)
            continue
        shutil.copyfile(source,raw_out/source.name)
        image=Image.open(source)
        if label in TEX_TARGETS:
            out=tex_out/TEX_TARGETS[label]
            seam_correct(image).save(out,optimize=True)
        elif label in NPCS:
            make_views(image,dir_out,'ninth' if label=='ninth_turnaround' else label)
        else:
            make_equipment(image,spr_out/'equipment',label)
            if label=='covenant_pistol':
                (spr_out/'equipment'/'covenant_pistol.png').replace(spr_out/'covenant_pistol.png')
        processed.append(label)
    print(json.dumps({'processed':processed,'missing':missing,'target':str(args.target)},indent=2))
    if not processed:raise SystemExit('No matching exports in source directory')

if __name__=='__main__':main()
