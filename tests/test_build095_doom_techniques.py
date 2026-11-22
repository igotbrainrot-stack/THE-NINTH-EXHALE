"""Build 09.5 tripwires for the DOOM-like RPG techniques. Behaviour is proven
by tests/godot_doom_095.tscn; these guard the rules in the source."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


def src(name):
    return (ROOT / "scripts" / name).read_text()


class DoomTechniqueTripwires(unittest.TestCase):
    def test_pain_is_deterministic_and_guarded(self):
        enemy = src("enemy.gd")
        hit = enemy.split("func take_hit(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("pain_damage_095 >= pain_needed", hit)
        self.assertIn("pain_guard_095 <= 0.0", hit)
        for banned in ("randf", "randi", "pick_random"):
            self.assertNotIn(banned, hit)
        # The old unconditional flinch on every hit is gone.
        before_guard = hit.split("pain_damage_095 +=", 1)[0]
        self.assertNotIn("stagger_time = maxf(stagger_time,0.24", before_guard)

    def test_hearing_uses_routes(self):
        perception = src("perception_092.gd")
        body = perception.split("static func heard_distance(", 1)[1].split("\nstatic func ", 1)[0]
        self.assertIn("path_length(world, source, listener)", body)
        sense = src("sense_092.gd")
        self.assertEqual(2, sense.count("owner_enemy.get_parent() as Node3D"), "both hearing checks pass the world")

    def test_guards_and_cue_read_the_same_light(self):
        self.assertIn("P.player_light(world_root", src("sense_092.gd"))
        self.assertIn("P.player_light(world_root", src("awareness_cue_093.gd"))
        self.assertIn("Perception092.register_shot(id)", src("player.gd"))

    def test_record_is_on_every_return_rail(self):
        main = src("main.gd")
        self.assertEqual(6, main.count("_with_record_095("), "helper + five district return rails")
        self.assertIn('preload("res://scripts/district_record_095.gd").bump("records")', src("run_state.gd"))


class CalloutTripwires(unittest.TestCase):
    def test_callouts_are_deterministic_and_witnessed(self):
        c = src("callouts_095.gd")
        for banned in ("randf", "randi", "pick_random", "shuffle", "RandomNumberGenerator"):
            self.assertNotIn(banned, c)
        man = c.split("static func man_down(", 1)[1].split("\nstatic func ", 1)[0]
        self.assertIn("_sees(n, dead.global_position", man, "only an ally that saw the death reacts")
        say = c.split("static func say(", 1)[1].split("\nstatic func ", 1)[0]
        self.assertIn('int(enemy.get("hp")) <= 0: return false', say, "the dead never speak")

    def test_each_callout_pairs_with_a_behaviour(self):
        enemy = src("enemy.gd")
        self.assertIn('Callouts095.say(self, "WINDUP_" + role_attack)', enemy.split("func _begin_windup", 1)[1].split("\nfunc ", 1)[0])
        self.assertIn("Callouts095.man_down(self)", enemy)
        c = src("callouts_095.gd")
        reload_fn = c.split("static func player_reloading(", 1)[1]
        self.assertIn('best.set("attack_timer"', reload_fn, "a reload callout makes the enemy press")


if __name__ == "__main__":
    unittest.main()
