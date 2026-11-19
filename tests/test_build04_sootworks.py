#!/usr/bin/env python3
"""Source and content-contract regression, not a Godot runtime test."""
import re,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

class SootworksSourceContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.main=(ROOT/'scripts/main.gd').read_text()
        cls.state=(ROOT/'scripts/run_state.gd').read_text()
        cls.world=(ROOT/'scripts/sootworks_builder.gd').read_text()
        cls.npc=(ROOT/'scripts/brin_actor.gd').read_text()
        cls.enemy=(ROOT/'scripts/enemy.gd').read_text()
        cls.bible=(ROOT/'docs/MASTER_GAME_BIBLE_FINAL.md').read_text()

    def test_distinct_real_sector_and_collision(self):
        self.assertIn('extends "res://scripts/world_builder.gd"',self.world)
        self.assertIn('solid_box("Sootworks floor"',self.world)
        self.assertIn('solid_box("North furnace wall"',self.world)
        self.assertIn('world = SootworksBuilder.new()',self.main)
        self.assertIn('reload_district_world()',self.main)

    def test_every_sootworks_console_has_interaction_case(self):
        # Map routes to real physical consoles rather than menu-only missions.
        ids=set(re.findall(r'add_console\([^\n]*?,\s*"([a-z_]+)",\s*Vector3',self.world))
        self.assertGreaterEqual(len(ids),7,ids)
        ids.add("labour_clerk")
        ids.add("brin")
        for ident in ids:
            self.assertTrue(('"'+ident+'":') in self.main or ('if interaction_id == "'+ident+'"') in self.main,ident)

    def test_brin_four_stage_order_and_actual_evidence(self):
        for key in ['meet_brin','record_payroll','investigate_brin','decide_brin','complete_brin_aftermath','kill_brin']:
            self.assertIn('func '+key+'(',self.state)
        self.assertIn('cleared_debt_years_ago":43',self.state)
        self.assertIn('"unmet"',self.state)
        self.assertIn('"encountered"',self.state)
        self.assertIn('"investigated"',self.state)
        self.assertIn('"decision"',self.state)
        self.assertIn('"consequence"',self.state)
        self.assertIn('"dead"',self.state)
        self.assertIn('"decision":""',self.state)
        self.assertIn('not bool(state["brin"]["alive"])',self.state)
        self.assertIn('Game.kill_brin()',self.npc)

    def test_labour_writ_unique_and_recoverable_after_keeper_death(self):
        self.assertIn('"qobj_writ_of_labour"',self.state)
        self.assertIn('if state["writs"].has("qobj_writ_of_labour")',self.state)
        for route in ['council','sabotage','registry']:
            self.assertIn('method == "'+route+'"',self.state)
            self.assertIn('writ:'+route,self.main)
        self.assertIn('state["labour"]["millwright_defeated"]',self.state)
        self.assertIn('record_event("sootworks.labour_writ.transferred"',self.state)
        self.assertIn('award_xp_once("writ.sootworks.labour",165)',self.state)
        self.assertIn('full game',self.bible.lower())

    def test_millwright_enemy_state_does_not_overwrite_hearth_guard(self):
        self.assertIn('var actor_key: String = "enforcer"',self.enemy)
        self.assertIn('actor_key',self.main)
        self.assertIn('"millwright":{"hp":125',self.state)
        self.assertIn('Game.state["actors"][actor_key]',self.enemy)

    def test_tradeoffs_and_one_time_supply(self):
        self.assertIn('"Brin\'s Torque"',self.state)
        self.assertIn('"Union Rivet Kit"',self.state)
        self.assertIn('"Chain of Wages"',self.state)
        self.assertIn('"Labour":-2,"Air":0',self.state)
        self.assertIn('"sootworks.emergency_supplies"',self.state)
        self.assertIn('"sootworks.brin.decision"',self.state)
        self.assertIn('"sootworks.regulator.isolated"',self.state)

    def test_save_load_resumes_zone_and_older_build03_save(self):
        self.assertIn('func ensure_build04_state()',self.state)
        self.assertIn('    ensure_build04_state()',self.state)
        self.assertIn('"zone_positions"',self.state)
        self.assertIn('Game.state["zone_positions"]', (ROOT/'scripts/player.gd').read_text())
        self.assertIn('reload_district_world()',self.main)
        self.assertIn('    save_attempt()',self.state)

if __name__=='__main__':unittest.main(verbosity=2)
