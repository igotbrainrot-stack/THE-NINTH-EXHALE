"""Build 08.8 art import: provenance manifest is complete, hashes match, and no
Runway task IDs are invented."""
from pathlib import Path
import hashlib, json, unittest
from PIL import Image
ROOT = Path(__file__).resolve().parents[1]
MANIFEST = json.loads((ROOT / 'art/BUILD_088_ART_IMPORT_MANIFEST.json').read_text())

class Build088ArtImport(unittest.TestCase):
    def test_no_invented_provenance(self):
        self.assertIn('pending', MANIFEST['runway_task_ids'])
        self.assertEqual('pending', MANIFEST['license_review'])
        for key, entry in MANIFEST['entries'].items():
            self.assertIsNone(entry['runway_task_id'], key)
            self.assertEqual('pending', entry['license_review'], key)

    def test_sources_and_outputs_match_hashes(self):
        for key, entry in MANIFEST['entries'].items():
            src = ROOT / entry['source_file']
            self.assertEqual(hashlib.sha256(src.read_bytes()).hexdigest(), entry['source_sha256'], key)
            for rel, digest in entry['outputs'].items():
                self.assertEqual(hashlib.sha256((ROOT / rel).read_bytes()).hexdigest(), digest, rel)

    def test_every_actor_has_eight_views_in_the_right_format(self):
        for key, entry in MANIFEST['entries'].items():
            for view in range(1, 9):
                if entry['kind'] == 'npc':
                    face = Image.open(ROOT / f'assets/sprites/npc_088/{key}_{view}.png')
                    idle = Image.open(ROOT / f'assets/sprites/npc_idle_088/{key}_{view}.png')
                    self.assertEqual((192, 280), face.size, key)
                    self.assertEqual((768, 280), idle.size, key)
                else:
                    atlas = Image.open(ROOT / f'assets/sprites/enemies_088/{key}_{view}.png')
                    self.assertEqual((768, 768), atlas.size, key)
                    self.assertEqual('RGBA', atlas.mode, key)

    def test_older_sprites_are_kept_as_fallbacks(self):
        for key, entry in MANIFEST['entries'].items():
            if entry['replaces']:
                self.assertTrue((ROOT / entry['replaces']).exists(), key)

    def test_loaders_prefer_088_art(self):
        self.assertIn('npc_088', (ROOT / 'scripts/directional_npc_sprite.gd').read_text())
        self.assertIn('enemies_088', (ROOT / 'scripts/enemy.gd').read_text())
        self.assertIn('enemies_088', (ROOT / 'scripts/animated_echoform_068.gd').read_text())

if __name__ == '__main__':
    unittest.main()
