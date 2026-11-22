"""Verify the 07.3 active eight-direction in-game artwork, not just file counts.

The 07.2 problem was valid-looking PNGs that were eight near-copies of frontal
illustrations. We require significant raster differences among EVERY pair and
verify the actual enemy, Echoform and gallery scripts select the fixed files.
"""
from pathlib import Path
import itertools,unittest,sys,json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
# 09.1: the 07.3 outputs were removed; their 07.4 polish keeps the eight
# genuinely rotated views and is what every actor falls back to.
SRC=ROOT/'assets/sprites/enemies_074'
NPC=ROOT/'assets/sprites/directional8'
SOURCES=ROOT/'art/production_sources/turntable_073'
MANIFEST=json.loads((ROOT/'art/RUNWAY_073_REGENERATION.json').read_text())
ENEMIES=set(MANIFEST['characters'])-{'sela','brin','ossa','oren','clerk'}

def pixels(image):
    out=image.convert('RGBA')
    bg=Image.new('RGBA',out.size,(44,49,47,255));bg.alpha_composite(out)
    return np.array(bg.convert('RGB'),dtype=np.int16)

class TrueEightRegression(unittest.TestCase):
 def test_22_rigs_have_full_true_turntables(self):
    self.assertEqual(22,len(MANIFEST['characters']))
    for key in MANIFEST['characters']:
       p=SOURCES/f'{key}_8way_TRUE_3d.png'
       self.assertTrue(p.is_file(),key)
       with Image.open(p) as im:
          self.assertIn(im.size,[(768,512),(768,560)])
          self.assertEqual(im.mode,'RGBA')
 def test_all_17_enemy_atlases_eight_non_duplicate_views(self):
    self.assertEqual(17,len(ENEMIES))
    for key in sorted(ENEMIES):
       views=[]
       for n in range(1,9):
          p=SRC/f'{key}_{n}.png'
          self.assertTrue(p.is_file(),str(p))
          with Image.open(p) as im:
             self.assertEqual((768,768),im.size)
             self.assertEqual('RGBA',im.mode)
             views.append(pixels(im.crop((0,0,192,256))))
       for a,b in itertools.combinations(range(8),2):
          delta=float(np.abs(views[a]-views[b]).mean())
          self.assertGreater(delta,2.5, f'{key} directions {a+1} and {b+1} are near duplicates: {delta:.2f}')
 def test_five_painted_npcs_preserved_but_genuinely_distinct(self):
    for key in ['sela','brin','ossa','oren','clerk']:
       views=[]
       for n in range(1,9):
          with Image.open(NPC/f'{key}_{n}.png') as im:
             self.assertEqual((192,280),im.size)
             views.append(pixels(im))
       for a,b in itertools.combinations(range(8),2):
          delta=float(np.abs(views[a]-views[b]).mean())
          self.assertGreater(delta,4.0,f'{key} {a+1}/{b+1} lacks a separate perspective')
 def test_runtime_and_gallery_use_new_atlases_first(self):
    for filename in ['enemy.gd','animated_echoform_068.gd']:
       text=(ROOT/'scripts'/filename).read_text()
       self.assertIn('res://assets/sprites/enemies_088/%s_%d.png',text)
       self.assertIn('enemies_074/%s_%d.png',text)
    gallery=(ROOT/'scripts/enemy_gallery_068.gd').read_text()
    self.assertIn('var source_dir: String = "enemies_074"',gallery)
    self.assertIn('source_dir = "enemies_088"',gallery)
    self.assertIn('KEY_T:',gallery)
    self.assertIn('view_from_world',(ROOT/'scripts/enemy.gd').read_text())
    self.assertIn('view_from_world',(ROOT/'scripts/directional_npc_sprite.gd').read_text())
 def test_runway_22_export_manifest_not_claimed_embedded(self):
    self.assertEqual(22,len(MANIFEST['characters']))
    for key,val in MANIFEST['characters'].items():
       self.assertFalse(val['embedded_in_game'],key)
       self.assertEqual('complete_in_runway_external',val['status'])
    self.assertTrue((ROOT/'art/tools/import_runway_true_eight_073.py').is_file())
 def test_duplicate_runway_sheet_is_rejected_not_imported(self):
    from importlib.util import spec_from_file_location,module_from_spec
    spec=spec_from_file_location('import_quality',ROOT/'art/tools/import_runway_true_eight_073.py')
    sys.path.insert(0,str(ROOT/'art/tools'))
    m=module_from_spec(spec);spec.loader.exec_module(m)
    from PIL import ImageDraw
    im=Image.new('RGBA',(192,256))
    draw=ImageDraw.Draw(im);draw.ellipse((53,9,147,184),fill=(130,82,45,255))
    report=m.quality_gate([im.copy() for _ in range(8)])
    self.assertFalse(report['passed'])
    self.assertTrue(any('near-duplicate' in i for i in report['issues']))
 def test_immutable_canon_and_3d_furniture_unmodified(self):
    s=(ROOT/'scripts/run_state.gd').read_text()
    for key in ['qobj_writ_of_labour','qobj_writ_of_faith','hearth.lung_installed']:
       self.assertIn(key,s)
    p=(ROOT/'scripts/prop_mesh_070.gd').read_text()
    self.assertIn('BoxMesh.new()',p)

if __name__=='__main__':unittest.main()
