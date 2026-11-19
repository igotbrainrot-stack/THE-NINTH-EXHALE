#!/usr/bin/env python3
"""Narrow regression for the reported Build 02 GDScript inference issue. Not an engine parser."""
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]

class TestReportedTypeIssue(unittest.TestCase):
    def test_enforcer_raycast_destination_has_explicit_static_type(self):
        code=(ROOT/"scripts/enemy.gd").read_text()
        self.assertIn("var destination: Vector3 = player.global_position",code)
        self.assertNotIn("var destination := player.global_position",code)
        self.assertIn("PhysicsRayQueryParameters3D.create(origin,destination)",code)
    def test_game_scene_still_references_enemy(self):
        code=(ROOT/"scripts/main.gd").read_text()
        self.assertIn('preload("res://scripts/enemy.gd")',code)
        self.assertRegex(code,r"guard\.player\s*=\s*player")
if __name__=="__main__":unittest.main(verbosity=2)
