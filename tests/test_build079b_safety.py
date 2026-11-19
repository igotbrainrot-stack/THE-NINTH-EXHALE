import unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
class Build079BSafety(unittest.TestCase):
    def test_rush_requires_visible_path_on_commit_and_contact(self):
        s=(ROOT/'scripts/enemy.gd').read_text()
        self.assertIn('if rush_hit_ready and distance < role_reach and _has_clear_shot():',s)
        self.assertIn('if not _has_clear_shot():\n            recovery = 0.35',s)
        self.assertNotIn('role_attack != "rush"',s)
    def test_materials_are_authored_not_node_names(self):
        s=(ROOT/'scripts/player.gd').read_text()
        self.assertIn('target.has_meta("surface_kind")',s)
        self.assertNotIn('label_text',s)
    def test_service_confirmation_precedes_finite_spend(self):
        s=(ROOT/'scripts/main.gd').read_text()
        self.assertLess(s.index('pending_quiet_service_079 != zone'),s.index('if Game.shut_down_hazard_079(zone,method):'))
        self.assertIn('PREVENTIVE ISOLATION',s)
        self.assertIn('1 ENERGY + 1 LABOUR',s)
if __name__ == '__main__': unittest.main()
