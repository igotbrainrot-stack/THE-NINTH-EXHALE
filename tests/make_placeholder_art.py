"""Generate ORIGINAL, deliberately simple pixel-art engineering placeholders; no franchise art."""
from PIL import Image, ImageDraw
from pathlib import Path
import random
ROOT=Path(__file__).resolve().parents[1]
tex=ROOT/'assets/textures'; spr=ROOT/'assets/sprites';tex.mkdir(parents=True,exist_ok=True);spr.mkdir(parents=True,exist_ok=True)
PALETTE={'ink':'#171918','iron':'#424A48','grey':'#68706C','chalk':'#C8C7AE','paper':'#E1D1A6','copper':'#6F4A36','amber':'#C28A43','green':'#86956A','rust':'#A94D3B','purple':'#716076','blue':'#718D9A'}

def texture(name,base,lines,seed):
 rng=random.Random(seed); im=Image.new('RGB',(64,64),base);d=ImageDraw.Draw(im)
 for y in range(0,64,4):
  for x in range(0,64,4):
   if rng.random()<0.26:d.rectangle((x,y,x+3,y+3),fill=rng.choice(lines))
 d.line((0,0,63,0),fill=lines[0],width=2);d.line((0,0,0,63),fill=lines[0],width=1)
 for i in range(10):
  x,y=rng.randrange(0,64),rng.randrange(0,64)
  d.point((x,y),fill=PALETTE['chalk'] if i%3==0 else lines[-1])
 im.save(tex/(name+'.png'))
texture('ward_linen','#828d82',['#75847d','#899489','#687b72'],8)
texture('floor_grid','#535b56',['#47524d','#59635d','#454d49'],9)
texture('requisition_steel','#485353',['#414949','#5d6864','#6a7770'],10)
texture('corroded_paper','#bbaa80',['#afa078','#c5b78e','#aa926b'],11)
texture('furnace_iron','#48413c',['#3b3936','#56483b','#6c5142'],12)

def actor(filename,coat,skin,details,step=0):
 im=Image.new('RGBA',(96,128),(0,0,0,0));d=ImageDraw.Draw(im)
 # shadow and shoes (ground baseline kept identical between every frame)
 d.ellipse((21,115,78,123),fill=(5,10,10,110))
 d.rectangle((31,102,46,115),fill=details); d.rectangle((52,102,67,115),fill=details)
 d.rectangle((28+step,111,47+step,120),fill=PALETTE['ink'])
 d.rectangle((50-step,111,71-step,120),fill=PALETTE['ink'])
 # torso / shoulders / coat
 d.polygon([(29,48),(63,48),(77,62),(71,109),(23,109),(18,62)],fill=coat)
 d.rectangle((42,52,51,108),fill=details)
 d.rectangle((20,60,29,96),fill=coat);d.rectangle((67,60,76,96),fill=coat)
 d.rectangle((19,89,29,100),fill=skin);d.rectangle((67,89,77,100),fill=skin)
 # head / hair / face asym
 d.rectangle((34,19,62,52),fill=skin)
 d.polygon([(32,26),(35,10),(61,14),(66,28),(57,23),(38,24)],fill=details)
 d.rectangle((39,34,43,37),fill=PALETTE['ink']);d.rectangle((55,34,59,37),fill=PALETTE['ink'])
 d.line((43,46,55,46),fill=PALETTE['copper'],width=2)
 # civic insignia and zipper tabs
 d.rectangle((31,58,38,65),fill=PALETTE['chalk'])
 d.rectangle((31,58,39,61),fill=PALETTE['copper'])
 d.line((36,73,39,73),fill=PALETTE['amber'],width=2)
 im.save(spr/filename)
actor('sela.png',PALETTE['paper'],'#ad806d',PALETTE['blue'])
actor('oren.png','#59625b','#9c7963','#2c3a3c')
actor('clerk.png','#615d55','#ac8870',PALETTE['purple'])
for k,step in enumerate([0,4,0,-4]):
 actor(f'enforcer_{k}.png','#5d6151','#9d8370','#343c3b',step)
# pistol shape intentionally a rectilinear ledger instrument, away from centre of screen.
im=Image.new('RGBA',(256,144),(0,0,0,0));d=ImageDraw.Draw(im)
d.polygon([(80,88),(224,70),(238,81),(233,103),(95,112)],fill='#1e2928')
d.polygon([(89,81),(225,63),(241,72),(225,88),(90,103)],fill='#434f4e')
d.rectangle((99,83,176,92),fill='#68706C')
d.polygon([(116,98),(156,96),(145,142),(105,142)],fill='#6f5946')
d.rectangle((130,104,141,136),fill='#343a38')
# signature counter mounted BEFORE grip (not revolver cylinder)
d.rectangle((170,78,201,101),fill='#c8c7ae');d.rectangle((178,82,195,93),fill='#1c2625')
for i in range(4):d.rectangle((180+i*4,85,182+i*4,90),fill='#c28a43' if i==1 else '#68706C')
d.polygon([(89,86),(102,84),(100,99),(88,101)],fill='#e1d1a6')
d.line((96,110,225,94),fill='#1d2221',width=3)
im.save(spr/'covenant_pistol.png')
# original reticle / crosshair intentionally docket-square instead of genre cross
im=Image.new('RGBA',(24,24));d=ImageDraw.Draw(im);d.rectangle((7,7,16,16),outline='#e1d1a6',width=2);d.point((11,11),fill='#a94d3b');im.save(spr/'reticle.png')
print('generated',len(list(tex.glob('*.png'))),'textures,',len(list(spr.glob('*.png'))),'sprite PNGs')
