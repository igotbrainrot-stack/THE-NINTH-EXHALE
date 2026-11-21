#!/usr/bin/env python3
from __future__ import annotations
import hashlib, json, urllib.request
from io import BytesIO
from pathlib import Path
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
IMPORT=ROOT/"art/production_sources/weapons_092/IMPORT_SOURCES.json"
CELL=(640,400)
CFG={
 "covenant":{"bbox":(408,177,624,400),"muzzle":[404,214],"shell_port":[470,236],"indices":[0,1,2,3],"fps":24,"recoil":0.25},
 "coil":{"bbox":(214,184,629,400),"muzzle":[226,204],"indices":[0,1,1,2,2,3],"fps":18,"recoil":0.22},
 "nail":{"bbox":(195,197,638,400),"muzzle":[207,217],"indices":[2,3],"fps":24,"recoil":0.28},
 "choir":{"bbox":(211,180,640,400),"muzzle":[223,200],"indices":[0,1,2,2,3],"fps":20,"recoil":0.22}
}
def sha(b): return hashlib.sha256(b).hexdigest()
def get(url):
 req=urllib.request.Request(url,headers={"User-Agent":"THE-NINTH-EXHALE-Weapon-Importer/1.0"})
 with urllib.request.urlopen(req,timeout=120) as r: b=r.read()
 if len(b)<2048: raise RuntimeError("source download too small")
 return b
def rgba(b,label):
 im=Image.open(BytesIO(b)).convert("RGBA"); a=im.getchannel("A")
 if a.getextrema()==(255,255): raise RuntimeError(label+" has no alpha; refusing destructive keying")
 if a.getbbox() is None: raise RuntimeError(label+" alpha is empty")
 corners=[a.getpixel((0,0)),a.getpixel((im.width-1,0)),a.getpixel((0,im.height-1)),a.getpixel((im.width-1,im.height-1))]
 if min(corners)>32: raise RuntimeError(label+" background corners are opaque")
 return im
def bbox(im):
 return im.getchannel("A").point(lambda p:255 if p>8 else 0).getbbox()
def fit(im,box,target):
 x0,y0,x1,y1=target; tw,th=x1-x0,y1-y0
 crop=im.crop(box); scale=min(tw/crop.width,th/crop.height)
 nw=max(1,round(crop.width*scale)); nh=max(1,round(crop.height*scale))
 crop=crop.resize((nw,nh),Image.Resampling.LANCZOS)
 out=Image.new("RGBA",CELL,(0,0,0,0)); out.alpha_composite(crop,(x0+(tw-nw)//2,y1-nh))
 return out
def qrgba(im):
 a=im.getchannel("A")
 rgb=im.convert("RGB").quantize(colors=96,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE).convert("RGB")
 rgb.putalpha(a); return rgb
def save_strip(frames,path):
 out=Image.new("RGBA",(640*len(frames),400),(0,0,0,0))
 for i,f in enumerate(frames): out.alpha_composite(qrgba(f),(640*i,0))
 path.parent.mkdir(parents=True,exist_ok=True); out.save(path,optimize=True); return out
def cells2x2(im,label):
 w,h=im.size; cw,ch=w//2,h//2; boxes=[(0,0,cw,ch),(cw,0,2*cw,ch),(0,ch,cw,2*ch),(cw,ch,2*cw,2*ch)]
 out=[]
 for i,(x0,y0,x1,y1) in enumerate(boxes):
  f=im.crop((x0+2,y0+2,x1-2,y1-2))
  if bbox(f) is None: raise RuntimeError(f"{label} cell {i} is empty")
  out.append(f)
 return out
def union(frames):
 bs=[bbox(f) for f in frames]
 return min(b[0] for b in bs),min(b[1] for b in bs),max(b[2] for b in bs),max(b[3] for b in bs)
def stats(im):
 h=im.getchannel("A").histogram(); n=im.width*im.height
 return {"opaque_pct":round(h[255]*100/n,2),"semi_pct":round(sum(h[1:255])*100/n,2)}
def thumb(im,bg):
 x=Image.new("RGBA",im.size,bg); x.alpha_composite(im); return x.convert("RGB").resize((320,200),Image.Resampling.LANCZOS)
def main():
 src=json.loads(IMPORT.read_text()); raw=ROOT/"art/production_sources/weapons_092"; runtime=ROOT/"assets/weapons/anim_092"
 manifest={"build":"09.2","engine":"Godot 4.4.1","cell_size":[640,400],"palette_limit":96,"weapons":{},"elements":[],"research":{"third_party_assets_imported":False,"note":"3D-Shep-Bot used for visual research only; no third-party geometry or textures copied into the game."}}
 qa=["# Build 09.2 — Weapon Art Import QA","","New Runway masters and 2x2 action sheets converted to 640x400 SpriteAnim092 strips.","","| Weapon | Idle | Fire/action | Other states |","|---|---:|---:|---|"]
 rows=[]; before=[]
 for wid,cfg in CFG.items():
  s=src["weapons"][wid]; d=raw/wid; d.mkdir(parents=True,exist_ok=True)
  mb=get(s["master"]["url"]); fb=get(s["fire"]["url"])
  mp=d/(wid+"_master_source.png"); fp=d/(wid+"_action_sheet_source.png"); mp.write_bytes(mb); fp.write_bytes(fb)
  master=rgba(mb,wid+" master"); sheet=rgba(fb,wid+" action")
  target=cfg["bbox"]; base=fit(master,bbox(master),target)
  idle=[]
  for dx,dy in [(0,0),(1,0),(2,1),(1,0)]:
   f=Image.new("RGBA",CELL,(0,0,0,0)); f.alpha_composite(base,(dx,dy)); idle.append(f)
  srcframes=cells2x2(sheet,wid+" action"); ub=union(srcframes)
  aligned=[fit(f,ub,target) for f in srcframes]
  action=[aligned[i] for i in cfg["indices"]]
  out=runtime/wid; ip=out/(wid+"_idle.png"); ap=out/(wid+"_fire.png")
  save_strip(idle,ip); save_strip(action,ap)
  anchors={"muzzle":cfg["muzzle"]}
  if "shell_port" in cfg: anchors["shell_port"]=cfg["shell_port"]
  anim={"cell":[640,400],"anchors":anchors,"procedural":{"recoil":cfg["recoil"],"reload_dip":True},
        "states":{"idle":{"frames":4,"fps":4,"loop":True},"fire":{"frames":len(action),"fps":cfg["fps"],"loop":False}}}
  jp=out/(wid+".anim.json"); jp.write_text(json.dumps(anim,indent=2)+"\n")
  mh,fh=sha(mb),sha(fb); ih,rh=sha(ip.read_bytes()),sha(ap.read_bytes()); model=s.get("model",{})
  manifest["weapons"][wid]={"manifest_file":str(jp.relative_to(ROOT)),"target_bbox":list(target),"anchors":anchors,
   "procedural_fallback":["reload","dry","draw","intervene"]+(["vent"] if wid=="nail" else []),
   "states":{"idle":{"file":str(ip.relative_to(ROOT)),"frames":4,"fps":4,"loop":True,"runtime_sha256":ih},
             "fire":{"file":str(ap.relative_to(ROOT)),"frames":len(action),"fps":cfg["fps"],"loop":False,"runtime_sha256":rh}},
   "source_files":[{"file":str(mp.relative_to(ROOT)),"task_id":s["master"]["task_id"],"sha256":mh},{"file":str(fp.relative_to(ROOT)),"task_id":s["fire"]["task_id"],"sha256":fh}],
   "source_model":{"provider":"Runway Tripo H3.1","task_id":model.get("task_id"),"triangles":model.get("triangles"),"has_materials":model.get("has_materials",True),"runtime_use":"source-only; retopology/LOD required"}}
  for state,t,rawp,rawh,runp,runh,n,fps,loop in [("idle",s["master"],mp,mh,ip,ih,4,4,True),("fire",s["fire"],fp,fh,ap,rh,len(action),cfg["fps"],False)]:
   manifest["elements"].append({"weapon":wid,"state":state,"asset_file":str(runp.relative_to(ROOT)),"runtime_sha256":runh,
    "source_files":[{"file":str(rawp.relative_to(ROOT)),"source_sha256":rawh}],"generator":"Runway GPT Image 2.6 Sunburst",
    "generator_job_id":t["task_id"],"reference_task_id":t.get("reference_task_id"),"reference_file_id":t.get("reference_file_id"),
    "prompt":t["prompt"],"processing":"RGBA alpha-trim; aligned to existing viewmodel bbox; <=96 RGB colours; horizontal strip.",
    "pixel_size":[640,400],"frames":n,"fps":fps,"loop":loop,"license_review":"pending"})
  rows.append((wid,[idle[0]]+action))
  oldp=ROOT/"assets/weapons"/(wid+"_idle.png"); old=Image.open(oldp).convert("RGBA") if oldp.exists() else Image.new("RGBA",CELL,(0,0,0,0))
  before.append((wid,old,idle[0]))
  os=stats(old); ns=stats(idle[0]); qa.append(f"| {wid} | 4 | {len(action)} | Procedural fallback retained |")
  qa.append(f"\n**{wid} alpha audit:** old opaque {os['opaque_pct']}%, old semi-transparent {os['semi_pct']}%; new opaque {ns['opaque_pct']}%, new semi-transparent {ns['semi_pct']}%.")
 (ROOT/"art/WEAPON_ANIM_092_MANIFEST.json").write_text(json.dumps(manifest,indent=2)+"\n")
 contact=Image.new("RGB",(1600,40+len(rows)*236),(30,32,30)); d=ImageDraw.Draw(contact); d.text((8,8),"WEAPON 09.2 — IDLE + ACTION FRAMES / DARK BACKING",fill=(240,230,205))
 for r,(wid,frames) in enumerate(rows):
  y=40+r*236; d.text((6,y+2),wid.upper(),fill=(230,210,170))
  for c,f in enumerate(frames[:5]): contact.paste(thumb(f,(23,25,24,255)),(c*320,y+24))
 cp=ROOT/"docs/handover/WEAPON_092_CONTACT_SHEET.png"; cp.parent.mkdir(parents=True,exist_ok=True); contact.save(cp,optimize=True)
 comp=Image.new("RGB",(1280,40+len(before)*440),(30,32,30)); d=ImageDraw.Draw(comp); d.text((8,8),"WEAPON ART 09.2 — BEFORE / AFTER, DARK AND LIGHT",fill=(240,230,205))
 for r,(wid,old,new) in enumerate(before):
  y=40+r*440; d.text((8,y),wid.upper(),fill=(230,210,170))
  for c,(f,bg) in enumerate([(old,(23,25,24,255)),(new,(23,25,24,255)),(old,(225,209,166,255)),(new,(225,209,166,255))]): comp.paste(thumb(f,bg),(c*320,y+24))
  for c,label in enumerate(["OLD / DARK","NEW / DARK","OLD / LIGHT","NEW / LIGHT"]): d.text((c*320+8,y+226),label,fill=(235,235,225))
 bp=ROOT/"docs/handover/WEAPON_092_BEFORE_AFTER.png"; comp.save(bp,optimize=True)
 qa += ["","## Coverage","",
  "Idle and fire/mechanical-action strips are delivered. Reload, dry-fire, draw and intervene remain on existing procedural fallback; Nail Storm vent also remains procedural.",
  "The Tripo source models are approximately 1.4M triangles each and are not runtime-ready; retopology and LOD are required.",
  "Muzzle anchors are provisional and require visual confirmation in the Godot playbot capture.",
  "Opaque-background exports are rejected; the importer does not chromakey away weapon detail."]
 (ROOT/"docs/handover/WEAPON_092_QA.md").write_text("\n".join(qa)+"\n")
 (raw/"IMPORT_RECEIPT.json").write_text(json.dumps({"build":"09.2","weapons":list(CFG),"temporary_signed_urls_removed":True},indent=2)+"\n")
 IMPORT.unlink(missing_ok=True)
 print("WEAPON_092_IMPORT_OK idle=4 each; action frames covenant=4 coil=6 nail=2 choir=5; alpha verified; palette<=96.")
if __name__=="__main__": main()
