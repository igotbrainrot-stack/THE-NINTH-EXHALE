#!/usr/bin/env python3
from __future__ import annotations
import hashlib,json,urllib.request
from io import BytesIO
from pathlib import Path
from PIL import Image,ImageDraw
from rembg import remove,new_session

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
 with urllib.request.urlopen(req,timeout=120) as r: data=r.read()
 if len(data)<2048: raise RuntimeError("Downloaded source is unexpectedly small")
 return data
def normalize_alpha(im,low=8,high=48):
 a=im.getchannel("A"); lut=[]
 for p in range(256):
  if p<=low: lut.append(0)
  elif p>=high: lut.append(255)
  else: lut.append(round((p-low)*255/(high-low)))
 out=im.copy(); out.putalpha(a.point(lut)); return out
def visible_bbox(im,threshold=8):
 return im.getchannel("A").point(lambda p:255 if p>threshold else 0).getbbox()
def solid_bbox(im,threshold=128,pad=8):
 a=im.getchannel("A"); b=a.point(lambda p:255 if p>=threshold else 0).getbbox()
 if b is None: b=a.point(lambda p:255 if p>=48 else 0).getbbox()
 if b is None: raise RuntimeError("No solid foreground after alpha normalization")
 return (max(0,b[0]-pad),max(0,b[1]-pad),min(im.width,b[2]+pad),min(im.height,b[3]+pad))
def rgba(data,label,require_alpha=True):
 im=Image.open(BytesIO(data)).convert("RGBA"); a=im.getchannel("A")
 if require_alpha and a.getextrema()==(255,255): raise RuntimeError(label+" has no alpha")
 if a.getbbox() is None: raise RuntimeError(label+" alpha is empty")
 return normalize_alpha(im)
def segment_sheet(original,session,label):
 w,h=original.size; cw,ch=w//2,h//2; out=Image.new("RGBA",(cw*2,ch*2),(0,0,0,0)); metrics=[]
 boxes=[(0,0,cw,ch),(cw,0,cw*2,ch),(0,ch,cw,ch*2),(cw,ch,cw*2,ch*2)]
 for i,(x0,y0,x1,y1) in enumerate(boxes):
  cell=original.crop((x0,y0,x1,y1)).convert("RGBA")
  result=remove(cell,session=session,alpha_matting=False,post_process_mask=True)
  if isinstance(result,bytes): result=Image.open(BytesIO(result)).convert("RGBA")
  else: result=result.convert("RGBA")
  result=normalize_alpha(result); a=result.getchannel("A"); b=visible_bbox(result); hist=a.histogram(); n=result.width*result.height
  visible=round((n-hist[0])*100/n,2); opaque=round(hist[255]*100/n,2)
  if b is None or visible<2.0 or visible>85.0 or opaque<2.0:
   raise RuntimeError(f"{label} cell {i}: AI mask rejected (visible={visible}%, opaque={opaque}%, bbox={b})")
  corners=[a.getpixel((0,0)),a.getpixel((result.width-1,0)),a.getpixel((0,result.height-1)),a.getpixel((result.width-1,result.height-1))]
  if all(v>32 for v in corners[:3]): raise RuntimeError(f"{label} cell {i}: opaque top/side background remains")
  out.alpha_composite(result,(x0,y0)); metrics.append({"frame":i,"visible_pct":visible,"opaque_pct":opaque,"solid_bbox":list(solid_bbox(result))})
 return out,metrics
def fit(im,box,target):
 x0,y0,x1,y1=target; tw,th=x1-x0,y1-y0; crop=im.crop(box)
 scale=min(tw/crop.width,th/crop.height); nw=max(1,round(crop.width*scale)); nh=max(1,round(crop.height*scale))
 crop=crop.resize((nw,nh),Image.Resampling.LANCZOS)
 out=Image.new("RGBA",CELL,(0,0,0,0)); out.alpha_composite(crop,(x0+(tw-nw)//2,y1-nh)); return out
def quantize(im):
 a=im.getchannel("A"); rgb=im.convert("RGB").quantize(colors=96,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE).convert("RGB"); rgb.putalpha(a); return rgb
def save_strip(frames,path):
 out=Image.new("RGBA",(640*len(frames),400),(0,0,0,0))
 for i,f in enumerate(frames): out.alpha_composite(quantize(f),(640*i,0))
 path.parent.mkdir(parents=True,exist_ok=True); out.save(path,optimize=True); return out
def split2x2(im,label):
 w,h=im.size; cw,ch=w//2,h//2; boxes=[(0,0,cw,ch),(cw,0,2*cw,ch),(0,ch,cw,2*ch),(cw,ch,2*cw,2*ch)]; out=[]
 for i,(x0,y0,x1,y1) in enumerate(boxes):
  f=im.crop((x0+2,y0+2,x1-2,y1-2))
  if visible_bbox(f) is None: raise RuntimeError(f"{label} cell {i} empty")
  out.append(f)
 return out
def union(frames):
 bs=[solid_bbox(f) for f in frames]
 return min(b[0] for b in bs),min(b[1] for b in bs),max(b[2] for b in bs),max(b[3] for b in bs)
def astats(im):
 h=im.getchannel("A").histogram(); n=im.width*im.height
 return {"visible_pct":round((n-h[0])*100/n,2),"opaque_pct":round(h[255]*100/n,2),"semi_pct":round(sum(h[1:255])*100/n,2)}
def thumb(im,bg):
 x=Image.new("RGBA",im.size,bg); x.alpha_composite(im); return x.convert("RGB").resize((320,200),Image.Resampling.LANCZOS)
def main():
 src=json.loads(IMPORT.read_text()); raw=ROOT/"art/production_sources/weapons_092"; runtime=ROOT/"assets/weapons/anim_092"; session=new_session("isnet-general-use")
 manifest={"build":"09.2","engine":"Godot 4.4.1","cell_size":[640,400],"palette_limit":96,"weapons":{},"elements":[],
  "background_removal":{"tool":"rembg","model":"isnet-general-use","alpha_matting":False,"alpha_curve":{"zero_at":8,"opaque_at":48},"solid_crop":{"threshold":128,"padding_px":8},"chromakey":False},
  "research":{"third_party_assets_imported":False,"note":"3D-Shep-Bot searches informed industrial hard-surface research only; no third-party geometry or textures copied into the game."}}
 qa=["# Build 09.2 — Weapon Art Import QA","","Runway masters and action sheets; per-frame AI foreground segmentation; RGB-independent alpha normalization; solid-silhouette crop; no chromakey.","","| Weapon | Idle | Fire/action | Idle opaque | Fire opaque | Unique fire poses | Missing states |","|---|---:|---:|---:|---:|---:|---|"]; rows=[]; before=[]; masks=[]
 for wid,cfg in CFG.items():
  s=src["weapons"][wid]; d=raw/wid; d.mkdir(parents=True,exist_ok=True)
  mb=get(s["master"]["url"]); fb=get(s["fire"]["url"])
  mp=d/(wid+"_master_source.png"); op=d/(wid+"_action_sheet_original_source.png"); cp=d/(wid+"_action_sheet_alpha_source.png")
  mp.write_bytes(mb); op.write_bytes(fb); master=rgba(mb,wid+" master",True)
  original=Image.open(BytesIO(fb)).convert("RGBA"); cutout,segmetrics=segment_sheet(original,session,wid); cutout.save(cp,optimize=True)
  target=cfg["bbox"]; base=fit(master,solid_bbox(master),target); idle=[]
  for dx,dy in [(0,0),(1,0),(2,1),(1,0)]:
   f=Image.new("RGBA",CELL,(0,0,0,0)); f.alpha_composite(base,(dx,dy)); idle.append(f)
  sourceframes=split2x2(cutout,wid+" action"); ub=union(sourceframes); aligned=[fit(f,ub,target) for f in sourceframes]; action=[aligned[i] for i in cfg["indices"]]
  out=runtime/wid; ip=out/(wid+"_idle.png"); ap=out/(wid+"_fire.png"); save_strip(idle,ip); save_strip(action,ap)
  anchors={"muzzle":cfg["muzzle"]}
  if "shell_port" in cfg: anchors["shell_port"]=cfg["shell_port"]
  anim={"cell":[640,400],"anchors":anchors,"procedural":{"recoil":cfg["recoil"],"reload_dip":True},
   "states":{"idle":{"frames":4,"fps":4,"loop":True},"fire":{"frames":len(action),"fps":cfg["fps"],"loop":False}}}
  jp=out/(wid+".anim.json"); jp.write_text(json.dumps(anim,indent=2)+"\n")
  mh,oh,ch=sha(mb),sha(fb),sha(cp.read_bytes()); ih,rh=sha(ip.read_bytes()),sha(ap.read_bytes()); model=s.get("model",{})
  sources=[{"file":str(mp.relative_to(ROOT)),"task_id":s["master"]["task_id"],"sha256":mh,"role":"master frame"},
   {"file":str(op.relative_to(ROOT)),"task_id":s["fire"]["task_id"],"sha256":oh,"role":"original action sheet"},
   {"file":str(cp.relative_to(ROOT)),"sha256":ch,"role":"AI-segmented alpha sheet"}]
  frame_map={"source_indices":cfg["indices"],"unique_source_poses":len(set(cfg["indices"])),"duplicated_holds":sorted({i for i in cfg["indices"] if cfg["indices"].count(i)>1})}
  manifest["weapons"][wid]={"manifest_file":str(jp.relative_to(ROOT)),"target_bbox":list(target),"anchors":anchors,
   "procedural_fallback":["reload","dry","draw","intervene"]+(["vent"] if wid=="nail" else []),
   "states":{"idle":{"file":str(ip.relative_to(ROOT)),"frames":4,"fps":4,"loop":True,"construction":"single master pose with <=2px breathing offsets","runtime_sha256":ih},
    "fire":{"file":str(ap.relative_to(ROOT)),"frames":len(action),"fps":cfg["fps"],"loop":False,"frame_map":frame_map,"runtime_sha256":rh}},
   "source_files":sources,"segmentation_metrics":segmetrics,
   "source_model":{"provider":"Runway Tripo H3.1","task_id":model.get("task_id"),"triangles":model.get("triangles"),"has_materials":model.get("has_materials",True),"runtime_use":"source-only; retopology/LOD required"}}
  for state,t,files,runp,runh,n,fps,loop in [
   ("idle",s["master"],[{"file":str(mp.relative_to(ROOT)),"source_sha256":mh}],ip,ih,4,4,True),
   ("fire",s["fire"],[{"file":str(op.relative_to(ROOT)),"source_sha256":oh},{"file":str(cp.relative_to(ROOT)),"source_sha256":ch}],ap,rh,len(action),cfg["fps"],False)]:
   manifest["elements"].append({"weapon":wid,"state":state,"asset_file":str(runp.relative_to(ROOT)),"runtime_sha256":runh,"source_files":files,
    "generator":"Runway GPT Image 2.6 Sunburst","generator_job_id":t["task_id"],"reference_task_id":t.get("reference_task_id"),"reference_file_id":t.get("reference_file_id"),
    "prompt":t["prompt"],"processing":"RGBA alpha normalized; solid silhouette crop threshold 128 with 8px padding; <=96 RGB colours; 640x400 cells.",
    "background_removal_tool":"rembg/isnet-general-use","pixel_size":[640,400],"frames":n,"fps":fps,"loop":loop,"license_review":"pending"})
  si=astats(idle[0]); sf=astats(action[0])
  if si["opaque_pct"]<3.0 or sf["opaque_pct"]<3.0: raise RuntimeError(f"{wid}: weapon still too translucent after alpha normalization (idle={si}, fire={sf})")
  rows.append((wid,[idle[0]]+action)); masks.append((wid,idle[0].getchannel("A"),action[0].getchannel("A")))
  oldp=ROOT/"assets/weapons"/(wid+"_idle.png"); old=Image.open(oldp).convert("RGBA") if oldp.exists() else Image.new("RGBA",CELL,(0,0,0,0)); before.append((wid,old,idle[0]))
  qa.append(f"| {wid} | 4 | {len(action)} | {si['opaque_pct']:.1f}% | {sf['opaque_pct']:.1f}% | {frame_map['unique_source_poses']} | reload, dry, draw, intervene"+("; vent" if wid=="nail" else "")+" |")
  qa.append(f"\n**{wid} frame map:** {frame_map}; idle is a four-frame micro-breath loop derived from the master pose.")
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
 mask_sheet=Image.new("L",(1280,40+len(masks)*220),0); d=ImageDraw.Draw(mask_sheet)
 for r,(wid,imask,fmask) in enumerate(masks):
  y=40+r*220; d.text((8,y),wid.upper(),fill=255)
  mask_sheet.paste(imask.resize((320,200)),(0,y+20)); mask_sheet.paste(fmask.resize((320,200)),(320,y+20))
  d.text((8,y+202),"IDLE MASK",fill=255); d.text((328,y+202),"FIRE MASK",fill=255)
 mpv=ROOT/"docs/handover/WEAPON_092_ALPHA_MASKS.png"; mask_sheet.save(mpv,optimize=True)
 qa += ["","## Coverage and quality gates","",
  "Alpha is normalized independently of RGB; dark steel and black details are never chromakeyed. Solid cropping uses the alpha core (>128) with 8px padding to remove low-alpha halos and restore viewmodel scale.",
  "Coil and Choir use duplicated holds in the first pass; see frame maps. They need more distinct source poses before final animation sign-off.",
  "Choir idle resonator ripple is outstanding. Reload, dry, draw and intervene remain procedural; Nail Storm vent remains procedural.",
  "Tripo source models are ~1.4M triangles each and remain source-only pending retopology/LOD.",
  "Muzzle anchors are provisional; confirm against the Godot in-game captures. Original Runway sheets and AI-segmented alpha sheets are retained."]
 (ROOT/"docs/handover/WEAPON_092_QA.md").write_text("\n".join(qa)+"\n")
 (raw/"IMPORT_RECEIPT.json").write_text(json.dumps({"build":"09.2","weapons":list(CFG),"background_removal":"rembg/isnet-general-use","alpha_curve":"8->0, 48->255","solid_crop":"threshold128 + 8px padding"},indent=2)+"\n")
 coverage=["weapon,state,frames,fps,loop,status,notes"]
 for wid,item in manifest["weapons"].items():
  idle=item["states"]["idle"]; fire=item["states"]["fire"]; fm=fire["frame_map"]
  coverage.append(f"{wid},idle,{idle['frames']},{idle['fps']},true,generated_provisional,single master pose with <=2px breathing offsets")
  coverage.append(f"{wid},fire,{fire['frames']},{fire['fps']},false,generated_provisional,{fm['unique_source_poses']} unique poses; duplicated holds={fm['duplicated_holds']}")
  for state in ["reload","dry","draw","intervene"]:
   coverage.append(f"{wid},{state},0,0,false,procedural_fallback,art pending")
  if wid=="nail": coverage.append("nail,vent,0,0,false,procedural_fallback,art pending")
  if wid=="choir": coverage.append("choir,idle_shutter_ripple,0,0,true,missing_variant,needs authored resonator shutter motion")
 (ROOT/"art/ART_ANIMATION_COVERAGE_092.csv").write_text("\n".join(coverage)+"\n")
 IMPORT.unlink(missing_ok=True)
 print("WEAPON_092_IMPORT_OK: alpha and solid-crop quality gates passed.")
if __name__=="__main__": main()
