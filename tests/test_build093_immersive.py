"""Build 09.3 immersive-sim Phase 1b tripwires. Behaviour is proven by
tests/godot_immersive_093.tscn; these guard the rules in the source."""
from pathlib import Path
import re, unittest

ROOT = Path(__file__).resolve().parents[1]
SENSE_FILES = ["perception_092.gd", "sense_092.gd", "witness_runner_093.gd", "named_witness_093.gd",
               "walk_grid_093.gd", "path_follower_093.gd", "awareness_cue_093.gd"]


def src(name):
    return (ROOT / "scripts" / name).read_text()


class ImmersiveTripwires(unittest.TestCase):
    def test_no_dice_in_perception(self):
        # Bible L699 / POR-20: reactions are deterministic.
        for name in SENSE_FILES:
            text = src(name)
            for banned in ("randf", "randi", "RandomNumberGenerator", "randomize", "pick_random"):
                self.assertNotIn(banned, text, f"{name} uses {banned}")

    def test_report_recorded_only_on_delivery(self):
        runner = src("witness_runner_093.gd")
        deliver = runner[runner.index("func _deliver"):]
        self.assertIn('record_event("witness.093.%s.reported_to_%s"', deliver)
        # The only record_event in the runner is inside _deliver.
        self.assertEqual(1, runner.count("record_event("))
        # A dead runner drops the pending report.
        self.assertIn('Game.state.get("witness_093", {}).erase(victim)', runner)

    def test_threat_handler_starts_a_run_not_an_alert(self):
        main = src("main.gd")
        body = main.split("func _on_named_witness_threatened_085(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("NamedWitness093.start_run(", body)
        self.assertNotIn("guard.anger()", body)

    def test_patrols_search_then_stay_alert(self):
        enemy = src("enemy.gd")
        self.assertIn("sense_092.lose_track(last_seen_position)", enemy)
        self.assertIn('sense_092.temperament == "patrol"', enemy)
        sense = src("sense_092.gd")
        self.assertIn('_set_state("HIGH_ALERT")', sense)
        self.assertIn('"high_alert_093"', sense)

    def test_dialogue_gated_while_threatened(self):
        main = src("main.gd")
        for key in ("brin", "ossa"):
            self.assertIn(f'_witness_gate_093("{key}")', main)
        self.assertIn('"witness:calm:" + key', main)

    def test_hud_cue_sits_above_vitals(self):
        cue = src("awareness_cue_093.gd")
        self.assertIn("position = Vector2(8, 322)", cue)
        self.assertIn("size = Vector2(204, 16)", cue)  # ends at y = 338, vitals start at 340


if __name__ == "__main__":
    unittest.main()
