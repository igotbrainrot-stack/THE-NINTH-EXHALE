"""Build 07.5 regression contracts. Source and authored clearance only;
Godot import, physics and play feel still need an actual engine run.
"""
from pathlib import Path
import unittest,sys,struct
from PIL import Image,ImageChops
ROOT=Path(__file__).resolve().parents[1]
def src(name):return (ROOT/name).read_text()
class Ashmarket075(unittest.TestCase):
    def test_physical_third_district_is_not_an_empty_menu(self):
        world=src('scripts/ashmarket_builder.gd');main=src('scripts/main.gd')
        for landmark in ['Market stone floor','North ledger partition','South ledger partition','Collector desk','Trade Writ registry','Buyers\' speaker shelf','Tenant cistern body']:
            self.assertIn(landmark,world)
        self.assertIn('AshmarketBuilder.new()',main)
        self.assertIn('const AshmarketBuilder',main)
        self.assertIn('func ashmarket_interaction(interaction_id: String)',main)
        self.assertIn('"ashmarket_transfer"',world if '"ashmarket_transfer"' in world else main)

    def test_three_routes_plus_intimidation_and_no_deadlock(self):
        rules=src('scripts/run_state.gd')
        relevant=rules.split('func grant_trade_writ(method: String) -> bool:')[1].split('func record_market_rain_reading')[0]
        for route in ['"coalition"','"sabotage"','"intimidation"','"registry"']:
            self.assertIn(route,relevant)
        self.assertIn('bool(state["trade"]["collector_defeated"])',relevant)
        self.assertIn('bool(state["trade"]["counting_lock_isolated"])',relevant)
        self.assertIn('coalition_check()',relevant)
        self.assertIn('qobj_writ_of_trade',relevant)
        self.assertIn('if not _in_ashmarket() or state["writs"].has("qobj_writ_of_trade")',relevant)

    def test_skill_checks_have_accessible_preset_routes(self):
        rules=src('scripts/run_state.gd')
        self.assertIn('"Mechanist": {"Force":2,"Reflex":2,"Insight":3,"Speech":2,"Tech":6',rules)
        self.assertIn('"Breaker": {"Force":6',rules)
        self.assertIn('for level_mark in [3,5]',rules)
        self.assertIn('func choose_attribute_075(stat_name: String) -> bool:',rules)
        self.assertIn('state["unspent_attribute_points"] = int(state["unspent_attribute_points"])-1',rules)
        self.assertIn('if int(state["unspent_attribute_points"]) <= 0',rules)
        main=src('scripts/main.gd')
        self.assertIn('attribute:',main)
        self.assertIn('"Speech"',main)

    def test_trade_evidence_is_independent_and_persistent(self):
        rules=src('scripts/run_state.gd')
        for event in ['ashmarket.duplicate_contracts','ashmarket.independent_buyers','ashmarket.buyers_coalition','ashmarket.trade_writ.transferred','ashmarket.counting_lock_isolated','ashmarket.collector_intimidated']:
            self.assertIn(event,rules)
        self.assertIn('if not bool(state["trade"]["duplicate_contracts"]) or not bool(state["trade"]["buyer_testimony"])',rules)
        self.assertIn('state["trade"]["coalition_recorded"] = true',rules)
        self.assertIn('state["trade"]["method"] = method',rules)

    def test_three_writ_quorum_is_real_and_not_an_ending(self):
        rules=src('scripts/run_state.gd');world=src('scripts/world_builder.gd');main=src('scripts/main.gd')
        gate=rules.split('func can_register_three_writ_quorum() -> bool:')[1].split('func register_three_writ_quorum()')[0]
        for key in ['"lung"','"hearing"','founding_writs_recorded_077().size() >= 3']:
            self.assertIn(key,gate)
        for key in ['qobj_writ_of_labour','qobj_writ_of_faith','qobj_writ_of_trade','qobj_writ_of_growth','qobj_writ_of_defence']:
            self.assertIn(key,rules)
        self.assertIn('"campaign_complete":false',rules)
        self.assertIn('quorum_audit_desk',world)
        self.assertIn('"trade:quorum_audit"',main)
        self.assertIn('"core:enter"',main)
        self.assertIn('"core_custodian_docket"',main)
        self.assertIn('No canonical ending has been selected',main)
        self.assertIn('"not_full_game":true',rules)

    def test_old_saves_migrate_without_replacing_other_writs(self):
        rules=src('scripts/run_state.gd')
        self.assertIn('    ensure_build075_state()',rules)
        self.assertIn('if not state.has("trade"):',rules)
        self.assertIn('if not state["zone_positions"].has("ashmarket")',rules)
        self.assertIn('if not state["actors"].has("collector")',rules)
        self.assertIn('if not state["relationships"].has("Trade")',rules)
        self.assertIn('"zone_selection"',rules)
        self.assertIn('"hearing"',rules)

    def test_market_water_is_finite_and_has_costs(self):
        rules=src('scripts/run_state.gd')
        s=rules.split('func resolve_market_rain(outcome: String) -> bool:')[1].split('func claim_market_emergency_lot')[0]
        self.assertIn('str(state["trade"]["rain_claim"]) != ""',s)
        self.assertIn('"open_tank"',s)
        self.assertIn('"take_cut"',s)
        self.assertIn('state["resources"]["Labour"] = int(state["resources"]["Labour"])-2',s)
        self.assertIn('state["resources"]["Energy"] = int(state["resources"]["Energy"])-1',s)
        self.assertNotIn('"Air"] = int(',s)
        self.assertIn('award_xp_once("ashmarket.price_of_rain",25)',s)

    def test_finite_supplies_one_only(self):
        rules=src('scripts/run_state.gd')
        s=rules.split('func claim_market_emergency_lot() -> bool:')[1].split('func can_register_three_writ_quorum')[0]
        self.assertIn('bool(state["trade"]["supplies_claimed"])',s)
        self.assertIn('ashmarket.one_public_defence_lot',s)
        self.assertIn('mini(120,int(state["spare_ammo"])+18)',s)

    def test_ashmarket_passable_in_approximate_geometry(self):
        from test_066_navigation_approx import obstacles,reachable
        obs=obstacles('ashmarket_builder.gd')
        goals={'archive':(-20,-12),'witnesses':(-20,6),'coalition':(-18,14),'counting lock':(18,-8),'collector':(14,4),'registry':(20,14),'cistern':(-6,-17),'water hearing':(-6,-11),'return':(-22,19)}
        result=reachable(obs,(-21,9),goals,(-25,25,-21,21))
        self.assertTrue(all(result.values()),result)

    def test_travel_reaches_third_zone_from_all_playable_districts(self):
        hearth=src('scripts/main.gd');soot=src('scripts/sootworks_builder.gd');faith=src('scripts/basilica_builder.gd');rules=src('scripts/run_state.gd')
        self.assertIn('"action":"travel:ashmarket"',hearth)
        self.assertIn('"ashmarket_transfer"',soot)
        self.assertIn('"ashmarket_transfer"',faith)
        self.assertIn('"ashmarket"',rules.split('func change_zone')[1].split('func meet_brin')[0])

    def test_collector_uses_real_distinct_eight_direction_atlases(self):
        d=ROOT/'assets/sprites/enemies_075';images=[]
        for angle in range(1,9):
            path=d/f'collector_{angle}.png'
            with Image.open(path) as im:
                self.assertEqual(im.size,(768,768))
                self.assertEqual(im.mode,'RGBA')
                im.load()
                images.append(im.copy())
        for x in range(8):
            for y in range(x+1,8):
                self.assertIsNotNone(ImageChops.difference(images[x],images[y]).getbbox(),f'duplicate {x+1} vs {y+1}')
        self.assertIn('enemies_075/collector_',src('scripts/enemy.gd'))

    def test_new_materials_and_original_district_music_present(self):
        for k in ['ashmarket_floor_075','ashmarket_ledger_wall_075','ashmarket_awning_075']:
            with Image.open(ROOT/f'assets/textures/{k}.png') as im:
                self.assertEqual(im.size,(512,512))
        ogg=ROOT/'assets/music/ashmarket_bonded_hours.ogg'
        self.assertEqual(ogg.read_bytes()[:4],b'OggS')
        self.assertIn('"ashmarket": "res://assets/music/ashmarket_bonded_hours.ogg"',src('scripts/adaptive_music_072.gd'))

if __name__=='__main__':unittest.main(verbosity=2)
