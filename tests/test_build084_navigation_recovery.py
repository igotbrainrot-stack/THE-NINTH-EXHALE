import unittest
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]

class NavigationRecovery084Tests(unittest.TestCase):
    def test_bounded_lateral_recovery(self):
        text=(BASE/'scripts/enemy.gd').read_text()
        self.assertIn('obstacle_dodge_time_084 = 0.56',text)
        self.assertIn('get_slide_collision_count()',text)
        self.assertIn('obstacle_dodge_cooldown_084 = 0.80',text)
        self.assertIn('role_move != "turret"',text)
        self.assertIn('rush_time <= 0.0',text)
    def test_cover_rules_remain_authoritative(self):
        text=(BASE/'scripts/enemy.gd').read_text()
        self.assertIn('if not _has_clear_shot():',text)
        self.assertIn('if not sees_player:',text)
        self.assertIn('get_world_3d().direct_space_state.intersect_ray',text)
    def test_original_quest_roster_unchanged(self):
        import json
        roster=json.loads((BASE/'data/enemy_roster_068.json').read_text())
        ids={a['id'] for a in roster['combat_enemies']}
        self.assertTrue({'sentry','enforcer','millwright','cantor'}.issubset(ids))

if __name__=='__main__': unittest.main()
