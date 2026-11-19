from pathlib import Path
import unittest
ROOT = Path(__file__).resolve().parents[1]
class Build080(unittest.TestCase):
    def test_witness_gestures_are_wired_to_real_interaction(self):
        main=(ROOT/'scripts/main.gd').read_text()
        actor=(ROOT/'scripts/directional_npc_sprite.gd').read_text()
        self.assertIn('interaction_id in ["brin", "ossa"]',main)
        self.assertIn('visual.talk_079x()',main)
        self.assertIn('if is_instance_valid(witness):',main)
        self.assertIn('func listen_080()',actor)
        self.assertIn('pose = 2 + int(pose_clock_080*8.0)%2',actor)
        self.assertIn('elif listen_time_080 > 0.0:',actor)
    def test_shot_recoil_has_accessible_toggle_and_is_bounded(self):
        s=(ROOT/'scripts/player.gd').read_text()
        self.assertIn('camera_impulse_enabled_080',s)
        self.assertIn('camera_impulse_strength_080',s)
        self.assertIn('clampf(camera_impulse_080-impulse*camera_impulse_strength_080,-0.055,0.0)',s)
        self.assertIn('camera.rotation.x = pitch + camera_impulse_080',s)
    def test_existing_spatial_safeguards_present(self):
        e=(ROOT/'scripts/enemy.gd').read_text()
        self.assertIn('if not _has_clear_shot():',e)
        self.assertIn('_update_aim_lane_079z()',e)
        self.assertIn('query.collision_mask = 3',e)

class DeathPose080(unittest.TestCase):
    def test_remains_are_visual_and_bounded(self):
        e=(ROOT/'scripts/enemy.gd').read_text()
        c=(ROOT/'scripts/combat_corpse_080.gd').read_text()
        self.assertIn('func _finish_death_080()',e)
        self.assertIn('remains.configure(sprite.texture, sprite.pixel_size)',e)
        self.assertIn('LIFETIME: float = 5.5',c)
        self.assertNotIn('CollisionShape3D',c)
        self.assertIn('queue_free()',c)
