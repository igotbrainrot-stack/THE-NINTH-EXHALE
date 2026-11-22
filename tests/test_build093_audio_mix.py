"""Build 09.3 audio integration: the routing config is consistent with the
recovered Runway sources, and the sources are untouched (manifest hashes)."""
from pathlib import Path
import hashlib, json, unittest

ROOT = Path(__file__).resolve().parents[1]
MIX = json.loads((ROOT / "data" / "audio_mix_093.json").read_text())
MANIFEST = json.loads((ROOT / "art" / "RUNWAY_AUDIO_20261122_MANIFEST.json").read_text())


def res(path):
    return ROOT / path.replace("res://", "")


class AudioMixTests(unittest.TestCase):
    def test_sources_are_unmodified(self):
        # Shaping happens at playback; the recovered files must stay byte-identical.
        for asset in MANIFEST["assets"]:
            data = (ROOT / asset["target_path"]).read_bytes()
            self.assertEqual(asset["sha256"], hashlib.sha256(data).hexdigest(), asset["target_path"])

    def test_every_replacement_points_at_a_manifest_file(self):
        known = {a["target_path"] for a in MANIFEST["assets"]}
        for wid, prof in MIX["weapons"].items():
            if prof.get("source") == "runway":
                self.assertIn(prof["path"].replace("res://", ""), known, wid)
                self.assertTrue(res(prof["path"]).exists(), wid)
                self.assertTrue((ROOT / "assets" / "audio" / f"{wid}_fire.wav").exists(), f"{wid} keeps its fallback")
        self.assertIn(MIX["music"]["combat"]["path"].replace("res://", ""), known)
        self.assertTrue(res(MIX["music"]["combat_fallback"]).exists())

    def test_modes_and_levels_are_sane(self):
        for wid, prof in MIX["weapons"].items():
            if prof.get("source") != "runway":
                continue
            self.assertIn(prof["mode"], ("one_shot", "burst", "mono"))
            self.assertLessEqual(prof["volume_db"], 0.0, "never boost above unity")
        self.assertEqual("burst", MIX["weapons"]["nail"]["mode"], "the nail file is a 0.6 s burst; per-shot play would stack")
        self.assertEqual("mono", MIX["weapons"]["choir"]["mode"], "a 1 s tone refired every 0.44 s must not stack")

    def test_loop_is_whole_bars_inside_the_file(self):
        m = MIX["music"]["combat"]
        duration = next(a["duration_seconds"] for a in MANIFEST["assets"] if a["key"] == "combat_music")
        self.assertLess(m["loop_end"], duration)
        self.assertGreaterEqual(m["loop_start"], 0.0)
        bar = 4 * 60.0 / m["bpm"]
        bars = (m["loop_end"] - m["loop_start"]) / bar
        self.assertAlmostEqual(bars, round(bars), delta=0.01, msg=f"loop is {bars:.3f} bars")
        self.assertLessEqual(m["trim_db"], 0.0)

    def test_combat_music_needs_real_hostility(self):
        src = (ROOT / "scripts" / "adaptive_music_072.gd").read_text()
        body = src.split("func _combat_threat_nearby", 1)[1].split("\nfunc ", 1)[0]
        self.assertNotIn("wake > 0.0 and distance", body)
        self.assertIn("if is_fighting and distance <= COMBAT_ENGAGE_DISTANCE", body)


if __name__ == "__main__":
    unittest.main()
