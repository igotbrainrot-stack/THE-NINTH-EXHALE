from PIL import Image,ImageDraw
from pathlib import Path
import math,random
p=Path(__file__).resolve().parents[1]/'assets/fx'
p.mkdir(exist_ok=True)
random.seed(79)
strip=Image.new('RGBA',(512,128),(0,0,0,0))
for j in range(4):
 tile=Image.new('RGBA',(128,128),(0,0,0,0)); d=ImageDraw.Draw(tile,'RGBA')
 cx,cy=64,64
 extent=[56,43,30,17][j]
 for i in range(16):
  theta=i*math.tau/16
  outer=extent*(0.78 if i%3 else 1.0)
  inner=7 if j<2 else 3
  x1=cx+math.cos(theta)*inner; y1=cy+math.sin(theta)*inner
  x2=cx+math.cos(theta)*outer; y2=cy+math.sin(theta)*outer
  d.line([(round(x1),round(y1)),(round(x2),round(y2))],fill=(255,179,65,205 if j<2 else 140),width=max(1,5-j))
 d.ellipse((cx-14+j*2,cy-14+j*2,cx+14-j*2,cy+14-j*2),fill=(255,228,143,255 if j==0 else 190))
 d.ellipse((cx-6,cy-6,cx+6,cy+6),fill=(255,255,219,255))
 strip.alpha_composite(tile,(j*128,0))
strip.save(p/'civic_muzzle_burst_079x.png',optimize=True)
print(p/'civic_muzzle_burst_079x.png',(p/'civic_muzzle_burst_079x.png').stat().st_size)
