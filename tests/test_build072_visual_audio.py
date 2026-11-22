"""Build 07.2: static/project tests, NOT Godot engine runtime or subjective audio QA."""
import json, subprocess, unittest, sys, shutil
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'art/tools'))
from import_runway_eight_views_072 import cut_magenta, split_sheet, make_enemy_atlas

class Build072VisualAudio(unittest.TestCase):
    def test_original_music_tracks_are_embedded_and_valid(self):
        for name in ('hearth_night_intake','sootworks_service_debt','basilica_submerged_choir','pressure_breach_combat'):
            path=ROOT/'assets/music'/f'{name}.ogg'
            self.assertTrue(path.is_file(),name)
            self.assertGreater(path.stat().st_size,90000)
            self.assertEqual(path.read_bytes()[:4],b'OggS')
            if shutil.which('ffprobe'):
                proc=subprocess.run(['ffprobe','-v','error','-show_entries','format=duration','-of','default=nokey=1:noprint_wrappers=1',str(path)],capture_output=True,text=True,check=True)
                self.assertGreater(float(proc.stdout.strip()),10.0)
    def test_music_autoload_and_enemies_only(self):
        project=(ROOT/'project.godot').read_text()
        s=(ROOT/'scripts/adaptive_music_072.gd').read_text()
        self.assertIn('Music="*res://scripts/adaptive_music_072.gd"',project)
        for code in ('func _combat_threat_nearby() -> bool:','get_nodes_in_group("hostile")','if hp <= 0: continue','var is_fighting: bool','if is_fighting and distance <= COMBAT_ENGAGE_DISTANCE','combat_hold = CALM_DELAY','CROSSFADE_TIME','muted','func toggle_mute()'):
            self.assertIn(code,s)
        self.assertIn('    listener = target',s)
        self.assertIn('Music.set_listener(player)',(ROOT/'scripts/main.gd').read_text())
        self.assertIn('Music.set_listener(null)',(ROOT/'scripts/main.gd').read_text())
        self.assertIn('KEY_F10',(ROOT/'scripts/player.gd').read_text())
        self.assertIn('KEY_F10',(ROOT/'scripts/start_screen.gd').read_text())
    def test_generations_have_all_real_ids_and_nonempty_provenance(self):
        items=json.loads((ROOT/'art/RUNWAY_072_SOURCE_REQUESTS.json').read_text())
        self.assertEqual(len(items),22)
        ids=[v['new_task_id'] for v in items.values()]
        self.assertEqual(len(set(ids)),22)
        self.assertTrue(all(v['reference_task_id'] and v['description'] for v in items.values()))
        music=json.loads((ROOT/'art/RUNWAY_072_MUSIC_TASKS.json').read_text())
        self.assertEqual(len(music['Runway_generated_original_tracks']),4)
        self.assertIn('NOT Runway exports',music['asset_status'])
    def test_all_8_direction_enemy_and_npc_atlases_remain(self):
        manifest=json.loads((ROOT/'art/EIGHT_VIEW_ASSET_MANIFEST_071.json').read_text())
        self.assertEqual(manifest['enemy_atlas_count'],136)
        for key in manifest['enemy_ids']:
            for direction in range(1,9):
                path=ROOT/'assets/sprites/enemies_074'/f'{key}_{direction}.png'  # 09.1: 07.1 removed
                self.assertTrue(path.is_file(),str(path))
                with Image.open(path) as im:self.assertEqual(im.size,(768,768))
        for key in ['sela','brin','ossa','oren','clerk']:
            for direction in range(1,9):
                path=ROOT/'assets/sprites/npc_idle_072'/f'{key}_{direction}.png'
                self.assertTrue(path.is_file(),str(path))
                with Image.open(path) as im:self.assertEqual(im.size,(768,280))
    def test_character_angle_import_and_matte_key(self):
        from tempfile import TemporaryDirectory
        with TemporaryDirectory() as temp:
            t=Path(temp)/'sample.png'
            img=Image.new('RGB',(512,256),(255,0,255))
            d=ImageDraw.Draw(img)
            for k in range(8):
                x=(k%4)*128;y=(k//4)*128
                d.rectangle((x+34,y+24,x+94,y+120),fill=(95,117,73))
            img.save(t)
            poses=split_sheet(t,(192,256))
            self.assertEqual(len(poses),8)
            self.assertTrue(all(im.size==(192,256) for im in poses))
            self.assertTrue(all(im.getpixel((0,0))[3]==0 for im in poses))
            self.assertTrue(all(im.getchannel('A').getbbox() for im in poses))
            atlas=make_enemy_atlas(poses[0])
            self.assertEqual(atlas.size,(768,768))
            self.assertNotEqual(atlas.crop((0,0,192,256)).tobytes(),atlas.crop((192,0,384,256)).tobytes())
    def test_npc_idle_frames_moving_without_foot_hopping(self):
        with Image.open(ROOT/'assets/sprites/npc_idle_072/sela_1.png') as img:
            f0=img.crop((0,0,192,280))
            f1=img.crop((192,0,384,280))
            self.assertNotEqual(f0.tobytes(),f1.tobytes())
            self.assertEqual(f0.crop((0,200,192,280)).tobytes(),f1.crop((0,200,192,280)).tobytes())
    def test_unchanged_canonical_quest_and_hearing_data(self):
        code=(ROOT/'scripts/run_state.gd').read_text()
        for key in ['qobj_writ_of_labour','qobj_writ_of_faith','Rootkin','cipher']:
            self.assertIn(key,code)
        self.assertIn('scripts/adaptive_music_072.gd',(ROOT/'project.godot').read_text())

if __name__=='__main__':unittest.main()
