"""Contract checks for the Build 08.2 source-only bug hunt.

These do not emulate the Godot renderer, input stack or physics engine.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class Build082RegressionTests(unittest.TestCase):
    def test_old_world_detached_before_replacement(self):
        main = (ROOT / 'scripts/main.gd').read_text()
        body = main.split('func reload_district_world() -> void:', 1)[1].split('func _setup_environmental_encounter_079', 1)[0]
        self.assertIn('world.process_mode = Node.PROCESS_MODE_DISABLED',body)
        self.assertLess(body.index('remove_child(world)'),body.index('world.queue_free()'))
        self.assertLess(body.index('world.queue_free()'),body.index('add_child(world)'))
    def test_save_does_not_persist_transient_weapon_recoil(self):
        player = (ROOT / 'scripts/player.gd').read_text()
        block=player.split('func capture_position() -> void:',1)[1].split('func restore_position()',1)[0]
        self.assertIn('Game.state["pitch"]=pitch',block)
        self.assertNotIn('Game.state["pitch"]=camera.rotation.x',block)
    def test_restore_discards_old_reloading_and_velocity(self):
        player = (ROOT / 'scripts/player.gd').read_text()
        block=player.split('func restore_position() -> void:',1)[1]
        for expected in ('reloading = false','reload_item = ""','reload_attempt = ""',
                         'reload_zone = ""','dash_time = 0.0','camera_impulse_080 = 0.0',
                         'velocity = Vector3.ZERO'):
            self.assertIn(expected,block)
    def test_portals_only_one_dynamic_light_per_frame(self):
        script = (ROOT/'scripts/world_builder.gd').read_text()
        block=script.split('func add_transition_frame(',1)[1].split('func signboard(',1)[0]
        self.assertEqual(block.count('OmniLight3D.new()'),1)
        self.assertIn('luminous exit indicator',block)

if __name__=='__main__': unittest.main()
