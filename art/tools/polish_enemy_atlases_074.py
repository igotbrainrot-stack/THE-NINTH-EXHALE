#!/usr/bin/env python3
"""07.4: add consistent palette/edge/material polish without faking angles.

Each output is derived from the corresponding actual 45-degree VTK bake.
The geometry, animation cells, orientation, alignment and artist provenance stay
intact. This *does not* create independent high-fidelity Runway artwork.
"""
from __future__ import annotations
from PIL import Image,ImageFilter,ImageEnhance
import numpy as np,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'assets/sprites/enemies_073'
OUT=ROOT/'assets/sprites/enemies_074'
IDS=['sentry','enforcer','millwright','cantor','edda_machine','pressure_mite','registry_bailiff','vent_whistler','rivet_courier','slag_sifter','chain_hauler','choir_reed','saltbound_porter','sluice_beadle','triage_warden','bell_wretch','rootkin']
# Different underpaint colors give a shared silhouette treatment without
# making the entire roster look like identical robots.
LINERS={'sentry':(20,31,28),'enforcer':(20,26,25),'millwright':(19,24,27),'cantor':(19,32,31),'edda_machine':(30,36,31),'rootkin':(22,40,35),'bell_wretch':(31,26,31)}

def polish_one(cell:Image.Image,theme:str)->Image.Image:
    rgba=np.asarray(cell.convert('RGBA'),np.uint8)
    a=rgba[:,:,3].astype('float32')/255
    rgb=rgba[:,:,:3].astype('float32')
    strong=a>.22
    # Dither light gently in material space. Sprite art remains 192x256.
    y,x=np.indices(a.shape)
    luminance=(rgb[:,:,0]*.30+rgb[:,:,1]*.57+rgb[:,:,2]*.13)/255
    rough=((x*73+y*151+(x*y)%37)%37).astype('float32')/37.0-.5
    micro=rough*(2.0+7.0*(1.0-luminance))
    # Directional painterly highlights on each mesh face and dark joint inset.
    top_edge=a-np.roll(a,1,axis=0)
    left_edge=a-np.roll(a,1,axis=1)
    bottom_edge=a-np.roll(a,-1,axis=0)
    rgb=rgb+micro[:,:,None]+5.8*np.maximum(0,top_edge)[:,:,None] +2.1*np.maximum(0,left_edge)[:,:,None]-11.5*np.maximum(0,bottom_edge)[:,:,None]
    # Controlled contrast: avoid uniformly bright plastic/rubber materials.
    rgb=(rgb-91.0)*1.075+91.0
    rgb=np.clip(rgb,0,255)
    out=Image.fromarray(np.uint8(np.dstack([rgb,a*255])),'RGBA')
    # Hard-pixel 1px contour for readability against textured industrial walls.
    src_alpha=out.getchannel('A')
    silhouette=src_alpha.point(lambda v:255 if v>38 else 0)
    dilated=silhouette.filter(ImageFilter.MaxFilter(3))
    lining=Image.new('RGBA',out.size,(*LINERS.get(theme,(24,30,29)),0))
    lining.putalpha(dilated.point(lambda v:225 if v>0 else 0))
    lining.alpha_composite(out)
    return lining

def run():
    OUT.mkdir(parents=True,exist_ok=True)
    for name in IDS:
        for angle in range(1,9):
            if (OUT/f'{name}_{angle}.png').is_file():
                continue
            src=Image.open(SRC/f'{name}_{angle}.png').convert('RGBA')
            assert src.size==(768,768)
            target=Image.new('RGBA',(768,768))
            for i in range(12):
                col=i%4;row=i//4
                tile=src.crop((col*192,row*256,(col+1)*192,(row+1)*256))
                target.alpha_composite(polish_one(tile,name),(col*192,row*256))
            target.save(OUT/f'{name}_{angle}.png',optimize=True)
    (ROOT/'art/BUILD_074_ENEMY_VISUAL_DERIVATION.json').write_text(json.dumps({
       'source':'assets/sprites/enemies_073','outputs':'assets/sprites/enemies_074','figures':len(IDS),'directions':8,
       'animation_frames_per_direction':12,'process':'material contrast, edge highlight, subtle industrial wear, 1px contrast outline',
       'truthfulness':'Derived from 07.3 low-poly 3D turntables, not the external Runway paintings.'},indent=2)+'\n')
    print('Polished',len(IDS)*8,'eight-view enemy atlases from existing 3D renders')
if __name__=='__main__':run()
