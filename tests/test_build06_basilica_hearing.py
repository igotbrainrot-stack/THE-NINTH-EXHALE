"""Build 06 structural/source contracts; does not execute the Godot runtime."""
import json, re, unittest
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
class BasilicaAndHearingContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.scripts={p.stem:p.read_text() for p in (ROOT/'scripts').glob('*.gd')}
        cls.ids=json.loads((ROOT/'data/master_ids.json').read_text())
        cls.main=cls.scripts['main'];cls.rules=cls.scripts['run_state'];cls.builder=cls.scripts['basilica_builder']

    def test_third_world_builder_and_both_transfers(self):
        self.assertIn('const BasilicaBuilder = preload',self.main)
        self.assertIn('world = BasilicaBuilder.new()',self.main)
        self.assertIn('"basilica"',self.rules)
        self.assertIn('"travel:basilica"',self.main)
        self.assertIn('"travel:hearth"',self.main)
        self.assertIn('"travel:sootworks"',self.main)

    def test_physical_sector_has_collision_and_walkable_hearing(self):
        self.assertIn('solid_box("Basilica foundations"',self.builder)
        self.assertIn('solid_box("North choir retaining wall"',self.builder)
        self.assertIn('solid_box("Lay partition N / upper"',self.builder)
        self.assertIn('solid_box("Lay partition N / lower"',self.builder)
        self.assertIn('solid_box("Lay public partition south"',self.builder)
        self.assertIn('"hearing_station"',self.builder)
        self.assertIn('_make_hearing_field()',self.builder)
        self.assertIn('"rootkin.png"',self.builder)
        self.assertIn('"bell_wretch.png"',self.builder)
        self.assertNotIn('capture_ball',self.builder)

    def test_every_basilica_interaction_has_a_case(self):
        ids=set(re.findall(r'add_(?:console|actor)\([^\n]*?"([a-z_]+)"\s*,\s*Vector3',self.builder))
        self.assertGreaterEqual(len(ids),10)
        for interaction in ids:
            self.assertTrue(('"'+interaction+'":') in self.main or ('if interaction_id == "'+interaction+'"') in self.main,interaction)

    def test_ossa_four_stages_and_refusal_to_posthumous_speech(self):
        for token in ['func meet_ossa','func investigate_ossa','func decide_ossa','func complete_ossa_aftermath','func kill_ossa']:
            self.assertIn(token,self.rules)
        for token in ['"unmet"','"encountered"','"investigated"','"decision"','"consequence"','"dead"']:
            self.assertIn(token,self.rules)
        self.assertIn('state["actors"]["ossa"]["alive"] = false',self.rules)
        self.assertIn('"basilica.ossa.death"',self.rules)
        self.assertIn('if not bool(ossa["alive"]):',self.main)
        self.assertIn('"Sister Ossa"',self.builder)

    def test_evidence_only_once_and_dialogue_order(self):
        for token in ['"basilica.hymn.original"', '"basilica.ossa.investigated"','"basilica.ossa.decision"','"basilica.ossa.aftermath"']:
            self.assertIn(token,self.rules)
        self.assertIn('bool(state["ossa"]["hymn_seen"])',self.rules)
        self.assertIn('str(state["ossa"]["stage"]) != "encountered"',self.rules)
        self.assertIn('award_xp_once("npc.ossa.arc",55)',self.rules)

    def test_faith_writ_succession_survives_keeper_death(self):
        self.assertEqual(self.ids['quest_objects']['Writ of Faith'],'qobj_writ_of_faith')
        for method in ['"council"','"sabotage"','"registry"']:
            self.assertIn('method == '+method,self.rules)
        self.assertIn('state["writs"].has("qobj_writ_of_faith")',self.rules)
        self.assertIn('bool(state["faith"]["cantor_defeated"])',self.rules)
        self.assertIn('"basilica.faith_writ.transferred"',self.rules)
        self.assertIn('award_xp_once("writ.basilica.faith",165)',self.rules)

    def test_faith_actions_have_finite_resource_cause(self):
        self.assertIn('"source":"isolated governor drive"',self.rules)
        self.assertIn('"source":"authorised lay council, signal isolation crew"',self.rules)
        self.assertIn('"Correction":-3',self.rules)
        self.assertIn('"Faith"] = -2',self.rules)
        self.assertIn('"Faith"] = 1',self.rules)

    def test_honor_hearing_five_canonical_commands_and_safe_exit(self):
        commands=set(re.findall(r'"action":"hearing:([A-Za-z]+)"',self.main)) - {'start'}
        self.assertEqual(commands,{'Press','Attune','Brace','Observe','Withdraw'})
        self.assertEqual(set(self.ids['hearing_commands']), commands)
        self.assertIn('"public loaner"',self.rules)
        self.assertIn('h["active"] = false',self.rules)
        self.assertIn('h["passed"] = true',self.rules)
        self.assertIn('hearing["transcript"].append',self.rules)
        self.assertIn('"basilica.civic_hearing",110',self.rules)
        self.assertNotIn('capture_reward',self.rules)

    def test_full_writ_quorum_not_replaced(self):
        self.assertIn('"slice_mode":true',self.rules)
        self.assertIn('"slice_featured"',self.rules)
        self.assertIn('"slice_hearing_district"',self.rules)
        self.assertIn('the full campaign still requires three separate office credentials',self.main)
        self.assertNotIn('"writs".size() >= 2',self.rules)

    def test_old_state_migration_and_position_persistence(self):
        self.assertIn('func ensure_build06_state()',self.rules)
        self.assertIn('ensure_build04_state()',self.rules)
        self.assertIn('    ensure_build06_state()\n    state_changed.emit()\n    return true',self.rules)
        self.assertIn('state["zone_positions"]["basilica"]',self.rules)
        self.assertIn('"zone":"hearth"',self.rules)
        self.assertIn('"basilica": zone_name = "Flood Basilica"',self.rules)

    def test_no_unearned_success_or_loot_on_retry(self):
        self.assertIn('if bool(state["hearing"]["passed"]) or bool(state["hearing"]["active"]):return false',self.rules)
        self.assertIn('if not record_event(event_id,',self.rules)
        self.assertIn('"hearing_command"',self.rules)
        self.assertIn('hearing["attempts"] = int(hearing["attempts"])+1',self.rules)
        self.assertIn('if bool(h["passed"]): award_xp_once("basilica.civic_hearing",110)',self.rules)

    def test_new_sprites_and_materials_are_valid(self):
        for name in ['ossa.png','rootkin.png','bell_wretch.png']:
            p=ROOT/'assets/sprites'/name
            self.assertTrue(p.is_file(),p)
            with Image.open(p) as img:
                self.assertEqual(img.mode,'RGBA');img.verify()
        for name in ['basilica_stone.png','basilica_copper.png','basilica_paper.png']:
            p=ROOT/'assets/textures'/name
            self.assertTrue(p.is_file(),p)
            with Image.open(p) as img:
                self.assertEqual(img.size,(256,256));img.verify()

if __name__=='__main__': unittest.main(verbosity=2)
