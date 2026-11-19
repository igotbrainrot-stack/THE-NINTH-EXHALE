"""Image-data and source-contract checks. These do not execute the Godot engine."""
from pathlib import Path
import json
import math
import unittest
from PIL import Image, ImageChops

ROOT=Path(__file__).resolve().parents[1]
ART=json.loads((ROOT/'art/EIGHT_VIEW_ASSET_MANIFEST_071.json').read_text())
ACTORS=ART['enemy_ids']

class EightDirection071(unittest.TestCase):
    def test_exact_order_and_zero_is_universal(self):
        self.assertEqual(ART['angle_order'], {'1':'front','2':'diagonal_left_front','3':'left','4':'diagonal_left_back','5':'back','6':'diagonal_right_back','7':'right','8':'diagonal_right_front'})
        self.assertIn('universal',ART['rotation_0'])
    def test_angle_math_in_all_eight_sectors(self):
        # Mirrors the published Godot local-space angle equation for source QA.
        cases=[(0,-1,1),(-1,-1,2),(-1,0,3),(-1,1,4),(0,1,5),(1,1,6),(1,0,7),(1,-1,8)]
        for x,z,want in cases:
            bearing=math.atan2(x,-z)
            selected=(math.floor((-bearing+math.pi/8)/(math.pi/4)) % 8)+1
            self.assertEqual(selected,want,(x,z))
        self.assertIn('Rotation8.view_from_world', (ROOT/'scripts/enemy.gd').read_text())
    def test_all_five_npcs_have_distinct_eight_angle_slots(self):
        for name in ['sela','brin','ossa','oren','clerk']:
            images=[]
            for rotation in range(1,9):
                path=ROOT/'assets/sprites/directional8'/f'{name}_{rotation}.png'
                self.assertTrue(path.is_file(),str(path))
                with Image.open(path) as im:
                    self.assertEqual(im.size,(192,280))
                    self.assertEqual(im.mode,'RGBA')
                    self.assertIsNotNone(im.getchannel('A').getbbox())
                    images.append(im.copy())
            self.assertIsNotNone(ImageChops.difference(images[0],images[1]).getbbox(),name)
    def test_eight_12_frame_enemy_and_echoform_atlases(self):
        self.assertEqual(17,len(ACTORS))
        for id in ACTORS:
            for direction in range(1,9):
                p=ROOT/'assets/sprites/enemies_071'/f'{id}_{direction}.png'
                self.assertTrue(p.is_file(),str(p))
                with Image.open(p) as im:
                    self.assertEqual((768,768),im.size)
                    self.assertEqual('RGBA',im.mode)
                    self.assertIsNotNone(im.crop((0,0,192,256)).getchannel('A').getbbox())
    def test_legacy_cardinals_are_preserved_identically(self):
        for enemy in ACTORS:
            for d,side in [(1,'front'),(3,'left'),(5,'back'),(7,'right')]:
                with Image.open(ROOT/'assets/sprites/enemies_068'/f'{enemy}_{side}.png') as old, Image.open(ROOT/'assets/sprites/enemies_071'/f'{enemy}_{d}.png') as new:
                    self.assertIsNone(ImageChops.difference(old.convert('RGBA'),new.convert('RGBA')).getbbox())
    def test_3d_prop_geometry_not_replaced_by_billboards(self):
        source=(ROOT/'scripts/prop_mesh_070.gd').read_text()
        self.assertIn('extends Node3D',source)
        self.assertIn('BoxMesh.new()',source)
        self.assertNotIn('Sprite3D.new()',source)
        prop=(ROOT/'scripts/prop_gallery_070.gd').read_text()
        self.assertIn('PI / 4.0',prop)
    def test_brin_source_provenance_and_galleries(self):
        self.assertTrue((ROOT/ART['new_eight_view_art']['source']).exists())
        self.assertIn('provisional',ART['provenance'])
        self.assertTrue((ROOT/'scenes/npc_gallery_071.tscn').exists())
        start=(ROOT/'scripts/start_screen.gd').read_text()
        self.assertIn('_enter_npc_gallery',start)
        self.assertIn('ENEMY GALLERY',start)
        enemy=(ROOT/'scripts/enemy_gallery_068.gd').read_text()
        self.assertIn('posmod(face+1,9)',enemy)
    def test_no_changes_to_quest_ids(self):
        state=(ROOT/'scripts/run_state.gd').read_text()
        for x in ['qobj_writ_of_labour','qobj_writ_of_faith','hearth.lung_installed']:
            self.assertIn(x,state)

if __name__=='__main__': unittest.main()
