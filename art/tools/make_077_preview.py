#!/usr/bin/env python3
"""Authoring schematic and exact runtime assets; not a Godot screenshot."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).resolve().parents[2]
OUT=R/'art/previews/BUILD_077_GROWTH_DEFENCE_PREVIEW.png'
OUT.parent.mkdir(exist_ok=True,parents=True)
im=Image.new('RGB',(1580,920),(18,22,22));d=ImageDraw.Draw(im)
try:
    face=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',19)
    small=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',13)
    bold=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',30)
except Exception:
    face=small=bold=None
d.text((30,20),'THE NINTH EXHALE / BUILD 07.7',font=bold,fill=(231,222,188))
d.text((30,60),'Actual new district textures, interim directional sprite samples & authored route schematics — NOT engine screenshots',font=small,fill=(173,184,165))
scenes=[('GLASS ORCHARD / GROWTH',(30,100),(65,105,81),[('Fruit sample',(-20,-15)),('Venn',(-20,0)),('Researchers',(-20,11)),('Growth register',(20,15)),('Root Seed',(21,-16)),('Rail',(-23,20))]),('QUIET BARRACKS / DEFENCE',(805,100),(92,92,78),[('Casualty roll',(-21,-15)),('Kest',(-20,0)),('Guard roster',(-21,7)),('Defence register',(20,16)),('Heat Survey',(21,-18)),('Rail',(-23,20))])]
for title,(xx,yy),fill,pts in scenes:
    d.rounded_rectangle((xx,yy,xx+730,yy+460),radius=8,fill=(28,33,31),outline=(137,117,74),width=2)
    d.text((xx+20,yy+14),title,font=face,fill=(224,213,181))
    sx=xx+48;sy=yy+65;W=620;H=335
    d.rectangle((sx,sy,sx+W,sy+H),fill=fill,outline=(197,198,174),width=4)
    def P(x,z): return (int(sx+(x+30)/60*W),int(sy+(z+24)/48*H))
    for z1,z2 in [(-23,-4.5),(4.5,23)]:
        x0,z0=P(0,z1);_,z3=P(0,z2)
        d.line((x0,z0,x0,z3),fill=(26,37,32),width=8)
    # central passage
    c1=P(-25,0);c2=P(25,0)
    d.line((c1[0],c1[1],c2[0],c2[1]),fill=(211,198,129),width=3)
    for idx,(name,(x,z)) in enumerate(pts):
        px,py=P(x,z);col=(225,174,85) if 'Writ' in name or 'register' in name else (174,227,190)
        d.ellipse((px-6,py-6,px+6,py+6),fill=col,outline=(19,19,19),width=2)
        ox=px+8 if x<0 else px-145
        oy=py-14 if idx%2==0 else py+8
        d.text((ox,oy),name,font=small,fill=(244,239,220))
    px,py=P(-22,8);d.ellipse((px-7,py-7,px+7,py+7),fill=(223,94,64));d.text((px+12,py+5),'SPAWN',font=small,fill=(243,222,199))
    d.text((xx+19,yy+418),'Walking passage and source-evidence terminals | schematic only',font=small,fill=(173,184,165))
# actual texture swatches and sprites
names=['orchard_glass_077.png','orchard_floor_077.png','barracks_wall_077.png','barracks_floor_077.png']
for j,name in enumerate(names):
    src=Image.open(R/'assets/textures'/name).convert('RGB').resize((185,185),Image.Resampling.NEAREST)
    x=30+j*196;y=622
    im.paste(src,(x,y))
    d.text((x,y+189),name.replace('_077.png',''),font=small,fill=(217,209,180))
for j,name in enumerate(['venn_1.png','kest_1.png']):
    src=Image.open(R/'assets/sprites/directional8'/name).convert('RGBA').resize((153,224),Image.Resampling.NEAREST)
    bg=Image.new('RGBA',(162,228),(38,43,42,255))
    bg.alpha_composite(src,(4,0));x=820+j*180;y=620
    im.paste(bg.convert('RGB'),(x,y));d.text((x+20,y+231),name.replace('_1.png',' / view 1'),font=small,fill=(211,211,188))
d.text((30,872),'SOURCE-VERIFIED ARTWORK • QUORUM: ANY THREE OF FIVE WRITS • TRUE DAWN CLUES: ROOT SEED + HEAT SURVEY',font=face,fill=(218,198,155))
im.save(OUT)
print(OUT)
