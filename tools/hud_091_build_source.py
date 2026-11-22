#!/usr/bin/env python3
"""THE NINTH EXHALE HUD 09.1 art-builder: new independent Godot drop-in assets.
No gameplay code changes. Preserve byte-identical OpenAI generation downloads.
"""
from PIL import Image, ImageDraw, ImageFont, ImageEnhance
from pathlib import Path
from collections import OrderedDict
from hashlib import sha256
import json, shutil, math, random, zipfile
import numpy as np

ROOT=Path('/mnt/data/THE_NINTH_EXHALE_HUD_091_COMPLETE')
SOURCES=ROOT/'art/production_sources/hud_091'
OUT=ROOT/'assets/ui/hud_091'
DOC=ROOT/'docs/handover'
for p in [SOURCES,OUT,DOC]:p.mkdir(parents=True,exist_ok=True)
INPUT=Path('/mnt/data')
P={
 'black':'#171918','dark':'#2A312E','iron':'#424A48','grey':'#68706C','bone':'#C8C7AE','paper':'#E1D1A6',
 'cream':'#E6DCC5','shadow':'#6F4A36','brass':'#B38A4F','amber':'#C28A43','teal':'#407D7F','warning':'#A94D3B',
 'care':'#718D9A','health':'#B66C5A','breath':'#6E9780','heat':'#C88C4E','dark_bronze':'#8F6F3D',
 'deep':'#0F1514','bright':'#F0DBB6','cool':'#607166','pressed':'#4F4735'
}
BORDER_SLICES={
 'hud_frame_brass':[10,9,10,9],'hud_frame_steel':[10,9,10,9],'hud_frame_route':[8,5,8,5],
 'hud_prompt_tab':[12,6,12,6],'hud_docket_modal':[20,20,20,20],
 'hud_button_normal':[14,7,14,7],'hud_button_hover':[14,7,14,7],'hud_button_pressed':[14,7,14,7],
 'hud_slip':[6,4,6,4],'hud_stamp_frame':[12,8,12,8],'hud_keycap':[3,2,3,4],
 'hud_bar_track':[4,1,4,1],'hud_tab_active':[6,5,6,1],'hud_tab_idle':[6,5,6,1]
}
SIZES={
'hud_frame_brass':(96,48),'hud_frame_steel':(96,48),'hud_frame_route':(96,28),'hud_prompt_tab':(128,26),
'hud_docket_modal':(280,166),'hud_button_normal':(160,32),'hud_button_hover':(160,32),'hud_button_pressed':(160,32),
'hud_slip':(64,22),'hud_stamp_frame':(150,37),'hud_keycap':(17,16),'hud_tab_active':(48,18),'hud_tab_idle':(48,18),
'hud_bar_track':(96,10),'hud_bar_fill_health':(96,10),'hud_bar_fill_breath':(96,10),'hud_bar_fill_heat':(145,10),
'hud_reticle':(32,32),'hud_reticle_hit':(32,32),
'icon_health':(24,24),'icon_breath':(24,24),'icon_ampoule':(24,24),'icon_ammo':(24,24),'icon_heat':(24,24),
'icon_writ':(24,24),'icon_evidence_tab':(24,24),'icon_interact':(24,24),'icon_route_arrow':(24,24)
}
GENS={
'hud_frame_brass':('ornate_industrial_pressure_hud_frame.png','64667e00-c40c-47aa-8329-9c8634e70bab'),
'hud_frame_steel':('teal_steel_industrial_hud_panel.png','483040f9-bfe8-4754-9fb0-b47d5f4d9227'),
'hud_prompt_tab':('industrial_brass_service_prompt_bar.png','e8710948-7d08-4b3c-9a64-caf817e111a2'),
'hud_docket_modal':('industrial_pressure_dossier_panel.png','98a72207-51dd-48be-979e-93db72d09ada'),
'hud_button_normal':('worn_brass_framed_docket_button.png','62582e3a-ea39-47ae-8d39-9ed86c01ab73'),
'hud_button_hover':('premium_brass_docket_hover_button.png','542eae8e-4fe4-4494-9b6a-0a331bbdd993'),
'hud_button_pressed':('pressed_steampunk_brass_docket_button.png','3e7bd8bc-5ccf-4438-9390-328b234d7702'),
'hud_slip':('steampunk_brass_bound_filing_slip.png','f812ee3e-70bf-4e16-a59f-97430026e0f7'),
'hud_stamp_frame':('distressed_vermilion_dossier_frame.png','9e343161-7f73-4381-bfca-2463d12465bc'),
'hud_keycap':('worn_brass_industrial_keycap.png','d9f55a7c-e903-40bd-88d9-7aa34c8bfc8c'),
}
ICON_SRC='a_clean_graphic_sprite_sheet_icon_set_on_a_trans.png'
ICON_GEN='f53f3ae5-6416-4884-af58-de1c822fc6ce'

manifest={'project':'THE NINTH EXHALE','set':'HUD_091','generation_date':'2026-11-21',
 'source_provider':'OpenAI Image Generation and original deterministic Pillow drawing',
 'license_review':'pending',
 'runway_note':'No individual HUD 09.1 image is a Runway export. All Runway task IDs intentionally null. The former Runway Style A task c9d38ddd-b52b-49d4-bcbb-7d00d5af135f was a historical reference only.',
 'provenance_note':'generator_job_id values refer to actual OpenAI image-generation gen IDs shown in the session; prompts were inferred from conversation and not directly retrievable as exact API arguments.',
 'elements':OrderedDict()}

def h(path):
 return sha256(Path(path).read_bytes()).hexdigest()

def save_source(name, src_name):
 target=SOURCES/src_name
 if not target.exists(): shutil.copyfile(INPUT/src_name,target)
 return target

def rgba(image):return image.convert('RGBA')

def trim_transparency(im, threshold=14, pad=4):
 arr=np.array(im.convert('RGBA'))
 # eliminate faint isolated alpha fringe; no chromakey because true RGBA images
 alpha=arr[:,:,3]
 alpha[alpha<threshold]=0
 arr[:,:,3]=alpha
 im=Image.fromarray(arr,'RGBA')
 b=im.getchannel('A').getbbox()
 if not b:return im
 x0,y0,x1,y1=b
 return im.crop((max(0,x0-pad),max(0,y0-pad),min(im.width,x1+pad),min(im.height,y1+pad)))

def snap_rgb(im, max_colors=30):
 # use median-cut on RGB but preserve original alpha; many UI elements need only ~30 colours
 im=im.convert('RGBA')
 alpha=im.getchannel('A')
 # Work on fully opaque black backing, then quantize. Edge alpha retained.
 base=Image.new('RGB',im.size,P['black'])
 base.paste(im,mask=alpha)
 quant=base.quantize(colors=max_colors,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE).convert('RGB')
 quant.putalpha(alpha)
 return quant

def resize_generated(im, wh, max_colors=28):
 # Edge-preserving downscale before a crisp limited-palette finish
 im=trim_transparency(im)
 # Crop to content then preserve or gently adjust proportions
 a=np.asarray(im.getchannel('A'))
 b=im.getchannel('A').getbbox()
 # avoid stretched transparency padding, direct fit to target
 im=im.resize(wh,Image.Resampling.LANCZOS)
 im=snap_rgb(im,max_colors)
 # threshold extremely faint downscale halo, but preserve bevel anti-aliasing
 aa=np.array(im)
 aa[:,:,3][aa[:,:,3]<36]=0
 return Image.fromarray(aa,'RGBA')

def output(name,im,provider,source,description,job_id=None,processing=''):
 assert im.mode=='RGBA'
 assert im.size==SIZES[name],f'{name}: {im.size} expected {SIZES[name]}'
 file=OUT/f'{name}.png'
 im.save(file,optimize=True)
 m={'asset_file':str(file.relative_to(ROOT)),'runtime_sha256':h(file),
    'source_file':str(source.relative_to(ROOT)),'source_sha256':h(source),
    'source_provider':provider,'generator_job_id':job_id,
    'runway_task_id':None,'prompt':None if provider=='OpenAI Image Generation' else description,
    'prompt_status':'implicit-context prompt, exact API prompt not available' if provider=='OpenAI Image Generation' else 'not a model prompt: original drawing specification',
    'pixel_size':{'width':im.width,'height':im.height},'nine_slice_margins':dict(zip(['left','top','right','bottom'],BORDER_SLICES[name])) if name in BORDER_SLICES else None,
    'processing':processing or description,'license_review':'pending'}
 manifest['elements'][name]=m

def authored_source(name,im,desc):
 p=SOURCES/f'{name}_programmatic_source.png'
 im.save(p,optimize=True)
 return p

def generated(name):
 path,job=GENS[name]
 s=save_source(name,path)
 return Image.open(s).convert('RGBA'),s,job

def rect(d,b,fill,outline=None,width=1):d.rectangle(b,fill=fill,outline=outline,width=width)

# 1) High-resolution OpenAI source art, resized to the real HUD 09.1 slots.
for name in ['hud_frame_brass','hud_frame_steel','hud_prompt_tab','hud_button_normal','hud_button_hover','hud_button_pressed','hud_slip','hud_stamp_frame','hud_keycap']:
 im,source,job=generated(name)
 out=resize_generated(im,SIZES[name],max_colors=28 if not name.startswith('hud_button') else 24)
 # Dark prompt text field is essential to cream text legibility
 if name=='hud_prompt_tab':
  d=ImageDraw.Draw(out)
  d.rectangle((33,7,116,18),fill=P['black'])
  # Thin metallic inner rule, with no symbols or letters
  d.line((36,6,118,6), fill=P['grey'],width=1)
 if name=='hud_keycap':
  # 17x16 must remain legible with a darker base lip and a plain paper centre
  d=ImageDraw.Draw(out)
  d.rectangle((4,4,12,10),fill=P['paper'])
  d.line((4,12,12,12),fill=P['shadow'])
 # Stamp centre is transparent; ensure no black matte or letters
 if name=='hud_stamp_frame':
  aa=np.array(out)
  # Interior frame transparent but keep faint red spots near edges only
  aa[10:27,18:132,3]=0
  out=Image.fromarray(aa,'RGBA')
 output(name,out,'OpenAI Image Generation',source,
        f'Crop and resample original transparent {name} to canonical Godot HUD source dimensions; quantize to 24–28 colours; retain alpha and clean fringe.',job)

# 2) Modal: Use the generated artwork but REMOVE its baked-in tabs and buttons: Godot draws real controls.
im,source,job=generated('hud_docket_modal')
# Source kept unmodified; the HUD runtime skin is reconstructed using original outer material + dark reading centre.
# In particular, the original source had three decorative button bars that conflict with live controls.
raw=resize_generated(im,(280,166),max_colors=32)
modal=Image.new('RGBA',SIZES['hud_docket_modal'],(0,0,0,0))
modal.alpha_composite(raw)
d=ImageDraw.Draw(modal)
# Cover baked tab/button regions with calm neutral surfaces while preserving riveted outer border.
d.rectangle((15,22,264,148), fill=P['dark'])
d.rectangle((17,24,262,146), fill=P['black'])
# The top band stays a single clean header area for Godot's live 20px title.
d.rectangle((38,5,261,19),fill='#243F3D')
d.line((38,21,260,21),fill=P['brass'])
# No button boxes baked into the background. Make lower part gently lighter behind live button skins.
d.rectangle((17,106,262,146),fill='#2A312E')
d.line((18,104,261,104),fill=P['shadow'])
output('hud_docket_modal',modal,'OpenAI Image Generation',source,
 'Reconstruct generated dossier frame: retain outer edge, paint neutral dark content area and header; remove all baked-in action bars and tab replicas before Godot draws live buttons.',job)

# 3) Route strip derived from the genuine steel source, then tailored to small height.
im,source,job=generated('hud_frame_steel')
route=resize_generated(im,SIZES['hud_frame_route'],max_colors=24)
d=ImageDraw.Draw(route)
# Minimize unnecessary top-left ornament at a 28px height; calm live text field.
d.rectangle((13,8,83,20),fill=P['black'])
d.line((14,7,82,7),fill=P['grey'])
output('hud_frame_route',route,'OpenAI Image Generation',source,
 'Derivative crop of steel frame for 248x28 route compass; 9-slice corners reduced to 8x5; dark centre.',job)

# 4) Original code-drawn UI essentials: note source provider honestly; preserve full-resolution 4x sources.
def add_drawn(name, maker,desc):
 big=maker(4)
 source=authored_source(name,big,desc)
 # area reduction for crisp technical lines then nearest-colour quantization
 sm=big.resize(SIZES[name],Image.Resampling.BOX)
 sm=snap_rgb(sm,16)
 output(name,sm,'Pillow procedural drawing',source,desc,processing='Original deterministic 4x vector/pixel drawing; Box downsample to game size, 16-colour quantization.')

def rounded(d,xy,r,fill,outline=None,width=1):d.rounded_rectangle(xy,radius=r,fill=fill,outline=outline,width=width)

def tabs(active=True):
 def build(k):
  w,h=48*k,18*k
  im=Image.new('RGBA',(w,h),(0,0,0,0));d=ImageDraw.Draw(im)
  upper=P['paper'] if active else P['iron'];lower=P['brass'] if active else P['grey']
  rounded(d,(2*k,2*k,w-3*k,h-2*k),2*k,P['deep'],P['brass'],k)
  d.rectangle((5*k,4*k,w-6*k,h-4*k),fill=upper)
  d.line((5*k,4*k,w-6*k,4*k),fill=P['bright'] if active else P['cool'],width=k)
  d.line((6*k,h-4*k,w-7*k,h-4*k),fill=P['shadow'] if active else P['deep'],width=k)
  d.rectangle((w-9*k,5*k,w-7*k,8*k),fill=P['warning'] if active else P['brass'])
  return im
 return build
add_drawn('hud_tab_active',tabs(True),'Activated docket tab, stale paper and brass upper rule, plain dark-text face, no label.')
add_drawn('hud_tab_idle',tabs(False),'Inactive docket tab, dark iron face for cream text, reduced glint, no label.')

def track(k):
 w,h=96*k,10*k;im=Image.new('RGBA',(w,h),(0,0,0,0));d=ImageDraw.Draw(im)
 rounded(d,(0,0,w-1,h-1),2*k,P['deep'],P['iron'],k)
 d.rectangle((4*k,3*k,w-5*k,6*k),fill=P['black'])
 d.line((5*k,2*k,w-6*k,2*k),fill=P['grey'],width=k)
 d.line((4*k,7*k,w-5*k,7*k),fill=P['shadow'],width=k)
 return im
add_drawn('hud_bar_track',track,'Recessed uniform pressure-gauge channel with retained 6,3,6,3 nine-slice ends.')

def fill_maker(hexcolor,orig_width):
 def maker(k):
  w,h=orig_width*k,10*k;im=Image.new('RGBA',(w,h),(0,0,0,0));d=ImageDraw.Draw(im)
  d.rectangle((0,0,w-1,h-1),fill=hexcolor)
  d.line((0,0,w-1,0),fill=P['bone'],width=k)
  d.line((0,8*k,w-1,8*k),fill=P['deep'],width=k)
  # Very subtle, repeatable horizontal machined channel, no gradient or end caps.
  d.line((0,4*k,w-1,4*k),fill=P['shadow'] if orig_width!=145 else P['dark_bronze'],width=k)
  return im
 return maker
add_drawn('hud_bar_fill_health',fill_maker(P['health'],96),'Flat tileable warm red ochre fill with one-pixel top edge, no endcaps.')
add_drawn('hud_bar_fill_breath',fill_maker(P['teal'],96),'Flat tileable oxide teal pressure fill, no endcaps.')
add_drawn('hud_bar_fill_heat',fill_maker(P['heat'],145),'Flat tileable amber heat fill, no endcaps and no left-to-right gradient.')

# reticle with open 6x6 centre, clean negative space and dark outline even over bright walls
def reticle_maker(hit):
 def maker(k):
  im=Image.new('RGBA',(32*k,32*k),(0,0,0,0));d=ImageDraw.Draw(im)
  cx=cy=16*k
  colour=P['bright'] if hit else P['bone']
  edge=P['deep']
  # 4 isolated T-shaped pressure-indicator stems with open 6x6 middle
  arms=[((cx,4*k),(cx,11*k)),((cx,21*k),(cx,28*k)),((4*k,cy),(11*k,cy)),((21*k,cy),(28*k,cy))]
  for a,b in arms:
   d.line((a,b),fill=edge,width=3*k)
   d.line((a,b),fill=colour,width=k)
  if hit:
   for x,y in [(10,10),(21,10),(10,21),(21,21)]:
    d.rectangle((x*k,y*k,(x+1)*k,(y+1)*k),fill=P['warning'])
  else:
   for x,y in [(9,9),(22,9),(9,22),(22,22)]:
    d.point((x*k,y*k),fill=P['shadow'])
  return im
 return maker
add_drawn('hud_reticle',reticle_maker(False),'32x32 4-arm crosshair with 6x6 open centre and crisp outlined strokes.')
add_drawn('hud_reticle_hit',reticle_maker(True),'32x32 brighter impact state, close ink ticks without blocking centre.')

# 5) ImageGen produced a 3x3 icon sheet. Remove its checkerboard and produce clean, legible unframed 24px silhouettes.
icon_source=save_source('icons',ICON_SRC)
sheet=Image.open(icon_source).convert('RGB')
icon_names=['icon_health','icon_breath','icon_ampoule','icon_ammo','icon_heat','icon_writ','icon_evidence_tab','icon_interact','icon_route_arrow']
# Source artwork is 1293x1217 3x3; all nine slots are separated by whitespace.
for n,name in enumerate(icon_names):
 row=n//3;col=n%3
 x0=round(col*sheet.width/3);x1=round((col+1)*sheet.width/3)
 y0=round(row*sheet.height/3);y1=round((row+1)*sheet.height/3)
 tile=sheet.crop((x0,y0,x1,y1))
 arr=np.array(tile,dtype=np.uint8)
 # Checkerboard area is neutral near-white (>=230 on each channel), non-neutral cream areas survive.
 mi=arr.min(axis=2); ma=arr.max(axis=2)
 mask=(mi<232)|((ma-mi)>25)
 yy,xx=np.where(mask)
 if len(xx)<20:raise RuntimeError(f'No sprite found in {name}')
 padding=5
 xx0=max(0,int(xx.min())-padding);xx1=min(tile.width,int(xx.max())+padding+1)
 yy0=max(0,int(yy.min())-padding);yy1=min(tile.height,int(yy.max())+padding+1)
 arr=arr[yy0:yy1,xx0:xx1,:]
 t=Image.fromarray(arr,'RGB').convert('RGBA')
 rgba_arr=np.array(t)
 mina=rgba_arr[:,:,:3].min(axis=2);maxa=rgba_arr[:,:,:3].max(axis=2)
 bg=(mina>=232)&((maxa-mina)<26)
 rgba_arr[:,:,3]=np.where(bg,0,255).astype('uint8')
 t=Image.fromarray(rgba_arr,'RGBA')
 # ensure visual enough while preserving outline
 fitted=Image.new('RGBA',(24,24),(0,0,0,0))
 t.thumbnail((20,20),Image.Resampling.LANCZOS)
 fitted.alpha_composite(t,((24-t.width)//2,(24-t.height)//2))
 # deliberately limited to max 12 colours; remove soft checkerboard bleeding
 f=np.array(snap_rgb(fitted,11))
 f[:,:,3][f[:,:,3]<110]=0
 f[:,:,3][f[:,:,3]>=110]=255
 icon=Image.fromarray(f,'RGBA')
 output(name,icon,'OpenAI Image Generation',icon_source,
  'Icon cropped from 3x3 OpenAI-generated concept sheet; checkerboard background removed, 20px fit into 24px alpha PNG, quantized to 11 colours and nearest-neighbour-ready silhouette.',ICON_GEN)

# Slice file, no blank optional slots claimed.
(OUT/'hud_091_slices.json').write_text(json.dumps(BORDER_SLICES,indent=2)+'\n')
(ROOT/'art/RUNWAY_HUD_091_MANIFEST.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')

# Create labelled contact sheet at exact source sizes (1x) and 2x on both backgrounds.
try:
 font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',15)
 small=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',12)
except OSError:
 font=ImageFont.load_default();small=font
items=list(SIZES.keys());cols=3;cw=480;ch=225;rows=math.ceil(len(items)/cols)
contact=Image.new('RGB',(cw*cols,ch*rows+28),'#E6E6E6');d=ImageDraw.Draw(contact)
for idx,name in enumerate(items):
 x=(idx%cols)*cw;y=(idx//cols)*ch
 d.rectangle((x+5,y+6,x+cw-5,y+ch-5),outline='#ADADAD',width=1)
 d.text((x+14,y+12),f'{name}  {SIZES[name][0]}×{SIZES[name][1]}',font=font,fill='#171918')
 src=Image.open(OUT/f'{name}.png').convert('RGBA')
 for j,(bg,cap) in enumerate([('#171918','DARK 1×'),('#E1D1A6','PAPER 1×'),('#171918','DARK 2×'),('#E1D1A6','PAPER 2×')]):
  ww=210;hh=73;xx=x+15+(j%2)*230;yy=y+46+(j//2)*84
  tile=Image.new('RGBA',(ww,hh),bg)
  factor=1 if j<2 else 2
  wanted=(src.width*factor,src.height*factor)
  # scale to cell without distorting aspect
  scale=min(1.0, max(0.01,min((ww-8)/wanted[0],(hh-8)/wanted[1])))
  dest=(max(1,round(wanted[0]*scale)),max(1,round(wanted[1]*scale)))
  resized=src.resize(dest,Image.Resampling.NEAREST)
  tile.alpha_composite(resized,((ww-dest[0])//2,(hh-dest[1])//2))
  contact.paste(tile.convert('RGB'),(xx,yy))
  d.text((xx+3,yy+hh-15),cap,font=small,fill='#B7B7B7' if bg=='#171918' else '#363A38')
contact.save(DOC/'HUD_091_CONTACT_SHEET.png',optimize=True)

# Enforce all sources and outputs: no fake files, hashes match, 9-slice 640x400 size constraints.
for name,entry in manifest['elements'].items():
 assert (ROOT/entry['source_file']).exists()
 assert (ROOT/entry['asset_file']).exists()
 assert h(ROOT/entry['source_file'])==entry['source_sha256']
 assert h(ROOT/entry['asset_file'])==entry['runtime_sha256']
 assert Image.open(ROOT/entry['asset_file']).mode=='RGBA'
 assert Image.open(ROOT/entry['asset_file']).size==SIZES[name]
 assert entry['runway_task_id'] is None
 if name not in ['hud_bar_track','hud_bar_fill_health','hud_bar_fill_breath','hud_bar_fill_heat']:
  assert np.array(Image.open(ROOT/entry['asset_file']))[:,:,3].min()==0
 if name in BORDER_SLICES:
  l,t,r,b=BORDER_SLICES[name];w,h0=SIZES[name]
  assert (l+r)<(w/2),name
  assert (t+b)<(h0/2),name
assert len(manifest['elements'])==28,len(manifest['elements'])
print('Created',len(manifest['elements']),'HUD 09.1 assets; source images',len(list(SOURCES.glob('*.png'))))
print('Manifest',ROOT/'art/RUNWAY_HUD_091_MANIFEST.json')
