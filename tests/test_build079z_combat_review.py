"""07.9Z regression checks. Source / archive tests are not a Godot runtime playtest."""
import pathlib
import struct
import unittest
ROOT = pathlib.Path(__file__).resolve().parents[1]

def body(name):
    return (ROOT/'scripts'/name).read_text(encoding='utf8')

class CombatReview(unittest.TestCase):
    def test_windup_lane_lifetime_and_wall_clip(self):
        s = body('enemy.gd')
        self.assertIn('_update_aim_lane_079z()',s)
        self.assertIn('query.collision_mask = 1',s)
        self.assertIn('if not obstruction.is_empty(): goal = obstruction["position"]',s)
        self.assertIn('aim_lane_079z.visible = false\n    attack_sequence += 1',s)
        self.assertIn('aim_lane_079z.visible = false\n        # Death',s)

    def test_hazard_and_fixture_respect_world_collision(self):
        hazard=body('encounter_hazard_079.gd')
        main=body('main.gd')
        self.assertIn('_clear_path_to_actor_079z(foe)',hazard)
        self.assertIn('_pressure_fixture_has_path_079z(at,guard)',main)
        self.assertIn('_pressure_fixture_has_path_079z(at,foe)',main)
        self.assertIn('var affected: bool = false',main)
        self.assertIn('if affected else',main)

    def test_civilian_hurt_is_visual_only(self):
        s=body('directional_npc_sprite.gd')
        self.assertIn('func hurt_079z()',s)
        self.assertIn('modulate = Color("#ed8b74")',s)
        self.assertNotIn('scale = Vector3(',s)
        for actor in ('brin_actor.gd','ossa_actor.gd'):
            self.assertIn('child.hurt_079z()',body(actor))

    def test_roster_primary_eight_view_atlas_dimensions(self):
        # Check file headers, not PNG decoder availability or generated claims.
        for name in ('sentry','enforcer','millwright','cantor'):
            for angle in range(1,9):
                path=ROOT/'assets'/'sprites'/'enemies_074'/f'{name}_{angle}.png'
                self.assertTrue(path.exists(),str(path))
                with path.open('rb') as stream:
                    header=stream.read(24)
                self.assertEqual(header[:8],b'\x89PNG\r\n\x1a\n')
                self.assertEqual(struct.unpack('>II',header[16:24]),(768,768))

if __name__=='__main__': unittest.main()
