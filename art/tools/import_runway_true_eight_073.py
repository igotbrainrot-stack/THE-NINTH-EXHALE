#!/usr/bin/env python3
"""Import actual Runway 2x4 actor turnaround sheets into Build 07.3.

This tool exists because prior '8-direction' images merely renamed/small-warped
front sprites. Imports are quality gated and atomic *per actor*: a failed view
set never overwrites a working 3D-turntable fallback.

Examples:
  python3 art/tools/import_runway_true_eight_073.py --source ~/Downloads/Ninth_Runway_073 --dry-run
  python3 art/tools/import_runway_true_eight_073.py --source ~/Downloads/Ninth_Runway_073
  python3 art/tools/import_runway_true_eight_073.py --source ~/Downloads/Ninth_Runway_073 --partial

Each source file is named e.g. 'sela.png', 'millwright.png', etc and must contain
exactly 2 rows x 4 views in angle order 1..8, chroma magenta behind subjects.
The 12 derived enemy animation poses remain motion proxies, not genuine full
hand-drawn walk/attack/death animations.
"""
from __future__ import annotations
import argparse, json, hashlib, shutil, sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(Path(__file__).parent))
from import_runway_eight_views_072 import split_sheet, make_enemy_atlas, make_atlas, NPCS
MANIFEST=ROOT/'art/RUNWAY_073_REGENERATION.json'
NPC_DIR=ROOT/'assets/sprites/directional8'
NPC_IDLE=ROOT/'assets/sprites/npc_idle_072'
ENEMY_DIR=ROOT/'assets/sprites/enemies_073'
ORIG=ROOT/'art/production_sources/runway_073'
PREVIEW=ROOT/'art/previews/BUILD_073_IMPORT_REVIEW.png'


def image_pixels(im:Image.Image)->np.ndarray:
    # Compare a raster composited on game-neutral material: alpha differences
    # and view-dependent color details should both be significant.
    x=im.convert('RGBA').resize((96,128),Image.Resampling.BILINEAR)
    neutral=Image.new('RGBA',x.size,(44,49,47,255))
    neutral.alpha_composite(x)
    return np.asarray(neutral.convert('RGB'),dtype=np.float32)


def quality_gate(views:list[Image.Image])->dict:
    if len(views)!=8:
        return {'passed':False,'issues':['eight distinct views required']}
    arrays=[image_pixels(i) for i in views]
    coverage=[float((np.asarray(i.getchannel('A'))>128).mean()) for i in views]
    differences={(i+1,j+1):float(np.abs(arrays[i]-arrays[j]).mean()) for i in range(8) for j in range(i+1,8)}
    minimum=min(differences.values())
    front_back=differences[(1,5)]
    side_front=min(differences[(1,3)],differences[(1,7)])
    issues=[]
    if min(coverage)<.025:issues.append('some slots contain no adequately sized subject')
    if max(coverage)>.84:issues.append('background removal probably failed or subject is cropped')
    if minimum<2.5:issues.append(f'near-duplicate view pair {min(differences,key=differences.get)}: RGB difference {minimum:.2f}')
    if front_back<4.0:issues.append(f'back and front too similar: {front_back:.2f}')
    if side_front<3.5:issues.append(f'side profiles too similar to front: {side_front:.2f}')
    return {'passed':not issues,'issues':issues,'minimum_rgb_difference':round(minimum,2),
            'front_to_back_rgb_difference':round(front_back,2),
            'min_side_to_front_rgb_difference':round(side_front,2),
            'coverage':[round(c,3) for c in coverage],
            'note':'Automated screen only; manual angle-by-angle review is still required to catch wrong left/right or incorrect props'}


def contact(views:dict[str,list[Image.Image]],dst:Path)->None:
    width=1050;height=80+len(views)*122
    im=Image.new('RGB',(width,height),(26,33,32));d=ImageDraw.Draw(im)
    d.text((10,12),'RUNWAY 073 / EIGHT INDEPENDENT DIRECTIONAL VIEWS — MANUAL REVIEW',fill=(237,208,160))
    d.text((10,35),'1 FRONT  2 FRONT-LEFT  3 LEFT  4 BACK-LEFT  5 BACK  6 BACK-RIGHT  7 RIGHT  8 FRONT-RIGHT',fill=(170,188,172))
    for j,(key,imgs) in enumerate(sorted(views.items())):
        y=70+j*122;d.text((10,y+52),key.replace('_',' '),fill=(244,218,172))
        for i,view in enumerate(imgs):
            thumb=view.copy();thumb.thumbnail((99,106),Image.Resampling.LANCZOS)
            bg=Image.new('RGBA',thumb.size,(56,63,58,255));bg.alpha_composite(thumb)
            im.paste(bg.convert('RGB'),(145+i*112+(99-thumb.width)//2,y))
    dst.parent.mkdir(parents=True,exist_ok=True);im.save(dst)


def main():
    a=argparse.ArgumentParser(description=__doc__)
    a.add_argument('--source',type=Path,required=True)
    a.add_argument('--dry-run',action='store_true')
    a.add_argument('--partial',action='store_true',help='Explicitly allow fewer than all 22 sources')
    args=a.parse_args()
    if not args.source.is_dir():a.error('Source folder not found')
    spec=json.loads(MANIFEST.read_text())['characters']
    found={}
    for k in spec:
        for name in [f'{k}.png',f'{k}_8view.png',f'{k}_8views.png']:
            p=args.source/name
            if p.is_file():found[k]=p;break
    missing=sorted(set(spec)-set(found))
    print(f'{len(found)} / {len(spec)} original 2x4 PNGs found.')
    if missing:print('Missing:',', '.join(missing))
    if missing and not args.partial:raise SystemExit('Strict mode: all 22 exports required, or explicitly pass --partial')
    report={'build':'07.3','expected':len(spec),'found':len(found),'missing':missing,'actors':{},
            'warning':'Each sheet MUST be inspected by a human for camera angle correctness and costume continuity. Automated anti-duplicate checks cannot recognise all semantic errors.'}
    staged={};review={}
    for key,path in sorted(found.items()):
        try:
            views=split_sheet(path,(192,280) if key in NPCS else (192,256))
            qc=quality_gate(views)
        except Exception as e:
            qc={'passed':False,'issues':[f'parsing failed: {e}']}
            views=[]
        report['actors'][key]={'quality':qc,'source_sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        if views:review[key]=views
        if qc['passed']:staged[key]=(path,views)
        else:print('REJECTED',key,' / '.join(qc['issues']))
    contact(review,PREVIEW)
    if args.dry_run:
        print('Dry run only. Preview:',PREVIEW)
    else:
        for key,(path,views) in staged.items():
            ORIG.mkdir(parents=True,exist_ok=True)
            shutil.copy2(path,ORIG/f'{key}_8view.png')
            target=NPC_DIR if key in NPCS else ENEMY_DIR
            target.mkdir(parents=True,exist_ok=True)
            for i,view in enumerate(views,1):
                if key in NPCS:
                    view.save(target/f'{key}_{i}.png',compress_level=1)
                    NPC_IDLE.mkdir(parents=True,exist_ok=True)
                    make_atlas(view).save(NPC_IDLE/f'{key}_{i}.png',compress_level=1)
                else:
                    make_enemy_atlas(view).save(target/f'{key}_{i}.png',compress_level=1)
            print('IMPORTED',key,'all eight painted views')
    report['imported']=0 if args.dry_run else len(staged)
    report['rejected']=sorted(set(found)-set(staged))
    (ROOT/'art/RUNWAY_073_IMPORT_REPORT.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Quality review:',PREVIEW,'Imported:',report['imported'],'Rejected:',len(report['rejected']))
    if report['rejected']:raise SystemExit('Quality failures: rejected sprite sheets were NOT installed.')

if __name__=='__main__':main()
