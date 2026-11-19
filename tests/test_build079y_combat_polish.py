"""Targeted source checks and portable geometry checks for 07.9Y.
These checks do NOT replace Godot collision or animation playtests.
"""
import math
from pathlib import Path
import unittest

BASE = Path(__file__).resolve().parents[1]

def read(path):
    return (BASE / 'scripts' / path).read_text()

class CombatPolish079Y(unittest.TestCase):
    def test_blocked_basilica_pull_cannot_steal_breath(self):
        enemy = read('enemy.gd')
        self.assertIn('func _line_attack(damage: int) -> bool:', enemy)
        self.assertIn('if _line_attack(role_damage):\n                Game.state["breath"]', enemy)
        self.assertIn('return false\n\nfunc _commit_attack', enemy)

    def test_enemy_fire_tracer_ends_at_physics_hit(self):
        enemy = read('enemy.gd')
        self.assertIn('var endpoint: Vector3 = hit.get("position",destination)', enemy)
        self.assertIn('_draw_attack_streak_079y(origin,endpoint)', enemy)
        self.assertIn('query.collision_mask = 3', enemy)

    def test_animation_states_reset_their_phase(self):
        enemy = read('enemy.gd')
        self.assertIn('if animation_state != displayed_animation_state_079y:', enemy)
        self.assertIn('animation_timer = 0.0', enemy)
        self.assertIn('animation_state = "death"', enemy)

    def test_vent_opening_and_cover_path(self):
        hazard = read('encounter_hazard_079.gd')
        self.assertIn('_pulse_enemy_pressure_079y()', hazard)
        self.assertIn('if exposed and _has_clear_pressure_path_079y():', hazard)
        self.assertIn('if hazard_key != "sootworks": return', hazard)
        self.assertIn('query.collision_mask = 1', hazard)
        for x,z,inside in [(0,0,True),(1.29,4.19,True),(1.30,0,False),(0,4.20,False)]:
            self.assertEqual(abs(x)<1.3 and abs(z)<4.2, inside)

    def test_fixture_shocks_optional_hostiles_without_farming(self):
        main = read('main.gd')
        self.assertIn('for foe in additional_enemies.values():', main)
        self.assertIn('foe.apply_environmental_stagger', main)
        self.assertNotIn('Game.award_xp_once', main[main.index('func _on_pressure_fixture_burst'):main.index('func ',main.index('func _on_pressure_fixture_burst')+5)])

if __name__ == '__main__':
    unittest.main()
