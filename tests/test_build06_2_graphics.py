import unittest,json
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
class GraphicsPassTests(unittest.TestCase):
  def test_all_four_facing_views_have_constant_canvas(self):
    for actor in ['sela','brin','ossa']:
      for facing in ['front','left','right','back']:
        # 09.1: cardinals now live in directional8 (the 4-view folder was removed).
        fp=ROOT/'assets'/'sprites'/'directional8'/f"{actor}_{ {'front':1,'left':3,'back':5,'right':7}[facing] }.png"
        self.assertTrue(fp.exists(),str(fp))
        with Image.open(fp) as img:
          self.assertEqual(img.size,(192,280))
          self.assertEqual(img.mode,'RGBA')
          self.assertGreater(img.getchannel('A').getbbox()[3],250)
  def test_camera_direction_runtime_script_linked(self):
    gd=(ROOT/'scripts/directional_npc_sprite.gd').read_text()
    self.assertIn('get_camera_3d()',gd)
    self.assertIn('view_from_world',gd)
    for f in ['world_builder.gd','brin_actor.gd','ossa_actor.gd']:
      self.assertIn('directional_npc_sprite.gd',(ROOT/'scripts'/f).read_text())
  def test_21_runway_art_tasks_have_unique_uuids(self):
    items=json.loads((ROOT/'art/RUNWAY_BATCH_MANIFEST.json').read_text())['assets']
    self.assertEqual(len(items),21)
    self.assertEqual(len({x['label'] for x in items}),21)
    self.assertEqual(len({x['task_id'] for x in items}),21)
  def test_independent_district_material_slots(self):
    assert (ROOT/'assets/textures/soot_floor_v3.png').exists()
    assert (ROOT/'assets/textures/basilica_floor_v3.png').exists()
    self.assertTrue(any(key in (ROOT/'scripts/sootworks_builder.gd').read_text() for key in ('soot_floor_v3','soot_floor_v4')))
    self.assertIn('basilica_floor_v3',(ROOT/'scripts/basilica_builder.gd').read_text())
  def test_new_import_pipeline_is_valid_python(self):
    import py_compile
    py_compile.compile(str(ROOT/'art/tools/import_runway_batch.py'),doraise=True)
  def test_quest_and_hearing_sources_preserved(self):
    for filename in ['main.gd','run_state.gd','player.gd']:
      self.assertTrue((ROOT/'scripts'/filename).exists())

if __name__=='__main__':unittest.main()
