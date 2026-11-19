"""Build 07.0 prop geometry contract. Source-only validation, not Godot runtime."""
import re
import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

class PropDepth(unittest.TestCase):
    def test_all_66_placements_use_procedural_meshes(self):
        code=(ROOT/'scripts/art_detail.gd').read_text()
        self.assertIn('model.setup(district,index,scale_value)',code)
        self.assertIn('const PropMesh070 = preload("res://scripts/prop_mesh_070.gd")',code)
        self.assertNotIn('Sprite3D.new()',code)
        chunks=re.split(r'        "(hearth|sootworks|basilica)":\n',code)
        for region in ('hearth','sootworks','basilica'):
            # Retained authored fixture positions are not shuffled or removed.
            fragment=chunks[chunks.index(region)+1]
            self.assertEqual(len(re.findall(r'\[\d+,[-\d.]+,[-\d.]+,[\d.]+\]',fragment)),22,region)

    def test_27_profile_meshes_exist(self):
        code=(ROOT/'scripts/prop_mesh_070.gd').read_text()
        for region in ['_hearth','_sootworks','_basilica']:
            part=code.split('func '+region+'(index: int) -> void:',1)[1].split('\nfunc ',1)[0]
            ids=set(map(int,re.findall(r'^        (\d+):',part,re.M)))
            self.assertEqual(ids,set(range(1,10)),(region,ids))

    def test_meshes_have_surface_depth_and_all_angles(self):
        code=(ROOT/'scripts/prop_mesh_070.gd').read_text()
        self.assertIn('BoxMesh.new()',code)
        self.assertIn('CylinderMesh.new()',code)
        self.assertIn('material_override = material[finish]',code)
        self.assertIn('uv1_triplanar = true',code)
        self.assertIn('TEXTURE_FILTER_NEAREST',code)
        self.assertIn('mesh',code)
        self.assertNotIn('billboard =',code)
        self.assertNotIn('Sprite3D.new()',code)

    def test_no_new_collision_routes_changed(self):
        code=(ROOT/'scripts/prop_mesh_070.gd').read_text()
        self.assertNotIn('CollisionShape3D.new()',code)
        self.assertNotIn('StaticBody3D.new()',code)
        for region in ['world_builder.gd','sootworks_builder.gd','basilica_builder.gd']:
            self.assertIn('decorate_population(', (ROOT/'scripts'/region).read_text())

    def test_true_3d_inspection_gallery(self):
        title=(ROOT/'scenes/main.tscn').read_text()
        start=(ROOT/'scripts/start_screen.gd').read_text()
        gallery=(ROOT/'scripts/prop_gallery_070.gd').read_text()
        self.assertIn('PropGalleryButton',title)
        self.assertIn('prop_gallery_button.pressed.connect(_enter_prop_gallery)',start)
        self.assertIn('res://scenes/prop_gallery_070.tscn',start)
        self.assertIn('displayed.rotation.y +=',gallery)
        self.assertIn('PropMesh070.new()',gallery)
        self.assertNotIn('Game.state[',gallery)

if __name__=='__main__':unittest.main(verbosity=2)
