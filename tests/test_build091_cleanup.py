"""Build 09.1 cleanup guard.

The 06.8, 07.1 and 07.3 enemy generations and the legacy 4-view NPC folder
were removed because the runtime lookup never reached them. This test replays
that lookup for every actor the game can spawn, so a future removal that
leaves an actor without art fails here instead of in play.
"""
from pathlib import Path
import json, hashlib, re, subprocess, unittest
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SPRITES = ROOT / "assets/sprites"
REMOVED_DIRS = ["sprites/enemies_068", "sprites/enemies_071", "sprites/enemies_073", "sprites/directional/"]
GUARDS = ["enforcer", "millwright", "cantor", "collector", "edda_machine",
          "core_actuator", "gardener", "commandant", "sentry"]
ECHOFORMS = ["bell_wretch", "rootkin"]
NPCS = ["sela", "brin", "ossa", "oren", "clerk", "venn", "kest"]


def enemy_atlas(key, face):
    """Mirror of enemy.gd _load_directional_animation()."""
    chain = [SPRITES / f"enemies_088/{key}_{face}.png"]
    if key in ("gardener", "commandant"):
        chain.append(SPRITES / f"enemies_077/{key}_{face}.png")
    elif key == "core_actuator":
        chain.append(SPRITES / f"enemies_076/core_actuator_{face}.png")
    elif key == "collector":
        chain.append(SPRITES / f"enemies_075/collector_{face}.png")
    else:
        chain.append(SPRITES / f"enemies_074/{key}_{face}.png")
    return next((p for p in chain if p.is_file()), None)


def echoform_atlas(key, face):
    """Mirror of animated_echoform_068.gd _ready()."""
    chain = [SPRITES / f"enemies_088/{key}_{face}.png", SPRITES / f"enemies_074/{key}_{face}.png"]
    return next((p for p in chain if p.is_file()), None)


def npc_face(stem, face):
    """Mirror of directional_npc_sprite.gd: 08.8 set if present, else directional8."""
    folder = "npc_088" if (SPRITES / f"npc_088/{stem}_1.png").is_file() else "directional8"
    p = SPRITES / f"{folder}/{stem}_{face}.png"
    return p if p.is_file() else None


class Build091Cleanup(unittest.TestCase):
    def test_every_enemy_and_guard_resolves_all_eight_faces(self):
        roster = json.loads((ROOT / "data/enemy_roster_068.json").read_text())
        keys = sorted({str(e["id"]) for e in roster["combat_enemies"]} | set(GUARDS))
        self.assertGreaterEqual(len(keys), 19)  # roster plus the nine district guards
        for key in keys:
            for face in range(1, 9):
                p = enemy_atlas(key, face)
                self.assertIsNotNone(p, f"{key} face {face} has no atlas")
                with Image.open(p) as im:
                    self.assertEqual((768, 768), im.size, str(p))
                    self.assertEqual("RGBA", im.mode, str(p))

    def test_echoforms_and_npcs_resolve(self):
        for key in ECHOFORMS:
            for face in range(1, 9):
                self.assertIsNotNone(echoform_atlas(key, face), f"{key} face {face}")
        for stem in NPCS:
            for face in range(1, 9):
                self.assertIsNotNone(npc_face(stem, face), f"{stem} face {face}")

    def test_no_code_reaches_removed_folders(self):
        for path in list((ROOT / "scripts").glob("*.gd")) + list((ROOT / "scenes").glob("*.tscn")) + [ROOT / "tools/import_art_088.py"]:
            text = path.read_text()
            for gone in REMOVED_DIRS:
                self.assertFalse(gone in text, f"{path.name} still references {gone}")
        for gone in ["enemies_068", "enemies_071", "enemies_073", "directional"]:
            self.assertFalse((SPRITES / gone).exists(), gone)

    def test_removal_log_is_complete_and_recoverable(self):
        log = json.loads((ROOT / "art/BUILD_091_REMOVED_SUPERSEDED.json").read_text())
        self.assertRegex(log["recoverable_from_commit"], r"^[0-9a-f]{40}$")
        self.assertEqual(log["removed_files"], len(log["files"]))
        for item in log["files"]:
            self.assertRegex(item["sha256"], r"^[0-9a-f]{64}$")
            self.assertFalse((ROOT / item["path"]).exists(), item["path"])
            self.assertTrue(item["reason"])

    def test_source_art_is_kept_out_of_godot_import(self):
        self.assertTrue((ROOT / "art/.gdignore").is_file())
        tracked = subprocess.run(["git", "ls-files", "art"], cwd=ROOT, capture_output=True, text=True).stdout.split()
        if tracked:  # only meaningful inside a git checkout
            self.assertEqual([], [t for t in tracked if t.endswith(".import")])

    def test_provenance_hashes_untouched(self):
        # Source sheets keep the exact bytes recorded at import time.
        manifest = json.loads((ROOT / "art/BUILD_088_ART_IMPORT_MANIFEST.json").read_text())
        for key, entry in manifest["entries"].items():
            src = ROOT / entry["source_file"]
            self.assertEqual(entry["source_sha256"], hashlib.sha256(src.read_bytes()).hexdigest(), key)


if __name__ == "__main__":
    unittest.main()
