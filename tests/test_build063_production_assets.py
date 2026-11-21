"""Source-level graphics regression tests; NO Godot runtime verification claimed."""
import json,unittest
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
class AssetChecks(unittest.TestCase):
 def test_every_major_npc_has_four_angles(self):
  for person in ['sela','brin','ossa','oren','clerk']:
   for side in ['front','left','right','back']:
    # 09.1: the 4-view folder was removed; directional8 holds the same cardinals.
    im=Image.open(ROOT/'assets/sprites/directional8'/f"{person}_{ {'front':1,'left':3,'back':5,'right':7}[side] }.png")
    self.assertEqual(im.size,(192,280));self.assertEqual(im.mode,'RGBA')
    self.assertLess(im.getpixel((1,1))[3],40)
 def test_three_distinct_hostiles(self):
  for name in ['enforcer','millwright','cantor']:
   self.assertTrue((ROOT/'assets/sprites'/f'{name}_front.png').exists())
  self.assertIn('"res://assets/sprites/%s_front.png" % actor_key',(ROOT/'scripts/enemy.gd').read_text())
 def test_five_material_variants(self):
  manifest=json.loads((ROOT/'art/RUNTIME_ASSET_MANIFEST.json').read_text())
  for path in manifest['tiles'].values():
   with Image.open(ROOT/path) as image:
    self.assertEqual(image.size,(512,512))
 def test_27_props_and_layout(self):
  self.assertEqual(len(list((ROOT/'assets/sprites/props').glob('*.png'))),27)
  art=(ROOT/'scripts/art_detail.gd').read_text()
  for area in ['hearth','sootworks','basilica']:
   self.assertIn('"'+area+'"',art)
  self.assertIn('decorate_population("hearth")',(ROOT/'scripts/world_builder.gd').read_text())
  self.assertIn('decorate_population("sootworks")',(ROOT/'scripts/sootworks_builder.gd').read_text())
  self.assertIn('decorate_population("basilica")',(ROOT/'scripts/basilica_builder.gd').read_text())
 def test_in_engine_gun_visual_asset(self):
  with Image.open(ROOT/'assets/sprites/covenant_pistol.png') as im:
   self.assertEqual(im.mode,'RGBA')
   self.assertEqual(im.size,(600,450))
  ui=(ROOT/'scripts/game_ui.gd').read_text()
  self.assertIn('gun.texture=load("res://assets/weapons/covenant_idle.png")',ui)
  for key in ('covenant','coil','nail','choir'):
   with Image.open(ROOT/'assets/weapons'/f'{key}_idle.png') as weapon:
    self.assertEqual(weapon.size,(640,400))
    self.assertEqual(weapon.mode,'RGBA')
 def test_godot_api_error_regression(self):
  for s in (ROOT/'scripts').glob('*.gd'):
   self.assertNotIn('TEXTURE_REPEAT_ENABLED',s.read_text())
 def test_missing_routes_not_claimed(self):
  txt=(ROOT/'README.md').read_text()
  self.assertIn('not yet playtested',txt.lower())
if __name__=='__main__':unittest.main()
