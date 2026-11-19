import pathlib, re, unittest
from PIL import Image
ROOT=pathlib.Path(__file__).resolve().parents[1]

class ArtPassTests(unittest.TestCase):
    def test_structural_detail_in_both_worlds(self):
        world=(ROOT/'scripts/world_builder.gd').read_text()
        soot=(ROOT/'scripts/sootworks_builder.gd').read_text()
        art=(ROOT/'scripts/art_detail.gd').read_text()
        for key in ('decorate_hearth()','decorate_sootworks()'):
            self.assertIn(key,world+soot)
            self.assertIn('func '+key+' -> void',art)
        self.assertIn('prepare(material_cache)',world)
        self.assertIn('prepare(material_cache)',soot)
        self.assertIn('uv1_triplanar',world)
        self.assertIn('decorative',art.lower())
        self.assertNotIn('CollisionShape3D',art)
        self.assertNotIn('StaticBody3D',art)
    def test_material_files_and_pixel_sprite(self):
        for name in ('floor_grid','ward_linen','requisition_steel','furnace_iron','corroded_paper','ward_enamel_v2','furnace_facing_v2','hazard_ochre_v2'):
            p=ROOT/f'assets/textures/{name}.png'
            self.assertTrue(p.is_file(),p)
            with Image.open(p) as img:
                self.assertEqual(img.size,(256,256))
                self.assertGreater(len(img.getcolors(256*256) or []),2)
        with Image.open(ROOT/'assets/sprites/covenant_pistol.png') as img:
            self.assertGreaterEqual(img.size[0],256)
            self.assertGreaterEqual(img.size[1],144)
            self.assertEqual(img.mode,'RGBA')
            self.assertEqual(img.getpixel((0,0))[3],0)
    def test_no_canon_or_interaction_replacement(self):
        self.assertTrue((ROOT/'docs/MASTER_GAME_BIBLE_FINAL.md').is_file())
        self.assertIn('"payroll_cylinder"',(ROOT/'scripts/sootworks_builder.gd').read_text())
        self.assertIn('"lung_rack"',(ROOT/'scripts/world_builder.gd').read_text())
        self.assertIn('"labour_registry"',(ROOT/'scripts/sootworks_builder.gd').read_text())
    def test_runway_provenance_and_importer_are_present(self):
        ref=(ROOT/'art/RUNWAY_ASSETS.md').read_text()
        for task in ('7498fe04','6d153692','6110cb57','d739c913'):
            self.assertIn(task,ref)
        self.assertTrue((ROOT/'art/tools/import_runway_exports.py').exists())
    def test_bounded_3d_detail_drawcalls(self):
        gd=(ROOT/'scripts/art_detail.gd').read_text()
        self.assertNotIn('while true',gd)
        self.assertGreater(gd.count('block('),20)
        self.assertNotRegex(gd,r'range\(-span_[xz]\s*/\s*2')
if __name__=='__main__':unittest.main()
