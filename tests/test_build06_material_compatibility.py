"""Prevent recurrence of the Build 06 Godot BaseMaterial3D repeat enum parse error.

These are source checks, not a substitute for a headless Godot import.
"""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class MaterialRepeatCompatibility(unittest.TestCase):
    def test_repeat_setting_is_boolean_in_world_builder(self):
        text = (ROOT / "scripts/world_builder.gd").read_text(encoding="utf-8")
        self.assertRegex(text, r"mat\.texture_repeat\s*=\s*true\b")
        self.assertIn("mat.uv1_triplanar = true", text)

    def test_no_2d_texture_repeat_enum_used_in_3d_materials(self):
        for file in sorted((ROOT / "scripts").glob("*.gd")):
            with self.subTest(script=file.name):
                text = file.read_text(encoding="utf-8")
                self.assertNotIn("BaseMaterial3D.TEXTURE_REPEAT_ENABLED", text)
                self.assertNotRegex(
                    text,
                    r"(?m)^\s*\w+\.texture_repeat\s*=\s*(?:BaseMaterial3D|StandardMaterial3D)\.",
                )


if __name__ == "__main__":
    unittest.main()
