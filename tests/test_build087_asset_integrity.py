from pathlib import Path
import json, hashlib, re, unittest
ROOT = Path(__file__).resolve().parents[1]

class Build087Assets(unittest.TestCase):
    def test_all_canonical_hud_icons_are_referenced_in_live_ui(self):
        text=(ROOT/'scripts/game_ui.gd').read_text()
        for icon in ['health','breath','ampoule','ammo','heat','writ','evidence_tab','interact','route_arrow']:
            self.assertIn('"icon_'+icon+'"',text)
            self.assertTrue((ROOT/'assets/ui/hud_086'/('icon_'+icon+'.png')).exists())

    def test_no_unreferenced_hud_icon_size_derivatives(self):
        # Canonical HUD assets are 24px and dynamically resized.
        self.assertEqual([],list((ROOT/'assets/ui/hud_086').glob('icon_*_16.png')))
        self.assertEqual([],list((ROOT/'assets/ui/hud_086').glob('icon_*_24.png')))

    def test_hud_manifest_has_true_provenance_and_valid_hashes(self):
        d=json.loads((ROOT/'art/RUNWAY_HUD_086_MANIFEST.json').read_text())
        self.assertIn('NOT Runway', d['source_provider'])
        self.assertEqual(23, len(d['elements']))
        for name,elem in d['elements'].items():
            self.assertIsNone(elem['runway_task_id'],name)
            for path_field,hash_field in [('asset_file','runtime_sha256'),('source_file','source_sha256')]:
                p=ROOT/elem[path_field]
                self.assertTrue(p.is_file(),name)
                self.assertEqual(hashlib.sha256(p.read_bytes()).hexdigest(),elem[hash_field],name)
            if margins:=elem.get('nine_slice_margins'):
                width=elem['pixel_size']['width'];height=elem['pixel_size']['height']
                self.assertLess(margins['left']+margins['right'],width)
                self.assertLess(margins['top']+margins['bottom'],height)

    def test_generated_audio_fallback_is_preserved(self):
        for i in range(4): self.assertTrue((ROOT/f'assets/audio/actor_083/npc_grunt_{i}.wav').exists())
        for kind in ('mechanical','organic'):
            for event in ('alert','windup','attack','hurt','death'):
                self.assertTrue((ROOT/f'assets/audio/actor_083/{kind}_{event}.wav').exists())

    def test_registry_all_current_files_exist(self):
        d=json.loads((ROOT/'art/BUILD_087_RUNTIME_ASSET_REGISTRY.json').read_text())
        self.assertEqual(778, d['summary']['total_media_files'])
        for item in d['assets']:
            self.assertEqual(hashlib.sha256((ROOT/item['path']).read_bytes()).hexdigest(),item['sha256'])

if __name__=='__main__':unittest.main()
