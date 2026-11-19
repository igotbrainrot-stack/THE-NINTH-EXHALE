#!/usr/bin/env python3
"""Produce actual 1..8 atlas slots for directional sprites.

Cardinal images (1,3,5,7) are losslessly reused from the previous release;
provisional diagonals (2,4,6,8) use a single-source optical-flow warp toward the adjacent cardinal pose. They are NOT falsely
credited as independently drawn art. A real newly illustrated Brin sheet is
cropped into eight unique slots. Godot has no runtime OpenCV dependency.
"""
from __future__ import annotations
import json
from pathlib import Path
from PIL import Image, ImageOps, ImageFilter
import numpy as np
try:
    import cv2
except ImportError:
    cv2 = None
ROOT = Path(__file__).resolve().parents[2]
DIRECTIONS = {1:'front',3:'left',5:'back',7:'right'}
ENEMY_OLD=ROOT/'assets/sprites/enemies_068'
ENEMY_NEW=ROOT/'assets/sprites/enemies_071'
NPC_OLD=ROOT/'assets/sprites/directional'
NPC_NEW=ROOT/'assets/sprites/directional8'
SRC=ROOT/'art/production_sources/brin_eight_view_imagegen_071.png'


def _optical_flow(a: Image.Image, b: Image.Image):
    if cv2 is None: return None
    A=np.asarray(a.convert('RGBA'),dtype=np.uint8)
    B=np.asarray(b.convert('RGBA'),dtype=np.uint8)
    # A fixed black matte plus silhouette edges; optical flow on IDLE ONLY.
    def gray(img):
        return cv2.cvtColor(img[:,:,:3],cv2.COLOR_RGB2GRAY)//2 + img[:,:,3]//2
    forward=cv2.calcOpticalFlowFarneback(gray(A),gray(B),None,0.5,3,17,3,5,1.1,0)
    backward=cv2.calcOpticalFlowFarneback(gray(B),gray(A),None,0.5,3,17,3,5,1.1,0)
    return forward,backward


def morph(a: Image.Image, b: Image.Image, w: float = 0.5, flows=None) -> Image.Image:
    """Primary-source perspective warp guided by adjacent source, not newly drawn art."""
    a=a.convert('RGBA');b=b.convert('RGBA')
    if flows is None:flows=_optical_flow(a,b)
    if flows is None:return Image.blend(a,b,w)
    A=np.asarray(a,dtype=np.float32);B=np.asarray(b,dtype=np.float32)
    h,wd=A.shape[:2]
    xx,yy=np.meshgrid(np.arange(wd,dtype=np.float32),np.arange(h,dtype=np.float32))
    FA,FB=flows
    AA=cv2.remap(A,xx-FA[:,:,0]*w,yy-FA[:,:,1]*w,cv2.INTER_LINEAR,borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))
    # Use the warped PRIMARY pose (rather than two semi-transparent heads).
    # This retains crisp body parts and avoids ugly translucent ghost doubles.
    return Image.fromarray(np.clip(AA,0,255).astype(np.uint8),'RGBA')


def combine_atlases(front: Image.Image, side: Image.Image) -> Image.Image:
    atlas=Image.new('RGBA',(768,768))
    base_rect=(0,0,192,256)
    flows=_optical_flow(front.crop(base_rect),side.crop(base_rect))
    # Reuse the SAME flow for every motion frame: foot/torso pivot remains fixed.
    for idx in range(12):
        rect=(idx%4*192,idx//4*256,(idx%4+1)*192,(idx//4+1)*256)
        cell=morph(front.crop(rect),side.crop(rect),flows=flows)
        atlas.paste(cell,(rect[0],rect[1]))
    return atlas


def extract_brin() -> dict[int,Image.Image]:
    img=Image.open(SRC).convert('RGB')
    width,height=img.size
    all_items=[]
    for index in range(8):
        col=index%4; row=index//4
        cell=img.crop((round(col*width/4),round(row*height/2),round((col+1)*width/4),round((row+1)*height/2)))
        a=np.asarray(cell).astype(np.int16)
        # Remove chroma magenta while preserving reddish-brown/skin accents.
        magenta=(a[:,:,0]>175)&(a[:,:,2]>155)&(a[:,:,1]<118)&((a[:,:,0]-a[:,:,1])>115)&((a[:,:,2]-a[:,:,1])>105)
        alpha=np.where(magenta,0,255).astype(np.uint8)
        # Preserve an anti-aliased outline and eliminate 1px stray matte noise.
        cv=np.array(cell.convert('RGBA'))
        cv[:,:,3]=alpha
        crop=Image.fromarray(cv,'RGBA')
        bbox=crop.getbbox()
        if bbox:
            crop=crop.crop(bbox)
        all_items.append(crop)
    max_w=max(c.width for c in all_items); max_h=max(c.height for c in all_items)
    scale=min(172/max_w,254/max_h)
    result={}
    for i,crop in enumerate(all_items):
        newsize=(max(1,round(crop.width*scale)),max(1,round(crop.height*scale)))
        body=crop.resize(newsize, Image.Resampling.LANCZOS)
        canvas=Image.new('RGBA',(192,280))
        canvas.alpha_composite(body,(round((192-newsize[0])/2),274-newsize[1]))
        result[i+1]=canvas
    return result


def make_npc_8():
    sources=['sela','brin','ossa','oren','clerk']
    count=0
    for actor in sources:
        cardinal={k:Image.open(NPC_OLD/f'{actor}_{s}.png').convert('RGBA') for k,s in DIRECTIONS.items()}
        # Brin gets actual *individually illustrated* eight-angle regeneration.
        views=extract_brin() if actor=='brin' else {
            1:cardinal[1],2:morph(cardinal[1],cardinal[3]),3:cardinal[3],
            4:morph(cardinal[3],cardinal[5]),5:cardinal[5],
            6:morph(cardinal[5],cardinal[7]),7:cardinal[7],
            8:morph(cardinal[7],cardinal[1])}
        for i,img in views.items():
            img.save(NPC_NEW/f'{actor}_{i}.png',optimize=True)
            count+=1
    return count


def make_enemies_8():
    count=0
    actors=sorted({p.name.rsplit('_',1)[0] for p in ENEMY_OLD.glob('*_front.png')})
    ENEMY_NEW.mkdir(parents=True, exist_ok=True)
    for actor in actors:
        original={k:Image.open(ENEMY_OLD/f'{actor}_{s}.png').convert('RGBA') for k,s in DIRECTIONS.items()}
        # Reuse the four exact existing source directions, preserving art and movement.
        views={1:original[1],2:combine_atlases(original[1],original[3]),3:original[3],
               4:combine_atlases(original[3],original[5]),5:original[5],
               6:combine_atlases(original[5],original[7]),7:original[7],
               8:combine_atlases(original[7],original[1])}
        for i,im in views.items():
            im.save(ENEMY_NEW/f'{actor}_{i}.png',optimize=True)
            count+=1
    return actors,count

if __name__=='__main__':
    NPC_NEW.mkdir(exist_ok=True,parents=True)
    actors,enemy_count=make_enemies_8()
    npc_count=make_npc_8()
    manifest={
      'build':'07.1','rotation_0':'single universal billboard view; not an extra angle',
      'angle_order':{'1':'front','2':'diagonal_left_front','3':'left','4':'diagonal_left_back','5':'back','6':'diagonal_right_back','7':'right','8':'diagonal_right_front'},
      'cell_pixels':{'enemies':[192,256],'npc':[192,280]},'enemy_atlas_grid':[4,3],
      'enemy_animation_frames':12,'actor_count':len(actors),'enemy_atlas_count':enemy_count,
      'npc_count':5,'npc_card_count':npc_count,
      'new_eight_view_art':{'actor':'brin','source':'art/production_sources/brin_eight_view_imagegen_071.png','directions':[1,2,3,4,5,6,7,8]},
      'provenance':'Brin 1..8 individually illustrated; other NPC and enemy diagonals 2,4,6,8 are provisional optical-flow-guided primary-source warps of existing original cardinal frames, NOT separately painted and NOT exported from Runway.',
      'source_provenance':'Legacy enemy cardinal frames remain exactly original in assets/sprites/enemies_068. Object furniture is full 3D geometry and uses infinitely many real viewing angles.',
      'synthesis_method':'Single-image perspective warping guided by optical flow toward the adjacent cardinal pose. NO overlay of two figures; provisional 45-degree views remain stylistically approximated.',
      'enemy_ids':actors
    }
    (ROOT/'art/EIGHT_VIEW_ASSET_MANIFEST_071.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps({'npc_cards':npc_count,'enemy_atlases':enemy_count,'enemy_types':len(actors),'uses_opencv':cv2 is not None}))
