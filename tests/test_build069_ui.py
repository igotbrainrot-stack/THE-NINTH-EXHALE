#!/usr/bin/env python3
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class TestBuild069UIPolish(unittest.TestCase):
    def test_ui_assets_exist(self):
        self.assertTrue((ROOT / 'assets/ui/reticle_069.png').exists())
        self.assertTrue((ROOT / 'assets/ui/vignette_069.png').exists())

    def test_game_ui_contains_card_layout_and_prompt_support(self):
        code = (ROOT / 'scripts/game_ui.gd').read_text()
        self.assertIn('func set_interact_prompt(message: String) -> void:', code)
        self.assertIn('ProgressBar.new()', code)
        self.assertIn('ADVISORY ROUTE', code)
        self.assertIn('subtitle.text = "CIVIC RECORD"', code)

    def test_player_emits_aim_prompt_signal(self):
        code = (ROOT / 'scripts/player.gd').read_text()
        self.assertIn('signal aim_prompt_changed(message: String)', code)
        self.assertIn('func _refresh_aim_prompt() -> void:', code)
        self.assertIn('_prompt_for_interaction', code)

    def test_start_screen_mentions_ui_build(self):
        code = (ROOT / 'scripts/start_screen.gd').read_text()
        self.assertTrue(any(label in code for label in ('BUILD 06.9 / UI + HUD POLISH','BUILD 07.1 / EIGHT DIRECTION SPRITES','BUILD 07.2 / EIGHT ANGLES + ADAPTIVE MUSIC','BUILD 07.6 / FREIGHT LIFT + FIRST SIGNATURE')))
        self.assertIn('ACTIVE SAVE DETECTED', code)
        self.assertIn('New and resume attempt choices appear inside the diegetic docket', code)

if __name__ == '__main__':
    unittest.main(verbosity=2)
