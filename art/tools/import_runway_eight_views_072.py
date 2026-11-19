#!/usr/bin/env python3
"""Import user-exported Runway 2x4 eight-angle sprite sheets.

  python3 art/tools/import_runway_eight_views_072.py --source ~/Downloads/ninth_runway_sheets

Never fabricates a finished eight-angle render when an export is missing.
Original source sheets are preserved under art/production_sources/runway_072/.
Runtime output uses old game's 192x280 NPC and 768x768 enemy atlas layouts.
The 12 derived enemy animation poses are deterministic MOTION PROXIES, not
independently painted animation frames. Source sheets show 8 still angles.
"""
from __future__ import annotations
import argparse,json,shutil
from pathlib import Path
import numpy as np
from PIL import Image, ImageEnhance
from build_npc_ambient_atlases_072 import make_atlas

ROOT=Path(__file__).resolve().parents[2]
MANIFEST=ROOT/'art/RUNWAY_072_SOURCE_REQUESTS.json'
NPCS={'sela','brin','ossa','oren','clerk'}
OUT_NPC=ROOT/'assets/sprites/directional8'
OUT_ENEMY=ROOT/'assets/sprites/enemies_071'
OUT_NPC_IDLE=ROOT/'assets/sprites/npc_idle_072'
OUT_ORIGINAL=ROOT/'art/production_sources/runway_072'
ANGLE_NAMES={1:'front',2:'front_left',3:'left',4:'back_left',5:'back',6:'back_right',7:'right',8:'front_right'}


def cut_magenta(cell:Image.Image)->Image.Image:
    src=np.array(cell.convert('RGB'),dtype=np.float32)
    red,green,blue=src[:,:,0],src[:,:,1],src[:,:,2]
    # Progressive edge alpha around a saturated magenta studio matte.
    diff=np.minimum(red-green,blue-green)
    chroma=(red>105)&(blue>105)&(diff>35)
    power=np.clip((diff-40)/45,0,1)
    alpha=255*(1-power*chroma)
    # Prevent purple halos where antialiased edges mix the background.
    a=np.clip(alpha/255.,0,1)
    safe=np.maximum(a,.16)
    bg=np.array([255.,0.,255.],dtype=np.float32)
    cleaned=(src-bg[None,None,:]*(1-a[:,:,None]))/safe[:,:,None]
    cleaned=np.clip(cleaned,0,255)
    rgba=np.concatenate((cleaned,alpha[:,:,None]),axis=2).astype('uint8')
    result=Image.fromarray(rgba,'RGBA')
    bb=result.getbbox()
    return result.crop(bb) if bb else Image.new('RGBA',(8,8))


def split_sheet(source:Path,cell_size:tuple[int,int])->list[Image.Image]:
    src=Image.open(source).convert('RGB')
    width,height=src.size
    views=[]
    for i in range(8):
        c=i%4;r=i//4
        part=src.crop((round(c*width/4),round(r*height/2),round((c+1)*width/4),round((r+1)*height/2)))
        views.append(cut_magenta(part))
    w,h=cell_size
    # Shared scale means the same character never grows when changing angles.
    shared_scale=min((w-14)/max(im.width for im in views),(h-8)/max(im.height for im in views))
    result=[]
    for view in views:
        scaled=view.resize((max(1,round(view.width*shared_scale)),max(1,round(view.height*shared_scale))),Image.Resampling.LANCZOS)
        cell=Image.new('RGBA',(w,h))
        cell.alpha_composite(scaled,((w-scaled.width)//2,h-scaled.height-3))
        result.append(cell)
    return result


def motion_proxy(original:Image.Image,pose:int)->Image.Image:
    """A consistent view-space motion proxy for a newly-painted static view."""
    w,h=original.size
    if pose<4:
        dx=[0,2,0,-2][pose]
        dy=[0,-2,0,-2][pose]
        angle=[0.,1.1,0.,-1.1][pose]
        scale=1.0
    elif pose<6:
        dx=-3;dy=3;angle=[-4.0,-5.0][pose-4];scale=.985
    elif pose<8:
        dx=3;dy=-3;angle=[5.0,3.5][pose-6];scale=1.0
    elif pose==8:
        dx=-4;dy=2;angle=-4;scale=.98
    else:
        dx=0;dy=round((pose-8)*5);angle=[0,14,31][pose-9];scale=1.0-(pose-9)*.07
    img=original.rotate(angle,Image.Resampling.BICUBIC,center=(w*.50,h*.91))
    if scale!=1:
        img=img.resize((round(w*scale),round(h*scale)),Image.Resampling.BICUBIC)
    target=Image.new('RGBA',(w,h))
    target.alpha_composite(img,(round((w-img.width)/2+dx),round(h-img.height+dy)))
    if pose==8:
        # brief mechanical hit response; preserve transparency and silhouette
        rgb=ImageEnhance.Brightness(target).enhance(1.18)
        target=rgb
    if pose>=9:
        a=target.getchannel('A').point(lambda v:round(v*[.98,.78,.55][pose-9]))
        target.putalpha(a)
    return target


def make_enemy_atlas(view:Image.Image)->Image.Image:
    atlas=Image.new('RGBA',(768,768))
    for i in range(12):
        frame=motion_proxy(view,i)
        atlas.alpha_composite(frame,((i%4)*192,(i//4)*256))
    return atlas


def import_one(key:str,source:Path)->None:
    is_npc=key in NPCS
    result=split_sheet(source,(192,280) if is_npc else (192,256))
    dest=OUT_NPC if is_npc else OUT_ENEMY
    dest.mkdir(parents=True,exist_ok=True)
    if is_npc:OUT_NPC_IDLE.mkdir(parents=True,exist_ok=True)
    originals=OUT_ORIGINAL
    originals.mkdir(parents=True,exist_ok=True)
    shutil.copy2(source,originals/f'{key}_8view.png')
    for angle,still in enumerate(result,1):
        image=still if is_npc else make_enemy_atlas(still)
        image.save(dest/f'{key}_{angle}.png',optimize=True)
        if is_npc:
            make_atlas(still).save(OUT_NPC_IDLE/f'{key}_{angle}.png',optimize=True)


def main()->None:
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,required=True)
    parser.add_argument('--dry-run',action='store_true')
    parser.add_argument('--strict',action='store_true',help='Require all 22 exports, otherwise stop')
    args=parser.parse_args()
    if not args.source.is_dir():parser.error(f'No export folder: {args.source}')
    spec=json.loads(MANIFEST.read_text())
    resolved={}
    for actor in spec:
        for variant in [actor+'.png',actor+'_8view.png',actor+'_8views.png']:
            if (args.source/variant).is_file():
                resolved[actor]=args.source/variant;break
    missing=sorted(set(spec)-set(resolved))
    print(f'Runway exports found: {len(resolved)} / {len(spec)}')
    if missing:print('Still missing:',', '.join(missing))
    if args.strict and missing:raise SystemExit('Strict import requires every character source')
    if args.dry_run:return
    for actor,src in sorted(resolved.items()):
        import_one(actor,src)
        print(f'  {actor}: eight full static views' + (' / NPC' if actor in NPCS else ' / 12 proxy animation atlas frames each'))
    report={'embedded_completed_count':len(resolved),'pending_external':missing,
       'caution':'Generated source image perspective consistency needs manual QA; procedural motion proxies are not hand-animated full walk cycles.',
       'angles':'1 front, 2 front-left, 3 left, 4 back-left, 5 back, 6 back-right, 7 right, 8 front-right'}
    (ROOT/'art/RUNWAY_072_IMPORT_REPORT.json').write_text(json.dumps(report,indent=2)+'\n')

if __name__=='__main__':main()
