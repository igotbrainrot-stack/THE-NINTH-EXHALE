from PIL import Image,ImageDraw,ImageFont,ImageFilter
from pathlib import Path
import json,random,math
ROOT=Path('/mnt/data/THE_NINTH_EXHALE_HUD_091_COMPLETE')
S=ROOT/'assets/ui/hud_091';D=ROOT/'docs/handover'
margins=json.loads((S/'hud_091_slices.json').read_text())
C={'black':'#171918','cream':'#E6DCC5','paper':'#E1D1A6','brass':'#D6AC6A','teal':'#6E9780','vermilion':'#A94D3B'}
fontpath='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
F={s:ImageFont.truetype(fontpath,s) for s in [8,9,10,11,12,13,17]}

def nine(img,w,h,m):
 l,t,r,b=m;src=img.convert('RGBA');sw,sh=src.size
 xs=[0,l,sw-r,sw];ys=[0,t,sh-b,sh]
 dx=[0,l,w-r,w];dy=[0,t,h-b,h]
 out=Image.new('RGBA',(w,h),(0,0,0,0))
 for row in range(3):
  for col in range(3):
   block=src.crop((xs[col],ys[row],xs[col+1],ys[row+1]))
   x0,y0,x1,y1=dx[col],dy[row],dx[col+1],dy[row+1]
   if x1<=x0 or y1<=y0:continue
   block=block.resize((x1-x0,y1-y0),Image.Resampling.NEAREST)
   out.alpha_composite(block,(x0,y0))
 return out

def art(name,w=None,h=None):
 img=Image.open(S/f'{name}.png').convert('RGBA')
 if w and h:
  return nine(img,w,h,margins[name]) if name in margins else img.resize((w,h),Image.Resampling.NEAREST)
 return img

def base():
 im=Image.new('RGB',(640,400),'#1c2624');d=ImageDraw.Draw(im)
 d.polygon([(0,100),(285,210),(285,330),(0,400)],fill='#282e2b')
 d.polygon([(640,90),(355,204),(355,330),(640,400)],fill='#232a27')
 d.polygon([(0,400),(240,255),(400,255),(640,400)],fill='#313530')
 d.polygon([(0,0),(640,0),(420,160),(220,160)],fill='#303630')
 for i in range(9):
  x=i*74
  d.line((x,0,320+(x-320)//3,175),fill='#1a201d',width=4)
 for y in [25,56,94,144]:d.line((0,y,640,y),fill='#222a27',width=2)
 for y in [260,285,315,350,385]:d.line((0,y,640,y),fill='#222723',width=2)
 for i in range(4):
  x=55+i*140
  d.rectangle((x,176,x+24,290),fill='#333933',outline='#4a4235',width=2)
  d.rectangle((x+8,206,x+20,245),fill='#161f1e')
 # blur the backdrop very slightly so HUD artwork remains crisp
 return im.filter(ImageFilter.GaussianBlur(.5)).convert('RGBA')

def paste(canvas,name,xy,size=None):
 im=art(name,*size) if size else art(name)
 canvas.alpha_composite(im,xy)

def label(canvas,xy,text,color='#E6DCC5',size=10):
 d=ImageDraw.Draw(canvas);d.text(xy,text,font=F[size],fill=color,stroke_width=0)

def demo_play():
 im=base();paste(im,'hud_frame_brass',(8,6),(300,60))
 paste(im,'hud_frame_route',(386,6),(248,28))
 label(im,(25,16),'HEARTH NINE',C['brass'],10)
 label(im,(25,32),'Complete the Rootkin hearing;',C['cream'],10)
 label(im,(25,45),'then obtain three distinct Writs.',C['cream'],10)
 label(im,(452,16),'↑  REPRINT RELAY · 4m',C['cream'],11)
 for i,(txt,col) in enumerate([('ENFORCER DOWN / RECORDED','#171918'),('EVIDENCE FILED / DOCKET','#171918'),('SERVICE RAIL / ACTIVE','#171918')]):
  y=41+i*26;paste(im,'hud_slip',(406,y),(224,24));label(im,(420,y+6),txt,col,9)
 paste(im,'hud_stamp_frame',(170,142),(300,74))
 label(im,(224,164),'LUNG INSTALLED',C['vermilion'],17)
 label(im,(225,189),'THE COST IS IN THE LEDGER',C['cream'],9)
 paste(im,'hud_reticle',(304,184))
 paste(im,'hud_prompt_tab',(186,239),(268,26))
 paste(im,'hud_keycap',(195,244),(17,16))
 label(im,(202,246),'E',C['black'],10)
 label(im,(247,247),'SPEAK TO BRIN HARKER',C['cream'],11)
 paste(im,'hud_frame_steel',(8,340),(204,54))
 paste(im,'hud_frame_brass',(428,340),(204,54))
 paste(im,'hud_bar_track',(33,353),(108,9));paste(im,'hud_bar_track',(33,369),(108,9))
 paste(im,'hud_bar_fill_health',(38,355),(95,5));paste(im,'hud_bar_fill_breath',(38,371),(95,5))
 paste(im,'icon_health',(14,351),(16,16));paste(im,'icon_breath',(14,367),(16,16))
 label(im,(151,353),'103/103',C['cream'],9)
 label(im,(151,370),'104/104',C['cream'],9)
 label(im,(24,383),'LV 1 · 0 XP',C['brass'],9)
 paste(im,'icon_ammo',(437,350),(22,22))
 label(im,(465,353),'COVENANT PISTOL',C['cream'],10)
 label(im,(464,371),'6 / 36',C['paper'],13)
 # native-game overlay key controls: separate flat text
 label(im,(230,364),'TAB dossier · F intervene',C['cream'],9)
 label(im,(244,378),'SHIFT sprint · R reload',C['cream'],9)
 return im.convert('RGB')

def demo_modal():
 im=demo_play().convert('RGBA');d=ImageDraw.Draw(im)
 d.rectangle((0,0,640,400),fill=(0,0,0,135))
 paste(im,'hud_docket_modal',(42,26),(556,328))
 label(im,(133,43),'CIVIC PRESSURE DOCKET',C['cream'],17)
 for i,(txt,name) in enumerate([('GOALS','hud_tab_active'),('THE NINTH','hud_tab_idle'),('RECORDS','hud_tab_idle'),('ENDGAME','hud_tab_idle')]):
  x=87+i*112;paste(im,name,(x,71),(102,19));label(im,(x+14,76),txt,C['black'] if i==0 else C['cream'],10)
 label(im,(82,111),'WITNESS / ATTEMPT 00001',C['paper'],10)
 label(im,(81,137),'KNOWN FINAL PREREQUISITES',C['paper'],12)
 label(im,(81,163),'TODO   Three unique Writs from different offices (1/3)',C['cream'],10)
 label(im,(81,182),'TODO   Public Echoform hearing passed',C['cream'],10)
 label(im,(81,204),'TRUE DAWN ALSO NEEDS:',C['teal'],10)
 for i,(slot,txt) in enumerate([('hud_button_hover','CLOSE DOCKET / RETURN TO WORLD'),('hud_button_normal','COMMIT SAVE AT THIS POSITION'),('hud_button_normal','SPEND ATTRIBUTE POINT / +1 FORCE')]):
  y=232+i*35;paste(im,slot,(70,y),(500,31));paste(im,'hud_keycap',(83,y+7),(17,16))
  label(im,(88,y+10),str(i+1),C['black'],9)
  label(im,(185,y+10),txt,C['black'],10)
 return im.convert('RGB')

demo_play().save(D/'HUD_091_640x400_LAYOUT_MOCK_PLAY.png')
demo_modal().save(D/'HUD_091_640x400_LAYOUT_MOCK_DOCKET.png')
print('Created 640x400 illustration-only HUD preflights')
