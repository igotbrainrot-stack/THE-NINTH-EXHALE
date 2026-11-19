from PIL import Image,ImageDraw,ImageFont
from pathlib import Path
import json,subprocess,tempfile
ROOT=Path(__file__).resolve().parents[2]
info=json.loads((ROOT/'data/enemy_roster_068.json').read_text())
keys=[v['id'] for v in info['combat_enemies']]+['bell_wretch','rootkin']
spec={v['id']:v for v in info['combat_enemies']}
preview=ROOT/'art/previews'
preview.mkdir(exist_ok=True)
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',15)
label_font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',12)
seq=[0,1,2,3,0,1,2,3,4,5,6,7,0,8,0,1,2,3,0,0]
with tempfile.TemporaryDirectory() as td:
 frames=[]
 for step,index in enumerate(seq):
  frame=Image.new('RGB',(1100,912),(23,25,30));d=ImageDraw.Draw(frame)
  d.text((28,12),'THE NINTH EXHALE / 06.8 — ENEMY ANIMATION TEST',font=font,fill=(241,221,178))
  d.text((28,35),'Embedded interim sprites • original Runway turnaround renders stored separately in Runway',font=label_font,fill=(180,188,184))
  for i,key in enumerate(keys):
   cx=i%5;cy=i//5;x=20+cx*217;y=75+cy*206
   box=(x+4,y+4,x+202,y+163)
   d.rounded_rectangle(box,radius=8,fill=(39,44,48),outline=(67,73,75),width=2)
   path=ROOT/'assets/sprites/enemies_068'/f'{key}_front.png'
   with Image.open(path) as source:
    sub=source.crop(((index%4)*192,(index//4)*256,((index%4)+1)*192,((index//4)+1)*256))
    sub.thumbnail((160,149),Image.Resampling.NEAREST)
    frame.paste(sub,(x+108-sub.width//2,y+155-sub.height),sub)
   title=spec[key]['name'] if key in spec else key.replace('_',' ').title()
   d.text((x+8,y+170),title,fill=(235,225,212),font=label_font)
   caption=spec[key]['zone'].upper() if key in spec else 'CIVIC HEARING'
   d.text((x+8,y+186),caption,fill=(139,171,155),font=label_font)
  frames.append(frame)
  frame.save(Path(td)/f'{step:03d}.png')
 out=preview/'BUILD_068_ENEMY_ANIMATION_PREVIEW.mp4'
 result=subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-framerate','7','-i',str(Path(td)/'%03d.png'),'-c:v','libx264','-pix_fmt','yuv420p','-crf','20','-movflags','+faststart',str(out)],capture_output=True,text=True)
 if result.returncode:raise RuntimeError(result.stderr)
 frames[0].save(preview/'BUILD_068_ENEMY_ANIMATION_CONTACT.png')
 print('Motion preview',out.stat().st_size,'bytes')
