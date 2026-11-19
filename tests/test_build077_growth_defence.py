"""Build 07.7 structural/data/geometry regression. NOT a live Godot playtest."""
import json, unittest, subprocess
from pathlib import Path
from PIL import Image, ImageChops
from test_066_navigation_approx import obstacles, reachable

ROOT=Path(__file__).resolve().parents[1]

def source(path): return (ROOT/path).read_text()

class Build077Offices(unittest.TestCase):
    def test_two_physical_founding_offices_are_built_and_routed(self):
        main=source('scripts/main.gd');state=source('scripts/run_state.gd')
        for builder,zone in [('orchard_builder_077.gd','orchard'),('barracks_builder_077.gd','barracks')]:
            self.assertTrue((ROOT/'scripts'/builder).exists())
            self.assertIn('"'+zone+'"',main)
            self.assertIn('"'+zone+'"',state)
            self.assertIn('res://scripts/'+builder,main)
            self.assertIn('add_console(',source('scripts/'+builder))
        for label in ['TRAVEL TO GLASS ORCHARD','TRAVEL TO QUIET BARRACKS']:
            self.assertIn(label,main)

    def test_growth_public_and_technical_and_defeat_paths(self):
        state=source('scripts/run_state.gd');main=source('scripts/main.gd')
        self.assertIn('func grant_growth_writ_077(method: String) -> bool:',state)
        for requirement in ['"researchers"','"isolation"','"registry"','sample_separated','researcher_vote','feed_line_isolated','gardener_defeated']:
            self.assertIn(requirement,state)
        self.assertIn('qobj_writ_of_growth',state)
        self.assertIn('mark_office_defeat_077("orchard")',main)

    def test_defence_noncombat_preserves_staffed_guard(self):
        state=source('scripts/run_state.gd')
        self.assertIn('func grant_defence_writ_077(method: String) -> bool:',state)
        self.assertIn('not bool(state["defence"]["guard_roster"])',state)
        self.assertIn('if not bool(state["defence"]["casualty_roll"]) or not bool(state["defence"]["guard_roster"])',state)
        self.assertIn('"source":"human guard detail and conventional electricity"',state)
        self.assertIn('qobj_writ_of_defence',state)
        self.assertIn('regional_keeper_person_killed":false',state)

    def test_quorum_uses_any_three_unique_founder_documents(self):
        state=source('scripts/run_state.gd')
        gate=state.split('func can_register_three_writ_quorum() -> bool:',1)[1].split('func register_three_writ_quorum()',1)[0]
        self.assertIn('founding_writs_recorded_077().size() >= 3',gate)
        self.assertIn('"hearing"',gate)
        self.assertIn('"lung"',gate)
        group=state.split('const FOUNDING_WRIT_IDS:',1)[1].split('func founding_writs_recorded_077()',1)[0]
        for suffix in ['labour','faith','trade','growth','defence']:
            self.assertIn('"qobj_writ_of_'+suffix+'"',group)
        self.assertIn('not originals.has(id)',state)
        self.assertIn('"physical_writs":originals.slice(0,3)',state)
        self.assertIn('"campaign_complete":false',state)

    def test_npc_arcs_are_actual_five_beat_recordings_with_one_decision(self):
        state=source('scripts/run_state.gd')
        self.assertIn('func arc_event_077(person: String, step: String, choice: String = "") -> bool:',state)
        for step in ['"meet"','"evidence"','"investigate"','"decide"','"aftermath"']:
            self.assertIn(step,state)
        self.assertIn('not bool(arc["alive"])',state)
        self.assertIn('str(arc["decision"]) != ""',state)
        self.assertIn('original forged warrant; no prior player killing asserted',state)
        self.assertNotIn('state["ending"] = ',state.split('func arc_event_077(',1)[1].split('func claim_restoration_clue_077(',1)[0])

    def test_unique_clues_not_free_true_dawn_and_stable_ids(self):
        state=source('scripts/run_state.gd');data=source('data/master_ids.json')
        for id in ['qobj_orchard_root_seed','qobj_deep_heat_survey']:
            self.assertIn(id,state);self.assertIn(id,data)
        self.assertIn('"not_public_mandate":true',state)
        self.assertIn('if bool(state[group][flag]): return false',state)
        self.assertIn('if item == "orchard_root_seed" and not bool(state["growth"]["sample_separated"]): return false',state)
        self.assertIn('if item == "deep_heat_survey" and not bool(state["defence"]["casualty_roll"]): return false',state)

    def test_finite_supply_and_energy_ledger(self):
        state=source('scripts/run_state.gd')
        self.assertIn('if bool(state[group]["supplies_claimed"]): return false',state)
        self.assertIn('"Labour":-2',state)
        self.assertIn('"Energy":-2',state)
        self.assertIn('"Correction":0',state)

    def test_old_save_migration_adds_flags_in_place(self):
        state=source('scripts/run_state.gd')
        self.assertIn('    ensure_build077_state()',state)
        self.assertIn('if not state.has("growth")',state)
        self.assertIn('if not state.has("defence")',state)
        self.assertIn('if not state["zone_positions"].has(entry["zone"])',state)
        self.assertIn('ensure_build076_state()',state)
        self.assertIn('return has_attempt() and bool(state["lung"]',state)

    def test_writ_registers_physically_separate_from_holder(self):
        for district,controller in [('orchard','orchard_gardener'),('barracks','barracks_commandant')]:
            data=source(f'scripts/{district}_builder_077.gd')
            self.assertIn('"'+controller+'"',data)
            self.assertIn('"'+district+'_writ"',data)
            self.assertIn('"hearth_return"',data)

    def test_orchard_and_barracks_routes_clear_for_player(self):
        goals={
            'orchard_builder_077.gd':{'sample':(-20,-15),'researchers':(-20,11),'seed':(21,-16),'writ':(20,15),'return':(-23,20)},
            'barracks_builder_077.gd':{'roll':(-21,-15),'safety':(-21,7),'survey':(21,-18),'writ':(20,16),'return':(-23,20)}
        }
        for builder,targets in goals.items():
            check=reachable(obstacles(builder),(-22,8),targets,(-29,29,-22,22))
            self.assertTrue(all(check.values()),f'{builder}: {check}')

    def test_eight_distinct_actor_views_and_enemy_atlases(self):
        for name in ['venn','kest']:
            imgs=[Image.open(ROOT/f'assets/sprites/directional8/{name}_{i}.png').convert('RGBA') for i in range(1,9)]
            self.assertTrue(all(im.size == (192,280) for im in imgs))
            self.assertGreater(len({im.tobytes() for im in imgs}),4)
        for name in ['gardener','commandant']:
            imgs=[Image.open(ROOT/f'assets/sprites/enemies_077/{name}_{i}.png').convert('RGBA') for i in range(1,9)]
            self.assertTrue(all(im.size == (768,768) for im in imgs))
            self.assertEqual(len({im.tobytes() for im in imgs}),8)

    def test_original_textures_and_music_exist(self):
        for file in ['orchard_floor_077.png','orchard_glass_077.png','barracks_floor_077.png','barracks_wall_077.png']:
            with Image.open(ROOT/'assets/textures'/file) as im:self.assertEqual(im.size,(256,256))
        for file in ['orchard_wet_lattice_077.ogg','barracks_order_zero_077.ogg']:
            path=ROOT/'assets/music'/file
            self.assertTrue(path.exists() and path.stat().st_size>10000)
        self.assertTrue((ROOT/'art/BUILD_077_ASSET_MANIFEST.json').exists())

    def test_living_npc_positions_follow_saved_decision(self):
        orchard=source('scripts/orchard_builder_077.gd')
        barracks=source('scripts/barracks_builder_077.gd')
        main=source('scripts/main.gd')
        self.assertIn('if venn_choice == "abandon":',orchard)
        self.assertIn('elif venn_choice == "help":',orchard)
        self.assertIn('if kest_choice == "abandon":',barracks)
        self.assertIn('elif kest_choice == "help":',barracks)
        self.assertIn('actor_node.queue_free()',main)
        self.assertIn('actor_node.position = Vector3(-15,0,15)',main)
        self.assertIn('"VennOfGlass"',orchard)
        self.assertIn('"Kest07"',barracks)

    def test_fixed_rail_not_new_canonical_ending(self):
        state=source('scripts/run_state.gd')
        self.assertIn('can_enter_slice_lift()',state)
        self.assertIn('visit_core_076()',state)
        self.assertIn('slice_mode',state)
        self.assertIn('No canonical ending has been selected',source('scripts/main.gd'))

if __name__=='__main__':unittest.main(verbosity=2)
