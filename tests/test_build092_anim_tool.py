"""Build 09.2: tools/anim_092.py accepts a clean delivery and rejects the
mistakes the art handovers warn about (floating feet, wrong frame counts)."""
from pathlib import Path
import json, subprocess, sys, tempfile, unittest
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools" / "anim_092.py"


def make_delivery(root: Path, float_frame: bool = False, declare: int = 4) -> Path:
    folder = root / "foe"
    folder.mkdir(parents=True)
    (folder / "foe.anim.json").write_text(json.dumps({"cell": [192, 256], "states": {"idle": {"frames": declare, "fps": 4, "loop": True}}}))
    strip = Image.new("RGBA", (192 * 4, 256), (0, 0, 0, 0))
    d = ImageDraw.Draw(strip)
    for i in range(4):
        lift = 14 if (float_frame and i == 2) else 0
        d.rectangle([i * 192 + 70, 20 - lift, i * 192 + 122, 252 - lift], fill=(60, 70, 65, 255))
    strip.save(folder / "foe_idle_1.png")
    return folder


def run(*args):
    return subprocess.run([sys.executable, "-I", str(TOOL), *args], capture_output=True, text=True)


class AnimToolTests(unittest.TestCase):
    def test_clean_delivery_passes(self):
        with tempfile.TemporaryDirectory() as t:
            folder = make_delivery(Path(t))
            r = run("check", str(folder))
            self.assertEqual(0, r.returncode, r.stdout + r.stderr)

    def test_floating_frame_fails(self):
        with tempfile.TemporaryDirectory() as t:
            folder = make_delivery(Path(t), float_frame=True)
            r = run("check", str(folder))
            self.assertEqual(1, r.returncode)
            self.assertIn("foot baseline", r.stdout)

    def test_frame_count_must_match_manifest(self):
        with tempfile.TemporaryDirectory() as t:
            folder = make_delivery(Path(t), declare=6)
            r = run("check", str(folder))
            self.assertEqual(1, r.returncode)
            self.assertIn("manifest declares 6", r.stdout)

    def test_slice_and_preview(self):
        with tempfile.TemporaryDirectory() as t:
            t = Path(t)
            sheet = Image.new("RGB", (192 * 2, 256), (255, 0, 255))
            ImageDraw.Draw(sheet).rectangle([70, 20, 122, 252], fill=(60, 70, 65))
            ImageDraw.Draw(sheet).rectangle([262, 20, 314, 252], fill=(60, 70, 65))
            sheet.save(t / "sheet.png")
            out = t / "foe"
            out.mkdir()
            (out / "foe.anim.json").write_text(json.dumps({"cell": [192, 256], "states": {"idle": {"frames": 2, "fps": 4}}}))
            self.assertEqual(0, run("slice", str(t / "sheet.png"), "--cell", "192x256", "--out", str(out), "--stem", "foe", "--rows", "idle:2", "--facing", "3", "--key-magenta").returncode)
            strip = Image.open(out / "foe_idle_3.png")
            self.assertEqual((384, 256), strip.size)
            self.assertEqual(0, strip.getpixel((5, 5))[3])
            self.assertEqual(0, run("check", str(out)).returncode)
            self.assertEqual(0, run("preview", str(out), "--out", str(t / "prev")).returncode)
            self.assertTrue((t / "prev" / "foe_idle_3.gif").exists())


if __name__ == "__main__":
    unittest.main()
