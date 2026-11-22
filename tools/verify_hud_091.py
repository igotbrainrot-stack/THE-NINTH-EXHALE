#!/usr/bin/env python3
"""Pure file/format/sha check of a Godot HUD 09.1 installation. Does not run the game."""
import json,hashlib,sys
from pathlib import Path
from PIL import Image
base=Path(sys.argv[1]).expanduser().resolve() if len(sys.argv)>1 else Path(__file__).resolve().parent.parent
m=json.loads((base/'art/RUNWAY_HUD_091_MANIFEST.json').read_text())
slices=json.loads((base/'assets/ui/hud_091/hud_091_slices.json').read_text())
assert len(m['elements'])==28, ('count',len(m['elements']))
for name,meta in m['elements'].items():
 p=base/meta['asset_file']
 assert p.is_file(),p
 img=Image.open(p)
 assert img.mode=='RGBA',p
 assert tuple(meta['pixel_size'][k] for k in ['width','height'])==img.size,(name,img.size)
 assert hashlib.sha256(p.read_bytes()).hexdigest()==meta['runtime_sha256'],name
 assert meta['runway_task_id'] is None,name
 src=base/meta['source_file'];assert src.is_file(),src
 assert hashlib.sha256(src.read_bytes()).hexdigest()==meta['source_sha256'],name
 if name in slices:
  left,top,right,bottom=slices[name]
  assert left+right<img.width/2, (name,'horizontal margins')
  assert top+bottom<img.height/2, (name,'vertical margins')
print('HUD_091 FILE CHECK: 28/28 RGBA textures, hashes, raw sources and 9-slice margins OK')
