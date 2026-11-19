from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[2]
OUTPUT=ROOT/'art/previews/BUILD_071_EIGHT_ANGLE_REAL_ASSETS.png'
OUTPUT.parent.mkdir(parents=True,exist_ok=True)
img=Image.new('RGB',(1700,1080),(19,26,26));draw=ImageDraw.Draw(img)
try:
  big=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',32)
  med=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',20)
  small=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',16)
except OSError:big=med=small=None
cream=(235,221,192); muted=(165,181,170); gold=(188,146,80)
draw.text((38,20),'THE NINTH EXHALE  /  BUILD 07.1',font=big,fill=cream)
draw.text((38,68),'EXPORTED IN-GAME ASSETS  •  1–8 DIRECTION SLOTS  •  0 = UNIVERSAL GRAPHIC',font=med,fill=gold)
angle_names=['1 FRONT','2 FRONT-L','3 LEFT','4 REAR-L','5 BACK','6 REAR-R','7 RIGHT','8 FRONT-R']
colw=202;startx=45
for j,t in enumerate(angle_names):
 x=startx+j*colw
 draw.rounded_rectangle((x,105,x+185,138),radius=6,fill=(54,60,54),outline=gold,width=2)
 draw.text((x+10,112),t,font=small,fill=cream)
def row(label,source,asset,y,height):
 draw.text((45,y-29),label,font=med,fill=cream)
 for d in range(1,9):
  if source=='npc':p=ROOT/'assets/sprites/directional8'/f'{asset}_{d}.png';sp=Image.open(p).convert('RGBA')
  else:
   p=ROOT/'assets/sprites/enemies_071'/f'{asset}_{d}.png';sp=Image.open(p).convert('RGBA').crop((0,0,192,256))
  width=round(sp.width*height/sp.height)
  sp=sp.resize((width,height),Image.Resampling.LANCZOS)
  x=startx+(d-1)*colw
  tile=Image.new('RGBA',(185,height+20),(34,43,40,255))
  tile.alpha_composite(sp,((185-width)//2,13))
  img.paste(tile.convert('RGB'),(x,y))
  draw.rectangle((x,y,x+185,y+height+20),outline=(75,91,81),width=1)
row('BRIN HARKER — NEW EIGHT-VIEW ORIGINAL ART', 'npc','brin',185,220)
row('DR SELA — ORIGINAL CARDINALS + OPTICAL-FLOW-WARPED DIAGONALS', 'npc','sela',470,220)
row('FILTER CRAWLER — 12 ANIMATION POSES PER DIRECTION','enemy','sentry',750,200)
draw.text((38,1000),'BRIN: individually generated views. Other new diagonal cells: provisional warps, not hand-drawn perspective art.',font=small,fill=muted)
draw.text((38,1030),'STATIC OBJECTS remain full 3D meshes; 0 is an optional universal sprite, not a ninth angle.',font=small,fill=muted)
img.save(OUTPUT,optimize=True)
print(OUTPUT)
