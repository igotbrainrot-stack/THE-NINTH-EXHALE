#!/usr/bin/env python3
"""Original pressure-control floor glyph, generated without external artwork."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random
SIZE=512
im=Image.new('RGBA',(SIZE,SIZE),(0,0,0,0))
d=ImageDraw.Draw(im,'RGBA')
center=SIZE/2
for radius,width,alpha in [(237,9,170),(209,3,140),(164,5,118),(126,3,104),(63,5,118)]:
    d.arc((center-radius,center-radius,center+radius,center+radius),0,360,fill=(220,159,82,alpha),width=width)
for idx in range(32):
    angle=(idx/32.0)*2*math.pi
    r1,r2=219,239
    x1,y1=center+math.cos(angle)*r1, center+math.sin(angle)*r1
    x2,y2=center+math.cos(angle)*r2, center+math.sin(angle)*r2
    d.line((x1,y1,x2,y2),fill=(230,176,100,160),width=4 if idx%4==0 else 2)
for idx in range(8):
    angle=2*math.pi*idx/8+math.pi/8
    x1=center+math.cos(angle)*140
    y1=center+math.sin(angle)*140
    x2=center+math.cos(angle)*185
    y2=center+math.sin(angle)*185
    d.line((x1,y1,x2,y2),fill=(153,103,59,105),width=5)
# Four opposed pressure-channel vent traces, not letters or borrowed insignia.
for quadrant in range(4):
    angle=quadrant*math.pi/2
    ux,uy=math.cos(angle),math.sin(angle)
    for dist in [24,42,60,78,96]:
        x,y=center+ux*dist,center+uy*dist
        d.ellipse((x-4,y-4,x+4,y+4),fill=(193,132,78,105))
output=Path(__file__).resolve().parents[2]/'assets/textures/pressure_docket_079.png'
im.save(output)
print(output)
