"""Build 06.8 contracts: asset presence, stability and source-level gameplay guards.
No claim of a Godot runtime or human playtest is made by these tests.
"""
import json,unittest
from pathlib import Path
from PIL import Image,ImageChops
ROOT=Path(__file__).resolve().parents[1]
DATA=json.loads((ROOT/'data/enemy_roster_068.json').read_text())
IDS=[s['id'] for s in DATA['combat_enemies']]
SPECS={s['id']:s for s in DATA['combat_enemies']}
ATLAS=json.loads((ROOT/'art/ENEMY_ANIMATION_MANIFEST_068.json').read_text())

class EnemyEcology068(unittest.TestCase):
    def test_exact_five_old_and_ten_new(self):
        self.assertEqual(15,len(IDS));self.assertEqual(15,len(set(IDS)))
        self.assertEqual({'sentry','enforcer','millwright','cantor','edda_machine'},set(IDS[:5]))
        self.assertEqual(10,sum(e['rank']>0 for e in DATA['combat_enemies']))
        self.assertEqual({'hearth','sootworks','basilica','lift'}, {e['zone'] for e in DATA['combat_enemies']})
    def test_origins_are_runway_generated_and_traceable(self):
        self.assertEqual(17,len(set([e['runway_task_id'] for e in DATA['combat_enemies']]+list(DATA['runway_hearing_tasks'].values()))))
        self.assertEqual(sum(1 for entry in ATLAS['art'] if entry['runway_source_path'] is not None),ATLAS['runway_raw_embedded_count'])
        self.assertIn('interim',ATLAS['claim'])
    def test_distinct_combat_profiles(self):
        self.assertGreaterEqual(len({e['attack'] for e in DATA['combat_enemies']}),4)
        self.assertGreaterEqual(len({e['move'] for e in DATA['combat_enemies']}),7)
        self.assertEqual(32,SPECS['sentry']['hp']);self.assertEqual(4,SPECS['sentry']['damage'])
        self.assertEqual(125,SPECS['millwright']['hp']);self.assertEqual(125,SPECS['cantor']['hp'])
        self.assertEqual(90,SPECS['edda_machine']['hp'])
        self.assertEqual(0,SPECS['vent_whistler']['speed'])
        self.assertTrue(SPECS['registry_bailiff']['move']=='shield')
    def test_all_seventeen_have_directional_12_frame_runtime_atlases(self):
        self.assertEqual(17,len(ATLAS['art']))
        # 09.1: the 06.8 atlases were removed; every actor's 07.4 atlas set
        # (eight views) carries the same 4x3 frame layout.
        for entry in ATLAS['art']:
            self.assertEqual(4,len(entry['atlas_files']))
            for view in range(1,9):
                with Image.open(ROOT/'assets/sprites/enemies_074'/f"{entry['id']}_{view}.png") as im:
                    self.assertEqual((4*192,3*256),im.size)
                    self.assertEqual('RGBA',im.mode)
                    self.assertEqual((0,0,0,0),im.getpixel((767,0)))
    def test_frames_not_static_fakes(self):
        # 09.1: checked on the 07.4 atlases every actor now uses as fallback.
        # Their 12 cells are not all distinct (two hold poses repeat), but an
        # atlas must never be a static fake: at least 10 distinct cells and two
        # different walk frames.
        for name in IDS+['bell_wretch','rootkin']:
            for view in range(1,9):
                im=Image.open(ROOT/'assets/sprites/enemies_074'/f'{name}_{view}.png').convert('RGBA')
                cells=[im.crop(((i%4)*192,(i//4)*256,(i%4+1)*192,(i//4+1)*256)) for i in range(12)]
                self.assertGreaterEqual(len({c.tobytes() for c in cells}),10,(name,view))
                self.assertIsNotNone(ImageChops.difference(cells[0],cells[1]).getbbox(),(name,view))
    def test_generated_cells_share_fixed_canvas_and_baseline(self):
        # 09.1: the 06.8 generator put every foot on row 243; the 07.4 atlases
        # bob and fall, so the rule is a grounded band: every cell has art and
        # its lowest pixel sits in the bottom 6 rows of the 256 px cell.
        for entry in ATLAS['art']:
            for view in range(1,9):
                im=Image.open(ROOT/'assets/sprites/enemies_074'/f"{entry['id']}_{view}.png")
                for i in range(12):
                    bbox=im.crop(((i%4)*192,(i//4)*256,(i%4+1)*192,(i//4+1)*256)).getchannel('A').getbbox()
                    self.assertIsNotNone(bbox,entry['id'])
                    self.assertGreaterEqual(bbox[3],250,(entry['id'],view,i,bbox))
    def test_title_enemy_gallery_is_working_and_does_not_mutate_campaign(self):
        title=(ROOT/'scenes/main.tscn').read_text()
        start=(ROOT/'scripts/start_screen.gd').read_text()
        gallery=(ROOT/'scripts/enemy_gallery_068.gd').read_text()
        self.assertIn('EnemyGalleryButton',title)
        self.assertIn('enemy_gallery_068.tscn',start)
        for action in ('KEY_LEFT','KEY_RIGHT','KEY_UP','KEY_DOWN','KEY_SPACE','KEY_ESCAPE'):
            self.assertIn(action,gallery)
        self.assertIn('AtlasTexture.new()',gallery)
        self.assertNotIn('Game.state[',gallery)
        self.assertNotIn('award_xp_once',gallery)

    def test_optional_foes_no_xp_farms_or_writ_shortcut(self):
        main=(ROOT/'scripts/main.gd').read_text()
        span=main.split('func _additional_enemy_defeated',1)[1].split('func _populate_living_wards',1)[0]
        self.assertIn('Game.record_event("combat.068.%s" % key',span)
        self.assertIn('Game.state["actors"][key]["alive"] = false',span)
        self.assertIn('Game.save_attempt()',span)
        self.assertNotIn('award_xp',span)
        self.assertNotIn('writs',span)
    def test_intro_remains_one_enemy_until_shutter_opens(self):
        code=(ROOT/'scripts/main.gd').read_text()
        self.assertIn('Game.intro_stage() in ["unwoken","alarm","cleared"]',code)
        self.assertIn('if additional_enemies.is_empty(): _spawn_additional_enemies_068()',code)
    def test_save_migration_and_seed_repeatability(self):
        state=(ROOT/'scripts/run_state.gd').read_text()
        self.assertIn('func ensure_enemy_roster_068_state()',state)
        self.assertIn('"zone_selection"',state)
        self.assertIn('"alive":true',state)
        self.assertIn('var offset: int = abs(seed) % candidates.size()',state)
        self.assertIn('if saved.has(zone): return saved[zone]',state)
        self.assertNotIn('randi()',state.split('func selected_enemy_068',1)[1])
    def test_not_boss_replacement_and_hearing_no_collection(self):
        main=(ROOT/'scripts/main.gd').read_text()
        for original in ('spawn_guard','spawn_intro_sentry','_guard_defeated','_intro_sentry_defeated'):
            self.assertIn('func '+original+'(',main)
        bas=(ROOT/'scripts/basilica_builder.gd').read_text()
        self.assertIn('AnimatedEchoform068',bas)
        self.assertIn('PUBLIC ROOTKIN / LOANER',bas)
        self.assertIn('BELL WRETCH / FIELD OPPOSITION',bas)

if __name__=='__main__': unittest.main()
