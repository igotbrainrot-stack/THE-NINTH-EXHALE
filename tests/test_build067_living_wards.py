"""Build 06.7 source and independent state-machine contracts.
These tests do NOT replace a Godot physics or human-fun playtest.
"""
import unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def read(name):
    return (ROOT / name).read_text(encoding='utf-8')

class LivingWards067(unittest.TestCase):
    def test_crawler_commits_to_direction_before_rush(self):
        s=read('scripts/enemy.gd')
        self.assertIn('rush_direction = (player.global_position-global_position).normalized()',s)
        self.assertIn('travel = rush_direction * move_speed',s)
        self.assertLess(s.index('rush_direction = (player.global_position'),s.index('travel = rush_direction'))
        self.assertIn('if rush_hit_ready and distance < role_reach',s)
    def test_keeper_repositions_without_telegraph_cancellation(self):
        s=read('scripts/enemy.gd')
        self.assertIn('not hold and role_move in ["boss","skirmish","flanker"]',s)
        self.assertIn('attack_sequence + int(Game.state["world_plan"]',s)
        self.assertIn('var tangent := Vector3(-toward.z,0.0,toward.x)',s)
    def test_pressure_fixture_weapon_and_melee_damage(self):
        s=read('scripts/pressure_fixture.gd')
        self.assertIn('extends StaticBody3D',s)
        self.assertIn('collision_layer = 4',s)
        self.assertIn('func take_hit(damage: int)',s)
        self.assertIn('if spent or not Game.has_attempt(): return',s)
        self.assertIn('burst.emit(fixture_id, global_position)',s)
        self.assertIn('collision_layer = 0',s)
        self.assertIn('query.collision_mask = 5',read('scripts/player.gd'))
    def test_three_stored_pressure_sources(self):
        r=read('scripts/run_state.gd');m=read('scripts/main.gd')
        for k in ('sootworks_stack','basilica_receiver','lift_regulator'):
            self.assertIn('"'+k+'"',r)
            self.assertIn('"'+k+'"',m)
        self.assertIn('if bool(state["pressure_067"].get(key,false)): return false',r)
        self.assertIn('if not record_event(event_id,"finite_pressure_discharge"',r)
        self.assertIn('state["pressure_067"][key] = true',r)
    def test_pressure_energy_is_finite_and_not_free_air(self):
        s=read('scripts/run_state.gd').split('func vent_pressure_fixture',1)[1].split('func meet_ossa',1)[0]
        self.assertIn('maxi(0,int(state["resources"].get("Energy",0))-spent)',s)
        self.assertIn('"Air":0,"Correction":0',s)
        self.assertNotIn('award_xp_once',s)
        self.assertNotIn('state["health"]',s)
        self.assertNotIn('spare_ammo',s)
        self.assertIn('save_attempt()',s)
    def test_fixture_works_only_in_its_owner_zone(self):
        s=read('scripts/run_state.gd').split('func vent_pressure_fixture',1)[1].split('func meet_ossa',1)[0]
        self.assertIn('str(state.get("zone","")) != str(zone_for[key])',s)
    def test_pressure_discharge_interrupts_only_nearby_enemy(self):
        s=read('scripts/main.gd').split('func _on_pressure_fixture_burst',1)[1].split('func _nav_target',1)[0]
        self.assertIn('distance <= 8.0',s)
        self.assertIn('guard.apply_environmental_stagger(2.8)',s)
        self.assertIn('if distance <= 4.5: guard.take_hit(10)',s)
        self.assertIn('valve_steam.wav',s)
    def test_nav_is_advisory_from_real_authored_positions(self):
        s=read('scripts/main.gd')
        for x in ('REPRINT RELAY','MANUAL VALVE','DR SELA','RESERVE LUNG','PAYROLL CYLINDER','ROOTKIN HEARING','EDDA TRIAL RECORD'):
            self.assertIn('"'+x+'"',s)
        self.assertIn('set_navigation(',s)
        self.assertIn('forward.signed_angle_to(direction.normalized(),Vector3.UP)',s)
    def test_nav_ui_is_nonblocking(self):
        s=read('scripts/game_ui.gd')
        self.assertIn('navigation.mouse_filter=Control.MOUSE_FILTER_IGNORE',s)
        self.assertIn('func set_navigation(label_text: String)',s)
        self.assertIn('navigation.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT',s)
    def test_rotors_are_meshes_not_furniture_billboards(self):
        s=read('scripts/ambient_machinery.gd')
        self.assertIn('extends Node3D',s)
        self.assertIn('var rotor := Node3D.new()',s)
        self.assertIn('blade.mesh = box',s)
        self.assertNotIn('BILLBOARD_ENABLED',s)
        self.assertIn('rotor.rotation.z += delta',s)
    def test_save_migration_is_additive(self):
        s=read('scripts/run_state.gd')
        self.assertIn('if not state.has("pressure_067")',s)
        self.assertIn('if not state["pressure_067"].has(key)',s)
        for old in ('"hearth.lung_installed"','"sootworks.labour_writ.transferred"','"basilica.civic_hearing"'):
            self.assertIn(old,s)
    def test_side_passage_discoveries_occupied_by_actual_consoles(self):
        soot=read('scripts/sootworks_builder.gd')
        bas=read('scripts/basilica_builder.gd')
        self.assertIn('"sootworks_relief", Vector3(6.7,0,-14.7)',soot)
        self.assertIn('"basilica_notes", Vector3(7.7,0,-15.4)',bas)
        main=read('scripts/main.gd')
        self.assertIn('if interaction_id in ["sootworks_relief","basilica_notes"]',main)
    def test_once_only_relief_does_not_generate_medical_items_infinitely(self):
        s=read('scripts/run_state.gd').split('func claim_discovery',1)[1].split('func meet_ossa',1)[0]
        self.assertIn('if bool(state["discovery_067"].get(key,false)): return false',s)
        self.assertIn('if not record_event(event_id,"physical_side_discovery"',s)
        self.assertIn('state["discovery_067"][key] = true',s)
        self.assertIn('"Breath Ampoule"] = int(stock.get("Breath Ampoule",0)) + 1',s)
        self.assertNotIn('award_xp_once',s)
    def test_choir_notes_inform_hearing_without_creature_ownership(self):
        s=read('scripts/run_state.gd')
        self.assertIn('or bool(state.get("discovery_067",{}).get("basilica_notes",false))',s)
        self.assertIn('state["hearing"]["familiarity"]',s)
        self.assertIn('"participant"] = "Rootkin"',s)
        self.assertIn('"accord_type"] = "loaner"',s)
    def test_optional_paths_reachable_in_planar_approximation(self):
        # An authored geometry clearance oracle, NOT an engine collision test.
        from test_066_navigation_approx import obstacles,reachable
        soot=reachable(obstacles('sootworks_builder.gd'),(-19,8),{'wage cache':(6.7,-14.7)},(-23,23,-22,22))
        bas=reachable(obstacles('basilica_builder.gd'),(-20,8),{'choir source':(7.7,-15.4)},(-25,25,-23,23))
        self.assertTrue(all(soot.values()),soot)
        self.assertTrue(all(bas.values()),bas)
    def test_procedural_original_vessel_material_has_source_generator(self):
        from PIL import Image
        with Image.open(ROOT/'assets/textures/pressure_vessel_067.png') as im:
            self.assertEqual(im.size,(256,256))
        self.assertIn('random.Random(670017)',read('art/tools/generate_pressure_texture_067.py'))
        self.assertIn('pressure_vessel_067.png',read('scripts/pressure_fixture.gd'))
    def test_no_resurrect_npcs_or_new_fake_finale(self):
        main=read('scripts/main.gd')
        self.assertIn('two-Writ DEVELOPMENT slice'.lower(),main.lower())
        self.assertNotIn('full five district campaign complete',main.lower())

if __name__=='__main__': unittest.main()
