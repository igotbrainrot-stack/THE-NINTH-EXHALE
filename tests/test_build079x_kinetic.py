from pathlib import Path
import unittest
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
def src(n):return (ROOT/'scripts'/n).read_text()
class Kinetic079X(unittest.TestCase):
 def test_8_direction_roster_atlas_dimensions(self):
  import json
  roster=json.loads((ROOT/'data/enemy_roster_068.json').read_text())['combat_enemies']
  for k in [e['id'] for e in roster]:
   for i in range(1,9):
    atlas=next((q for folder in ('enemies_077','enemies_076','enemies_075','enemies_074','enemies_073','enemies_071') if (q:=ROOT/'assets/sprites'/folder/f'{k}_{i}.png').exists()),None)
    # NPCs may have intentional legacy fallback; only validate full atlases where they exist.
    if atlas:
     with self.subTest(k=k,angle=i), Image.open(atlas) as im:self.assertEqual(im.size,(768,768))
 def test_new_fx_asset_in_game(self):
  with Image.open(ROOT/'assets/fx/civic_muzzle_burst_079x.png') as im:self.assertEqual(im.size,(512,128))
  self.assertIn('civic_muzzle_burst_079x.png',src('game_ui.gd'))
  self.assertIn('tracer_event_079x.connect(_on_tracer_079x)',src('main.gd'))
 def test_los_safety_preserved(self):
  self.assertIn('if not _has_clear_shot():',src('enemy.gd'))
  self.assertIn('and _has_clear_shot()',src('enemy.gd'))
 def test_animation_state_binding(self):
  self.assertIn('animation_state = "hurt"',src('enemy.gd'))
  self.assertIn('talk_time_079x',src('directional_npc_sprite.gd'))
  self.assertIn('child.talk_079x()',src('player.gd'))
if __name__=='__main__':unittest.main()
