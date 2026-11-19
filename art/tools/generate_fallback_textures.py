"""Original, deterministic backup tileable textures for Vesper.
Runway source images are art references; these hand-built atlas materials are the
engine-safe baseline. No commercial game assets or sampled third-party textures.
"""
from PIL import Image, ImageDraw
from pathlib import Path
import random
ROOT=Path(__file__).resolve().parents[2] / 'assets' / 'textures'
ROOT.mkdir(parents=True,exist_ok=True)
SIZE=256

def clamp(v):return max(0,min(255,int(v)))
def col(v,n=0):return tuple(clamp(x+n) for x in v)
def blend(v,w,t):return tuple(clamp(v[i]*(1-t)+w[i]*t) for i in range(3))
def save(name,im):
    im.save(ROOT/name,optimize=True)
    print(name,im.size)

def panels(seed,base,frame,hilite,deep,industrial=False):
    r=random.Random(seed); im=Image.new('RGB',(SIZE,SIZE),base);d=ImageDraw.Draw(im)
    # Fine irregular patina, original pixel stipple, always within panel faces.
    for y in range(0,SIZE,4):
        for x in range(0,SIZE,4):
            q=r.randint(-9,9)
            d.rectangle([x,y,x+3,y+3],fill=col(base,q))
    # Four repeatable envelope panels with gasket gaps.
    for j in range(2):
        for i in range(2):
            x=i*128; y=j*128
            d.rectangle([x,y,x+127,y+127],outline=deep,width=5)
            d.line((x+6,y+5,x+122,y+5),fill=hilite,width=3)
            d.line((x+6,y+6,x+6,y+123),fill=hilite,width=2)
            d.line((x+121,y+6,x+121,y+121),fill=frame,width=3)
            d.line((x+7,y+121,x+121,y+121),fill=frame,width=3)
            for sx,sy in [(x+12,y+12),(x+116,y+12),(x+12,y+116),(x+116,y+116)]:
                d.ellipse((sx-3,sy-3,sx+3,sy+3),fill=deep)
                d.line((sx-1,sy,sx+1,sy),fill=hilite)
            # Perforated readable nameplate / inspection slip
            d.rectangle((x+23,y+17,x+100,y+30),fill=frame)
            d.rectangle((x+26,y+20,x+78,y+25),fill=hilite)
            d.rectangle((x+83,y+20,x+96,y+25),fill=deep)
            # Two heat/cooling vent lattices on right side
            if industrial:
                d.rectangle((x+35,y+45,x+93,y+92),fill=deep)
                for ly in range(y+49,y+89,8):
                    d.rectangle((x+40,ly,x+89,ly+3),fill=frame)
                    d.line((x+40,ly,x+89,ly),fill=hilite)
            else:
                for ly in range(y+44,y+96,10):
                    d.line((x+34,ly,x+92,ly),fill=frame,width=2)
                    d.line((x+38,ly+2,x+89,ly+2),fill=hilite,width=1)
            for k in range(16):
                px=x+r.randint(11,115);py=y+r.randint(34,112)
                d.line((px,py,px+r.randint(1,7),py+r.randint(0,3)),fill=blend(base,frame,r.uniform(.2,.45)),width=1)
    return im

def floor():
    r=random.Random(805); bg=(73,78,72); im=Image.new('RGB',(SIZE,SIZE),bg);d=ImageDraw.Draw(im)
    for y in range(0,SIZE,4):
        for x in range(0,SIZE,4):d.rectangle((x,y,x+3,y+3),fill=col(bg,r.randint(-6,6)))
    for p in range(0,256,64):
        d.rectangle((p,0,p+5,255),fill=(37,45,43))
        d.rectangle((0,p,255,p+5),fill=(37,45,43))
        d.line((p+7,6,p+7,255),fill=(116,119,103),width=2)
        d.line((6,p+7,255,p+7),fill=(116,119,103),width=2)
    for y in range(0,256,64):
        for x in range(0,256,64):
            for dx,dy in [(13,13),(53,13),(13,53),(53,53)]:
                d.ellipse((x+dx-2,y+dy-2,x+dx+2,y+dy+2),fill=(40,45,43))
                d.line((x+dx-1,y+dy,x+dx+1,y+dy),fill=(132,130,113))
            for _ in range(6):
                q=x+r.randint(14,50); v=y+r.randint(14,50)
                d.line((q,v,q+r.randint(3,9),v),fill=(102,102,88),width=1)
    return im

def linen():
    r=random.Random(23);bg=(175,181,167);im=Image.new('RGB',(SIZE,SIZE),bg);d=ImageDraw.Draw(im)
    for y in range(0,256,3):
        d.line((0,y,255,y),fill=col(bg,-7 if y%2 else 4),width=1)
    for x in range(0,256,4): d.line((x,0,x,255),fill=col(bg,5),width=1)
    for _ in range(100):
        x=r.randrange(256); y=r.randrange(256)
        d.line((x,y,x+r.randint(1,8),y),fill=col(bg,r.randint(-19,-7)),width=1)
    for y in range(0,256,128):
        d.line((0,y,255,y),fill=(81,92,90),width=3)
        d.line((0,y+6,255,y+6),fill=(224,217,184),width=2)
        for x in range(14,256,25):
            d.ellipse((x-2,y+2,x+2,y+6),fill=(93,94,87))
    return im

def paper():
    r=random.Random(65); bg=(213,196,154); im=Image.new('RGB',(SIZE,SIZE),bg);d=ImageDraw.Draw(im)
    for y in range(0,256,5):
        for x in range(0,256,5):d.rectangle((x,y,x+4,y+4),fill=col(bg,r.randint(-14,8)))
    for y in range(0,256,64):
        d.line((0,y,255,y),fill=(148,130,105),width=2)
        for k in range(4):
            dx=(k*64+21)%256
            d.line((dx,y+14,dx+29,y+14),fill=(77,81,73),width=2)
            d.line((dx,y+21,dx+37,y+21),fill=(108,107,86),width=1)
            d.line((dx,y+28,dx+23,y+28),fill=(108,107,86),width=1)
            d.rectangle((dx+33,y+33,dx+40,y+40),outline=(120,64,48),width=2)
    return im

def striped():
    im=Image.new('RGB',(256,256),(50,57,53));d=ImageDraw.Draw(im)
    for x in range(-256,512,32):
        d.polygon([(x,0),(x+16,0),(x+272,256),(x+256,256)],fill=(187,123,49))
    d.rectangle((0,0,255,255),outline=(43,43,38),width=10)
    return im

save('floor_grid.png',floor())
save('ward_linen.png',linen())
save('requisition_steel.png',panels(52,(98,110,109),(43,64,66),(171,185,170),(29,45,46),False))
save('furnace_iron.png',panels(79,(78,81,74),(99,67,54),(153,126,91),(31,35,35),True))
save('corroded_paper.png',paper())
save('ward_enamel_v2.png',panels(105,(150,167,166),(81,101,110),(214,212,183),(56,69,75),False))
save('furnace_facing_v2.png',panels(106,(88,83,70),(96,69,55),(158,132,91),(28,32,34),True))
save('hazard_ochre_v2.png',striped())
