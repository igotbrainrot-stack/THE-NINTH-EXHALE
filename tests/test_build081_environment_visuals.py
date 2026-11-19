"""Source and packaged-art regression gates for the non-gameplay 08.1 architecture pass.
Not a substitute for a Godot renderer or human inspection."""
from pathlib import Path
import unittest
import struct

ROOT = Path(__file__).resolve().parents[1]
ART = (ROOT / 'scripts' / 'industrial_art_pass_081.gd').read_text()
MAIN = (ROOT / 'scripts' / 'main.gd').read_text()
WORLD = (ROOT / 'scripts' / 'world_builder.gd').read_text()

class Build081ArtChecks(unittest.TestCase):
    def test_nine_district_styles(self):
        for district in ('hearth','sootworks','basilica','ashmarket','orchard','barracks','core','assembly','lift'):
            self.assertIn(f'"{district}": _{district}()', ART)
            self.assertIn(f'func _{district}()', ART)

    def test_nonblocking_decorative_geometry(self):
        self.assertNotIn('StaticBody3D.new()',ART)
        self.assertNotIn('CollisionShape3D.new()',ART)
        self.assertNotIn('Game.record_event',ART)
        self.assertNotIn('Game.state[',ART)
        self.assertNotIn('set_meta("interaction_id"',ART)

    def test_instanced_on_world_reload(self):
        self.assertIn('const IndustrialArt081 = preload("res://scripts/industrial_art_pass_081.gd")',MAIN)
        self.assertIn('art_pass.configure(zone)',MAIN)
        self.assertIn('world.add_child(art_pass)',MAIN)

    def test_rail_lift_assembly_portal_differentiation(self):
        for shape in ('legal chamber keystone','sliding cargo door','reinforced rail leaf',
                      'embossed safety shutter rib','visible handle plate'):
            self.assertIn(shape,WORLD)
        self.assertIn('func add_transition_frame(',WORLD)
        self.assertIn('Station controls retain their original interaction IDs',WORLD)

    def test_original_materials_present_and_valid_png(self):
        tiles = [
            'cast_iron_rivets_081.png','ward_crazed_enamel_081.png',
            'patinated_copper_081.png','basilica_salt_wash_081.png','oxidized_forge_081.png',
        ]
        for name in tiles:
            path=ROOT/'assets/textures/architectural_081'/name
            self.assertTrue(path.is_file(),name)
            payload=path.read_bytes()
            self.assertTrue(payload.startswith(b'\x89PNG\r\n\x1a\n'))
            w,h=struct.unpack('>II',payload[16:24])
            self.assertEqual((w,h),(256,256))
            self.assertIn(name.removesuffix('.png'),ART)

    def test_animated_parts_do_not_have_physics(self):
        self.assertIn('moving_parts.append(',ART)
        self.assertIn('part.position = pos',ART)
        self.assertNotIn('move_and_slide',ART)

if __name__ == '__main__': unittest.main()
