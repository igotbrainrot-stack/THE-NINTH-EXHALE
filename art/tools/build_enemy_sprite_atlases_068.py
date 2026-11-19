#!/usr/bin/env python3
"""Non-jittery 4-direction/12-pose enemy atlas baker for The Ninth Exhale.

Sources: PNG turnarounds under art/production_sources/enemies_068/NAME.png (Runway
exports; 2x2: front, left, right, back). Existing sprite-era author assets stay
as fallback for five prototype hostiles and the Echoform hearing pair.
The other ten ship with explicit original procedurally painted interim sprite
silhouettes. Never mistake these fallbacks for a downloaded Runway artwork.

The atlas uses 4 columns x 3 rows of 192x256 frames:
  row 0: idle/walk0, walk1, walk2, walk3
  row 1: windup0, windup1, attack0, attack1
  row 2: hit, death0, death1, death2
Stable canvas and feet anchors prevent independently generated pose jitter.
"""
import json, math, hashlib, random
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance, ImageChops, ImageFont
ROOT=Path(__file__).resolve().parents[2]
W,H=192,256
DIRS=['front','left','right','back']
SOURCES=ROOT/'art/production_sources/enemies_068'
OUT=ROOT/'assets/sprites/enemies_068'
SOURCES.mkdir(parents=True,exist_ok=True);OUT.mkdir(parents=True,exist_ok=True)
MANIFEST=json.loads((ROOT/'data/enemy_roster_068.json').read_text())
ALL=[e['id'] for e in MANIFEST['combat_enemies']]+['bell_wretch','rootkin']
SHORT={'sentry','pressure_mite','vent_whistler','rivet_courier','choir_reed','bell_wretch','rootkin'}
BASE={'sentry':'sentry_front.png','enforcer':'enforcer_front.png','millwright':'millwright_front.png','cantor':'cantor_front.png','bell_wretch':'bell_wretch.png','rootkin':'rootkin.png'}
METAL_COLORS={
 'edda_machine':('#6d7774','#e2d8b5','#8d6643'),
 'pressure_mite':('#6c8d87','#bcb3a7','#b77a4d'),
 'registry_bailiff':('#52616c','#a49c7b','#ae7642'),
 'vent_whistler':('#697e78','#d3be9a','#8c5d42'),
 'rivet_courier':('#698079','#b59f73','#ba6b36'),
 'slag_sifter':('#564846','#8c6f59','#d35d2d'),
 'chain_hauler':('#606466','#9f844f','#b1713f'),
 'choir_reed':('#5b7771','#d7c69b','#ae854c'),
 'saltbound_porter':('#64787a','#cbc3a7','#7b6559'),
 'sluice_beadle':('#5d6961','#a58c65','#bd8152'),
 'triage_warden':('#88938a','#e1dbb3','#bd855f')}

def rgba(hexstr,a=255):
 h=hexstr.lstrip('#');return tuple(int(h[i:i+2],16) for i in (0,2,4))+(a,)

def lighten(color,factor):
 return tuple(min(255,int(c*factor)) for c in color[:3])+(color[3],)

def make_interim(name,view):
 """Distinct handcrafted mechanical/worker silhouette, NOT a Runway source."""
 bg=Image.new('RGBA',(320,400),(0,0,0,0));d=ImageDraw.Draw(bg)
 color,light,accent=METAL_COLORS[name];dark=rgba('#201f22');steel=rgba(color);ivory=rgba(light);rust=rgba(accent)
 rng=random.Random(int(hashlib.sha1((name+view).encode()).hexdigest()[:8],16))
 side=view in ('left','right');back=view=='back'
 # A fixed 320x400 coordinate system. Coordinates echo functional municipal equipment.
 def rounded(box,fill,rad=8,outline=dark,wd=5):d.rounded_rectangle(box,radius=rad,fill=fill,outline=outline,width=wd)
 def bar(coords,fill=steel,width=12):d.line(coords,fill=fill,width=width,joint='curve')
 def rivets(xys):
  for x,y in xys:
   d.ellipse((x-4,y-4,x+4,y+4),fill=ivory,outline=dark,width=2)
 humanoid=name in ('registry_bailiff','saltbound_porter','triage_warden')
 is_long=name in ('chain_hauler','choir_reed','triage_warden')
 short=name in ('pressure_mite','vent_whistler','rivet_courier')
 # grounded feet/treads, consistent contact line y=384
 if humanoid or is_long:
  leg_w=36 if side else 42
  for x in ((139,186) if side else (112,202)):
   yy=233 if is_long else 253
   rounded((x-leg_w//2,yy,x+leg_w//2,366),steel,8)
   rounded((x-leg_w//2-11,356,x+leg_w//2+15,382),rust,7)
   rivets([(x,280),(x,337)])
 elif name in ('slag_sifter','sluice_beadle','edda_machine'):
  rounded((63,307,257,382),dark,26)
  for x in (82,216):rounded((x-26,313,x+26,382),rust,12)
  rivets([(77,332),(243,332)])
 else:
  for x in (83,236):
   bar([(158,250),(x,310),(x,363)],rust,14)
   rounded((x-20,356,x+20,383),steel,7)
 # torso/main apparatus
 width=112 if side else 174
 l=160-width//2;rr=160+width//2
 if name=='pressure_mite':
  rounded((90,190,236,290),steel,26)
  rounded((109,214,205,258),ivory,12)
  d.ellipse((148,218,181,251),fill=rust,outline=dark,width=4)
  for y in (204,245,285):
   bar([(90,y),(56,y+36),(45,y+72)],steel,7)
   bar([(228,y),(263,y+36),(275,y+72)],steel,7)
  rivets([(120,201),(207,272)])
 elif name=='vent_whistler':
  rounded((127,274,194,367),steel,12)
  for i,(x,h) in enumerate(((100,120),(160,86),(223,131))):
   bar([(x,272),(x,h+68)],steel,14)
   d.polygon([(x-23,h+66),(x-12,h),(x+12,h),(x+23,h+66)],fill=ivory,outline=dark)
  rounded((96,224,227,272),rust,9)
  rivets([(115,249),(205,249)])
 elif name=='choir_reed':
  rounded((109,142,212,305),steel,16)
  for x,h in zip((116,150,189,217),(76,101,59,91)):
   rounded((x-10,h,x+10,165),ivory,5)
  rounded((118,177,204,236),rust,8)
  for j in range(6):bar([(136,186+j*7),(192,186+j*7)],dark,2)
  rivets([(125,266),(195,266)])
 elif name=='rivet_courier':
  rounded((105,150,227,307),steel,7)
  rounded((183,177,252,279),ivory,7)
  for yy in range(182,260,18):rounded((199,yy,237,yy+11),rust,2)
  rounded((84,203,131,289),rust,6)
  rivets([(122,168),(215,290)])
 elif name=='slag_sifter':
  rounded((62,190,262,337),steel,15)
  d.polygon([(65,193),(104,148),(226,148),(263,193)],fill=rust)
  for j in range(9):bar([(86,231+j*9),(238,231+j*9)],dark,3)
  rounded((124,125,205,181),ivory,9)
  rivets([(82,209),(242,313)])
 elif name=='chain_hauler':
  rounded((115,152,207,306),steel,11)
  d.ellipse((99,103,229,220),fill=rust,outline=dark,width=8)
  for radius in (47,28,13):d.ellipse((164-radius,163-radius,164+radius,163+radius),outline=ivory,width=5)
  bar([(95,193),(58,263),(77,305)],rust,16)
  bar([(220,193),(261,265),(235,328)],rust,16)
  d.arc((212,275,281,348),-5,205,fill=ivory,width=13)
  rivets([(125,260),(185,260)])
 elif name=='sluice_beadle':
  rounded((72,152,246,336),steel,11)
  rounded((109,183,209,301),rust,3)
  for x in range(122,208,19):bar([(x,199),(x,286)],ivory,4)
  rounded((90,128,235,181),steel,8)
  rivets([(87,167),(233,167),(100,321),(216,321)])
 elif name=='edda_machine':
  rounded((87,133,238,321),steel,12)
  for y in (164,213,259):rounded((104,y,223,y+23),ivory,3)
  for x in (130,162,195):d.ellipse((x-10,103,x+10,123),fill=rust,outline=dark,width=3)
  bar([(161,128),(161,82)],ivory,8)
  rounded((128,73,194,115),rust,5)
  rivets([(110,144),(212,309)])
 elif humanoid:
  # public employee uniform with working posture
  rounded((l,147,rr,286),steel,16)
  for x in ((l+22,rr-22) if not side else (l+18,)):
   bar([(x,174),(x-15 if x<160 else x+15,293)],ivory,6)
  for x in (l-10,rr+10):
   rounded((x-19,160,x+19,276),rust,10)
  rounded((119,64,205,149),ivory,26)
  d.ellipse((127,63,198,137),fill=rgba('#a28b79'),outline=dark,width=5)
  if not back:
   for x in (144,179):d.ellipse((x-4,107,x+4,114),fill=dark)
   bar([(142,125),(179,125)],dark,3)
  else:rounded((123,69,204,105),rust,12)
  rounded((l-8,150,rr+8,169),ivory,6)
  rounded((124,233,198,278),rust,5)
  if name=='registry_bailiff':rounded((70 if not side else 105,167,128 if not side else 154,283),ivory,7)
  if name=='saltbound_porter':
   for x in (128,173,203):
    for y in (182,229,252):d.ellipse((x-2,y-2,x+2,y+2),fill=ivory)
  if name=='triage_warden':
   rounded((l,155,rr,253),ivory,8)
   rounded((137,101,188,160),dark,2)
   rivets([(110,190),(210,190)])
 # Grain and wear (same distribution for the same pose; never animated random flicker)
 px=bg.load()
 for i in range(2400):
  x=rng.randrange(55,269);y=rng.randrange(60,372)
  if px[x,y][3] > 100 and rng.random()<.58:
   if rng.random()<.5: px[x,y]=(*lighten(px[x,y],rng.choice((0.65,0.8,1.18,1.25)))[:3],px[x,y][3])
 # Use the same identical image for all directions when no painted turnaround exists.
 # Mirroring is honest as an interim sprite, not falsely described as distinct art.
 if view=='left':bg=bg.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
 elif view=='back':bg=bg.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
 return bg

def magenta_cutout(im):
 im=im.convert('RGBA')
 # Magenta key: precise hot-pink backgrounds with 10% smooth edge feather.
 import numpy as np
 a=np.asarray(im).copy().astype('float32')
 r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
 pink=(r>165)&(b>145)&(g<155)&((r+b)>g*3.1)
 # Remove true chroma backdrop but avoid deleting dark purple artwork.
 strength=np.clip((r-150)/55,0,1)*np.clip((b-g-40)/80,0,1)*np.clip((r-g-55)/70,0,1)
 a[:,:,3]=np.minimum(a[:,:,3],255*(1-strength))
 a[pink,3]=0
 return Image.fromarray(np.uint8(np.clip(a,0,255)),'RGBA')

def source_views(name):
 source=SOURCES/f'{name}.png'
 if source.exists():
  im=magenta_cutout(Image.open(source))
  w,h=im.size
  # Top left F, top right L, bottom left R, bottom right B.
  return {k:im.crop((q%2*w//2,q//2*h//2,(q%2+1)*w//2,(q//2+1)*h//2)) for q,k in enumerate(DIRS)},'Runway exported source'
 if name in BASE:
  art=Image.open(ROOT/'assets/sprites'/BASE[name]).convert('RGBA')
  # Existing local source is one view, with mirrored companion views.
  return {'front':art,'left':art.transpose(Image.Transpose.FLIP_LEFT_RIGHT),'right':art,'back':art.transpose(Image.Transpose.FLIP_LEFT_RIGHT)},'Build 06.7 author sprite'
 return {k:make_interim(name,k) for k in DIRS},'Original vector-painted interim (Runway source pending export)'

def prepare(im):
 im=im.convert('RGBA');bbox=im.getbbox()
 if bbox is None: return Image.new('RGBA',(W,H),(0,0,0,0))
 cropped=im.crop(bbox)
 maxw,maxh=W-27,H-24
 scale=min(maxw/max(1,cropped.width),maxh/max(1,cropped.height))
 newsize=(max(1,int(cropped.width*scale)),max(1,int(cropped.height*scale)))
 cropped=cropped.resize(newsize,Image.Resampling.LANCZOS)
 target=Image.new('RGBA',(W,H),(0,0,0,0))
 target.alpha_composite(cropped,((W-newsize[0])//2,H-13-newsize[1]))
 return target

def shift_section(img,y0,y1,x_left,x_right):
 top=img.crop((0,0,W,y0))
 bot_left=img.crop((0,y0,W//2,y1)); bot_right=img.crop((W//2,y0,W,y1))
 out=Image.new('RGBA',(W,H),(0,0,0,0))
 out.alpha_composite(top)
 out.alpha_composite(bot_left,(x_left,y0));out.alpha_composite(bot_right,(W//2+x_right,y0))
 if y1<H:out.alpha_composite(img.crop((0,y1,W,H)),(0,y1))
 return out

def pose(img,idx):
 if idx==0:return img
 if idx in (1,2,3):
  if idx==2:return img
  d=4 if idx==1 else -4
  return shift_section(img,166,247,-d,d)
 if idx in (4,5):
  # windup rises only on rigid torso; keep feet baseline and 2px movement.
  out=Image.new('RGBA',(W,H),(0,0,0,0))
  u=img.crop((0,0,W,173));out.alpha_composite(u,(0,-3 if idx==4 else -6))
  out.alpha_composite(img.crop((0,173,W,H)),(0,173))
  # tiny amber finite pressure lamp at chest (same size per frame).
  draw=ImageDraw.Draw(out)
  cx=W//2+34;cy=73 if idx==4 else 68
  draw.ellipse((cx-5,cy-5,cx+5,cy+5),fill=(243,188,98,245),outline=(34,28,22,255),width=2)
  return out
 if idx in (6,7):
  # attack snap from the same source pixels, never a redrawn body.
  d=6 if idx==6 else 3
  out=Image.new('RGBA',(W,H),(0,0,0,0))
  out.alpha_composite(img.crop((0,0,W,180)),(d,0))
  out.alpha_composite(img.crop((0,180,W,H)),(0,180))
  return out
 if idx==8:
  out=ImageEnhance.Brightness(img).enhance(1.4)
  tint=Image.new('RGBA',(W,H),(250,178,104,0))
  return Image.blend(out,tint,0.13)
 # death: collapse without shifting foot baseline; alpha fade in final frame.
 scale={9:0.82,10:0.51,11:0.25}[idx]
 bbox=img.getbbox()
 if not bbox:return img
 shot=img.crop(bbox)
 out=Image.new('RGBA',(W,H),(0,0,0,0))
 h=max(4,int(shot.height*scale));resized=shot.resize((shot.width,h),Image.Resampling.BICUBIC)
 if idx==11:
  a=resized.getchannel('A').point(lambda v:int(v*.50));resized.putalpha(a)
 out.alpha_composite(resized,((W-shot.width)//2,H-13-h))
 return out

def bake_one(name):
 views,origin=source_views(name);res=[]
 for face,source in views.items():
  base=prepare(source)
  atlas=Image.new('RGBA',(W*4,H*3),(0,0,0,0))
  for i in range(12):atlas.alpha_composite(pose(base,i),((i%4)*W,(i//4)*H))
  output=OUT/f'{name}_{face}.png';atlas.save(output,optimize=True)
  res.append(output)
 return {'id':name,'provenance':origin,'runway_source_path':str((SOURCES/f'{name}.png').relative_to(ROOT)) if (SOURCES/f'{name}.png').exists() else None,'atlas_files':[str(p.relative_to(ROOT)) for p in res]}

def preview(rows):
 out=Image.new('RGB',(1400,((len(rows)+4)//5)*320),(25,25,29));d=ImageDraw.Draw(out)
 f=ImageFont.load_default()
 for i,row in enumerate(rows):
  image=Image.open(ROOT/row['atlas_files'][0]).convert('RGBA').crop((0,0,W,H))
  image.thumbnail((204,260))
  x=(i%5)*280+30;y=(i//5)*320+16
  out.paste(image,(x+(204-image.width)//2,y),image)
  label=row['id'].replace('_',' ').title()
  d.text((x,y+265),label,fill=(230,223,202),font=f)
  d.text((x,y+281),'RUNWAY' if row['runway_source_path'] else 'INTERIM',fill=(151,177,156),font=f)
 out.save(ROOT/'art/previews/BUILD_068_ENEMY_ROSTER.png')

def main():
 rows=[bake_one(x) for x in ALL]
 note={'atlas_format':'4x3 each 192x256 RGBA','directions':DIRS,'frames':['idle','walk_a','walk_b','walk_c','windup_a','windup_b','attack_a','attack_b','hurt','death_a','death_b','death_c'],'art':rows,'runway_raw_embedded_count':sum(1 for r in rows if r['runway_source_path']),'claim':'Atlases are runtime-ready. When Runway raw PNGs are absent, see provenance for embedded-author-sprite versus procedurally painted interim. No external Runway image is falsely claimed as embedded.'}
 (ROOT/'art/ENEMY_ANIMATION_MANIFEST_068.json').write_text(json.dumps(note,indent=2)+'\n')
 preview(rows)
 print('Rendered',len(rows),'sets × 4 directional atlases × 12 frames =',len(rows)*48,'atlas frames')
 print('Runway source PNGs imported:',note['runway_raw_embedded_count'])

if __name__=='__main__':main()
