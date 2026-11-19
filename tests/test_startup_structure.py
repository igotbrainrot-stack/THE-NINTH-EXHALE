#!/usr/bin/env python3
"""Static startup graph checks. Does NOT execute the Godot engine."""
from pathlib import Path
import re
import unittest
ROOT = Path(__file__).resolve().parents[1]

class Startup(unittest.TestCase):
    def test_project_has_visible_main_scene(self):
        project = (ROOT/'project.godot').read_text()
        self.assertIn('run/main_scene="res://scenes/main.tscn"', project)
        scene = (ROOT/'scenes/main.tscn').read_text()
        self.assertIn('[node name="StartScreen" type="Control"]', scene)
        self.assertIn('node name="PlayButton"', scene)
        self.assertIn('text = "ENTER HEARTH NINE"', scene)

    def test_start_event_actually_changes_scenes(self):
        script = (ROOT/'scripts/start_screen.gd').read_text()
        self.assertIn('play_button.pressed.connect(_enter_hearth_nine)', script)
        self.assertIn('change_scene_to_file("res://scenes/hearth_nine.tscn")', script)
        self.assertTrue((ROOT/'scenes/hearth_nine.tscn').exists())

    def test_live_scene_still_loads_player_and_game(self):
        t=(ROOT/'scenes/hearth_nine.tscn').read_text()
        self.assertIn('res://scripts/main.gd',t)
        self.assertIn('res://scripts/player.gd',t)
        self.assertIn('type="CharacterBody3D"',t)
        self.assertIn('Game="*res://scripts/run_state.gd"',(ROOT/'project.godot').read_text())

    def test_no_broken_script_references(self):
        for scene in (ROOT/'scenes').glob('*.tscn'):
            data=scene.read_text()
            for res in re.findall(r'path="(res://[^"]+)"',data):
                self.assertTrue((ROOT/res.removeprefix('res://')).is_file(), res)

    def test_launcher_exists_and_is_executable(self):
        launcher=ROOT/'launch_linux.sh'
        self.assertTrue(launcher.exists())
        self.assertTrue(launcher.stat().st_mode&0o111)
        self.assertIn('--path "$ROOT"',launcher.read_text())

if __name__=='__main__':unittest.main(verbosity=2)
