"""Paint original Covenant Pistol 2D placeholder into a more readable equipment sprite.
Source drawings are original and obey Master Bible §11; no borrowed game sprite.
"""
from PIL import Image,ImageDraw
from pathlib import Path
p=Path(__file__).resolve().parents[2]/'assets/sprites/covenant_pistol.png'
im=Image.new('RGBA',(256,144),(0,0,0,0));d=ImageDraw.Draw(im)
outline=(16,23,23,255); dark=(32,43,43,255); iron=(60,73,73,255); cold=(85,105,103,255);mid=(118,137,131,255); white=(207,200,172,255); brass=(135,106,65,255); copper=(114,71,52,255);shade=(24,31,30,255)
# Low, offset, functional muzzle and an angular witness-counter service firearm.
d.polygon([(42,70),(221,49),(243,63),(232,91),(92,110),(43,97)],fill=outline)
d.polygon([(49,75),(215,57),(236,65),(226,85),(93,101),(46,92)],fill=dark)
d.polygon([(61,67),(201,49),(225,53),(218,66),(75,86)],fill=iron)
d.line([(65,67),(198,52),(222,55)],fill=mid,width=3)
d.polygon([(219,53),(242,64),(230,80),(215,69)],fill=shade)
d.polygon([(223,55),(240,65),(230,70),(218,65)],fill=cold)
# Muzzle shroud (a rectangular maintenance piece rather than a gun barrel cylinder).
d.polygon([(40,72),(66,68),(78,88),(70,100),(38,96)],fill=shade)
d.polygon([(42,76),(66,75),(71,84),(47,86)],fill=white)
d.rectangle((36,82,44,91),fill=mid)
d.line((44,92,65,91),fill=brass,width=2)
# Upper side venting with low 8-bit cluster pattern.
for i in range(6):
    x=109+i*15
    d.line((x,72-int(i*0.9),x+7,71-int(i*0.9)),fill=shade,width=3)
    d.line((x,68-int(i*0.9),x+6,67-int(i*0.9)),fill=mid,width=1)
# Service counter must be in front of the grip, not a rotary chamber.
d.polygon([(158,74),(193,69),(196,92),(158,98)],fill=outline)
d.polygon([(163,77),(189,73),(191,89),(162,93)],fill=white)
d.polygon([(166,81),(186,78),(187,87),(167,90)],fill=iron)
for x in (169,175,182):
    d.rectangle((x,81,x+2,86),fill=brass)
d.line((160,96,195,90),fill=copper,width=2)
# Firearm's machinery-driven articulated housing, square and non-generic.
d.polygon([(80,93),(216,77),(226,91),(201,106),(100,120),(79,112)],fill=iron)
d.polygon([(92,101),(198,88),(216,89),(197,101),(106,113)],fill=cold)
d.line((95,105,207,90),fill=mid,width=2)
d.line((103,116,199,101),fill=shade,width=3)
d.polygon([(104,118),(117,115),(129,119),(130,132),(116,134),(110,126)],fill=outline)
# Grip and gloved hand bottom edge anchored to the weapon.
d.polygon([(125,105),(156,101),(171,133),(161,144),(122,144),(112,127)],fill=outline)
d.polygon([(129,111),(152,108),(164,133),(156,142),(126,142),(118,126)],fill=(87,73,57,255))
for y in range(116,138,5):
    d.line((125+(y-115)//4,y,157,y-1),fill=(61,54,46,255),width=2)
# Safety and tactile switch.
d.rectangle((89,100,102,106),fill=white)
d.rectangle((92,99,98,102),fill=brass)
d.rectangle((176,104,190,109),fill=outline)
d.line((177,106,186,106),fill=brass,width=2)
# Small surface wear, mechanical screwheads and service stamps.
for x,y in [(81,87),(139,93),(203,79)]:
    d.ellipse((x-2,y-2,x+2,y+2),fill=shade)
    d.line((x-1,y,x+1,y),fill=white)
for x,y in [(106,93),(117,90),(127,89),(207,83)]:
    d.line((x,y,x+4,y-1),fill=(153,154,128,255),width=1)
# No character HUD clone, brand marks or centred hand pose.
im.save(p,optimize=True)
print('Painted',p,im.size)
