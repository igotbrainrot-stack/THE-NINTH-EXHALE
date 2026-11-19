#!/usr/bin/env python3
"""Creates a 100% source-backed authoring preview, NOT a Godot screenshot."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageOps
import re
ROOT=Path(__file__).resolve().parents[2]
out=ROOT/'art/previews/BUILD_075_ASHMARKET_AUTHORING_PREVIEW.png'
out.parent.mkdir(exist_ok=True,parents=True)
W,H=1740,1000
im=Image.new('RGB',(W,H),(20,27,26));d=ImageDraw.Draw(im)
try:
 font_big=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',36)
 font_med=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',20)
 font_sm=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',16)
except:font_big=font_med=font_sm=None
cream=(232,215,182);muted=(154,165,153);amber=(205,153,83);red=(169,91,72)
d.text((52,38),'THE NINTH EXHALE / BUILD 07.5',font=font_big,fill=cream)
d.text((54,94),'ASHMARKET — THIRD WRIT OFFICE  /  ACTUAL SOURCE ASSETS + AUTHORING MAP',font=font_sm,fill=muted)
# top layout panel
region=(40,150,882,926)
d.rounded_rectangle(region,radius=8,fill=(31,38,36),outline=amber,width=3)
d.text((65,171),'PHYSICAL MARKET FLOOR PLAN',font=font_med,fill=cream)
d.text((65,203),'Top-down authored geometry (not an engine screenshot)',font=font_sm,fill=muted)
# map x[-26,26],z[-22,22] to box
xmin,xmax,zmin,zmax=-26,26,-22,22
left,top,ww,hh=88,258,745,580
X=lambda x:left+(x-xmin)/(xmax-xmin)*ww
Y=lambda z:top+(z-zmin)/(zmax-zmin)*hh
floor=Image.open(ROOT/'assets/textures/ashmarket_floor_075.png').convert('RGB').resize((int(ww),int(hh)))
floor.putalpha(110)
im.paste(floor,(left,top),floor)
d.rectangle((left,top,left+ww,top+hh),outline=(208,176,128),width=3)
code=(ROOT/'scripts/ashmarket_builder.gd').read_text()
rx=re.compile(r'solid_box\("([^\"]+)"\s*,\s*Vector3\(([-\d.]+),\s*([-\d.]+),\s*([-\d.]+)\)\s*,\s*Vector3\(([-\d.]+),\s*([-\d.]+),\s*([-\d.]+)\)')
for title,x,y,z,w,h,depth in rx.findall(code):
 x,y,z,w,h,depth=map(float,(x,y,z,w,h,depth))
 if y+h/2<.5 or y-h/2>1.4 or 'floor' in title.lower(): continue
 border=(55,67,65) if any(k in title.lower() for k in ['partition','wall']) else (113,90,70)
 d.rectangle((X(x-w/2),Y(z-depth/2),X(x+w/2),Y(z+depth/2)),fill=border,outline=(207,167,97),width=1)
points=[('START',-21,9,(226,231,210)),('CONTRACTS',-20,-12,amber),('BUYERS',-20,6,amber),('COALITION',-18,14,amber),('WATER',-6,-17,(97,163,173)),('COUNTING',18,-8,red),('COLLECTOR',14,4,red),('TRADE WRIT',20,14,(124,185,145)),('RAIL',-22,19,(160,193,165))]
for label,x,z,color in points:
 px,py=X(x),Y(z)
 d.ellipse((px-6,py-6,px+6,py+6),fill=color,outline=(15,21,19),width=2)
 d.text((px+9,py-12),label,font=font_sm,fill=color,stroke_width=2,stroke_fill=(13,19,18))
# right panel
right=(910,150,1698,926)
d.rounded_rectangle(right,radius=8,fill=(31,38,36),outline=amber,width=3)
d.text((938,171),'ORIGINAL NEW MATERIALS',font=font_med,fill=cream)
textures=['ashmarket_floor_075','ashmarket_ledger_wall_075','ashmarket_awning_075']
for i,name in enumerate(textures):
 x=944+i*237;y=218
 pic=Image.open(ROOT/'assets/textures'/f'{name}.png').convert('RGB').resize((210,180),Image.Resampling.NEAREST)
 im.paste(pic,(x,y))
 d.rectangle((x,y,x+210,y+180),outline=(196,151,91),width=2)
 d.text((x,y+187),name.replace('ashmarket_','').replace('_075',''),font=font_sm,fill=muted)
d.text((938,460),'COLLECTOR / EIGHT ANGLE PROXY',font=font_med,fill=cream)
for i in range(8):
 face=i+1;src=Image.open(ROOT/f'assets/sprites/enemies_075/collector_{face}.png').convert('RGBA')
 cell=src.crop((0,0,192,256));cell.thumbnail((151,180),Image.Resampling.NEAREST)
 x=943+(i%4)*188;y=515+(i//4)*191
 im.paste(cell,(x,y),cell)
 d.text((x+13,y+150),f'VIEW {face}',font=font_sm,fill=cream)
d.text((938,905),'All imagery drawn from the downloadable build assets.',font=font_sm,fill=muted)
im.save(out)
print(out)
