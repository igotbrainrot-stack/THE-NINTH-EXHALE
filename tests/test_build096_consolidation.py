"""Build 09.6 consolidation tripwires: story, gameplay and art kept in line
with docs/MASTER_GAME_BIBLE_FINAL.md. Pure source checks, standard library only."""
import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BIBLE = (ROOT / "docs/MASTER_GAME_BIBLE_FINAL.md").read_text(encoding="utf-8")


def src(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def bible_weapon_row(name):
    """Base damage, interval, magazine, reload, range, stagger from the bible's §8 table."""
    for line in BIBLE.splitlines():
        if line.startswith("| **%s** |" % name):
            cells = [c.strip() for c in line.strip("|").split("|")]
            return {
                "damage": float(cells[2]), "interval": float(cells[3]), "mag": float(cells[4]),
                "reload": float(cells[5]), "range": float(cells[6]), "stagger": float(cells[7]),
            }
    raise AssertionError("weapon %s not in the bible table" % name)


def catalog_entry(key):
    m = re.search(r'"%s": \{([^}]*)\}' % key, src("scripts/weapon_catalog.gd"))
    assert m, key
    return {k: float(v) for k, v in re.findall(r'"(\w+)":\s*([0-9.]+)', m.group(1))}


class WeaponsMatchTheBible(unittest.TestCase):
    """The four built weapons carry the bible's numbers, including stagger."""

    def test_each_built_weapon(self):
        for key, name in [("covenant", "Covenant Pistol"), ("coil", "Coil Shotgun"),
                          ("nail", "Nail Storm"), ("choir", "Choirbreaker")]:
            with self.subTest(weapon=key):
                bible = bible_weapon_row(name)
                game = catalog_entry(key)
                damage = game["damage"] * game.get("pellets", 1.0)   # Coil: 8 pellets x 8
                self.assertEqual(damage, bible["damage"])
                for field in ["interval", "mag", "reload", "range", "stagger"]:
                    self.assertAlmostEqual(game[field], bible[field], places=3, msg=field)

    def test_stagger_drives_the_pain_meter(self):
        enemy = src("scripts/enemy.gd")
        player = src("scripts/player.gd")
        self.assertIn("func take_weapon_hit_096(damage: int, stagger: float)", enemy)
        self.assertIn("_incoming_stagger_096 if _incoming_stagger_096 >= 0.0 else float(applied_damage)", enemy)
        self.assertIn('spec.get("stagger", damage)', player)
        self.assertIn('int(spec.get("pellets", 1))', player)  # one Coil shot is one shot of stagger


class OnlyPeopleSpeak(unittest.TestCase):
    """Automata have no words (bible §9, §11.4); people do."""

    def test_every_combat_enemy_has_a_voice_kind(self):
        roster = json.loads(src("data/enemy_roster_068.json"))
        kinds = {e["id"]: e.get("voice") for e in roster["combat_enemies"]}
        self.assertEqual(set(kinds.values()), {"speech", "machine"})
        for machine in ["sentry", "pressure_mite", "vent_whistler", "rivet_courier", "slag_sifter", "edda_machine"]:
            self.assertEqual(kinds[machine], "machine", machine)
        for person in ["enforcer", "registry_bailiff", "cantor", "sluice_beadle"]:
            self.assertEqual(kinds[person], "speech", person)

    def test_barks_and_callouts_follow_the_voice(self):
        perception = src("scripts/perception_092.gd")
        callouts = src("scripts/callouts_095.gd")
        self.assertIn("const MACHINE_BARKS", perception)
        self.assertIn('voice: String = "speech"', perception)
        self.assertIn('owner_enemy.call("voice_kind")', src("scripts/sense_092.gd"))
        self.assertIn("const MACHINE_LINES", callouts)
        machine_block = callouts.split("const MACHINE_LINES", 1)[1].split("}", 1)[0]
        self.assertNotIn("RELOAD", machine_block)           # machines don't read a reload
        for line in re.findall(r'"(\[[^"]*\])"', machine_block):
            self.assertRegex(line, r"^\[[A-Z ]+\]$")        # captions, not words
        self.assertIn('if voice_of(n) != "speech": continue', callouts)

    def test_no_line_gives_ninth_a_pronoun(self):
        lines = " ".join(re.findall(r'"([A-Z][^"]*)"', src("scripts/callouts_095.gd")))
        lines += " ".join(re.findall(r'"([A-Z][^"]*)"', src("scripts/perception_092.gd").split("const BARKS", 1)[1].split("}", 1)[0]))
        self.assertIsNone(re.search(r"\b(HE|HE'S|HIM|HIS|SHE|SHE'S|HER)\b", lines))


class NoDiceInTheStory(unittest.TestCase):
    def test_assembly_counts_constituencies_not_rolls(self):
        main = src("scripts/main.gd")
        self.assertNotIn("Affirmative rolls", main)
        self.assertIn("Affirmative constituencies: %d / 3.", main)


class ArtFollowsTheBible(unittest.TestCase):
    def test_frame_tabs_drawn_above_panels(self):
        ui = src("scripts/game_ui.gd")
        self.assertIn('const HUD091_TAB_096 := {"hud_frame_brass": 5, "hud_frame_steel": 5, "hud_frame_route": 3, "hud_docket_modal": 3}', ui)
        self.assertIn("style.expand_margin_top = float(HUD091_TAB_096[name])", ui)
        self.assertIn("drawn HUD frames do not overlap", src("tests/godot_codefix_regressions.gd"))

    def test_district_light_follows_the_space_table(self):
        main = src("scripts/main.gd")
        self.assertIn('env.ambient_light_color = Color("#c39a74")', main)   # Sootworks furnace
        self.assertIn('env.ambient_light_color = Color("#b8c0c4")', main)   # Barracks security white
        self.assertIn('env.ambient_light_color = Color("#c4bca8")', main)   # Hearth warm clinical
        depth = float(re.search(r"FURNACE_PULSE_DEPTH_096 := ([0-9.]+)", main).group(1))
        period = float(re.search(r"FURNACE_PULSE_SECONDS_096 := ([0-9.]+)", main).group(1))
        self.assertLessEqual(depth, 0.05)    # a slow glow, not flashing (bible §13 accessibility)
        self.assertGreaterEqual(period, 2.0)


class DocsPointAtTheCurrentState(unittest.TestCase):
    def test_stale_docs_are_marked_historical(self):
        for rel in ["docs/NEXT_STEPS_ROADMAP.md", "docs/DEVELOPMENT_HANDOVER.md"]:
            with self.subTest(doc=rel):
                self.assertIn("docs/research/CONSOLIDATION_REVIEW_096.md", src(rel)[:800])

    def test_review_and_art_brief_exist(self):
        self.assertTrue((ROOT / "docs/research/CONSOLIDATION_REVIEW_096.md").exists())
        self.assertTrue((ROOT / "docs/handover/GPT_ART_CONSOLIDATION_096.md").exists())


if __name__ == "__main__":
    unittest.main()
