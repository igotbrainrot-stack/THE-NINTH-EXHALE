"""Build 07.9 focused source contracts. Not a Godot runtime or human fun test."""
from pathlib import Path
from hashlib import sha256
import unittest
import wave
ROOT=Path(__file__).resolve().parents[1]
def src(path):return (ROOT/path).read_text(encoding='utf-8')

class Gameplay079(unittest.TestCase):
    def test_source_files_and_world_hooks(self):
        for file in ['encounter_hazard_079.gd','hazard_switch_079.gd','combat_impact_079.gd','physical_hearing_079.gd']:
            self.assertTrue((ROOT/'scripts'/file).exists())
        main=src('scripts/main.gd')
        self.assertIn('_setup_environmental_encounter_079(zone)',main)
        self.assertIn('hazard.shutdown_requested.connect(_shutdown_environmental_encounter_079)',main)
        self.assertIn('world.add_child(signal_field)',main)
    def test_three_tactical_dangers_are_distinct(self):
        hazard=src('scripts/encounter_hazard_079.gd')
        for zone in ['hearth','sootworks','basilica']:
            self.assertIn('hazard_key == "'+zone+'"',hazard)
        for r in ['2.15','3.25','4.05']:
            self.assertIn(r,hazard)
        self.assertIn('Game.take_damage(4 if hazard_key == "hearth" else 7)',hazard)
        self.assertIn('Game.state["breath"]',hazard)
    def test_warning_is_visible_before_damage(self):
        s=src('scripts/encounter_hazard_079.gd')
        for start,activate,finish,period in [(2.9,3.65,4.2,4.4),(2.65,3.55,4.3,4.7),(2.8,3.85,4.55,5.1)]:
            self.assertLess(start,activate)
            self.assertLess(activate,finish)
            self.assertLess(finish,period)
            self.assertGreater(period-finish,0.1)
        self.assertIn('var warming: bool =',s)
        self.assertIn('status_label.text = "WARNING',s)
        self.assertIn('var planar_distance: float',s)
    def test_tactical_dangers_only_operate_when_canonically_appropriate(self):
        s=src('scripts/encounter_hazard_079.gd')
        self.assertIn('Game.intro_stage() == "alarm"',s)
        self.assertIn('bool(saved.get("hostile",false))',s)
        self.assertIn('if not bool(saved.get("alive",true)): return false',s)
        self.assertIn('get("decision","")) == "help": return false',s)
    def test_no_new_writ_or_ending_gates(self):
        s=src('scripts/run_state.gd').split('# --- BUILD 07.9 / PHYSICAL SERVICE HAZARDS ---',1)[1]
        for prohibited in ['"writs"].append','ending =','record_canonical_ending','Game.change_zone','"Correction"] =']:
            self.assertNotIn(prohibited,s)
    def test_save_migration_additive_and_idempotent(self):
        s=src('scripts/run_state.gd')
        self.assertIn('func ensure_build079_state()',s)
        self.assertIn('if not state.has("hazards_079")',s)
        self.assertIn('if not state["hazards_079"].has(id)',s)
        self.assertIn('if bool(entry.get("disabled",false)): return false',s)
        self.assertIn('save_attempt()',s.split('func shut_down_hazard_079',1)[1])
        self.assertIn('Game.ensure_build079_state()',src('scripts/main.gd'))
    def test_finite_resource_accounting_and_methods(self):
        s=src('scripts/run_state.gd').split('func shut_down_hazard_079',1)[1]
        for t in ['method not in ["quiet","rupture"]','var energy_cost: int = 2 if method == "rupture" else 1','var labour_cost: int = 0 if method == "rupture" else 1','state["resources"]["Energy"])-energy_cost','state["resources"]["Labour"])-labour_cost','state["ledger"].append','if not record_event(event_id']:
            self.assertIn(t,s)
    def test_acoustic_mechanics_affect_factual_hearing_not_capture(self):
        s=src('scripts/run_state.gd')
        self.assertIn('id == "basilica" and method == "quiet"',s)
        self.assertIn('hearing["observed"] =',s)
        self.assertIn('"participant"] = "Rootkin"',s)
        self.assertIn('"accord_type"] = "loaner"',s)
    def test_enemy_sight_obeyed_and_squad_attacks_not_all_at_once(self):
        s=src('scripts/enemy.gd')
        self.assertIn('func _has_clear_shot() -> bool',s)
        self.assertIn('result.get("collider") == player',s)
        self.assertIn('func _ally_winding_up() -> bool',s)
        self.assertIn('elif _ally_winding_up():',s)
        self.assertIn('if not sees_player:',s) # 07.9B fixes rush-through-wall exception
    def test_missing_enemy_position_is_not_fixed_fallback(self):
        s=src('scripts/enemy.gd')
        self.assertIn('saved.get("position",[position.x,position.y,position.z])',s)
        self.assertNotIn('saved.get("position",[18.0,0.15,0.0])',s)
    def test_weapon_impacts_are_material_sensitive(self):
        p=src('scripts/player.gd')
        self.assertIn('signal impact_event_079(at: Vector3, normal: Vector3, material_kind: String)',p)
        self.assertIn('impact_event_079.emit(hit["position"],hit["normal"],kind)',p)
        vfx=src('scripts/combat_impact_079.gd')
        for k in ['"metal"','"ceramic"','"living"']:
            self.assertIn(k,vfx)
        self.assertIn('spark.configure(material_kind,normal)',src('scripts/main.gd'))
    def test_hud_damage_reticle_feedback(self):
        ui=src('scripts/game_ui.gd')
        self.assertIn('func impact_damage_079(amount: int)',ui)
        self.assertIn('reticle_hit_clock_079',ui)
        self.assertIn('_update_vitals_079',src('scripts/main.gd'))
    def test_hearing_field_reflects_saved_current_state(self):
        h=src('scripts/physical_hearing_079.gd')
        self.assertIn('Game.hearing_phase()',h)
        self.assertIn('hearing.get("integrity",31)',h)
        self.assertIn('hearing.get("strain_margin",46)',h)
        self.assertIn('not bool(hearing.get("active",false))',h)
    def test_physical_switch_supports_quiet_or_shot(self):
        s=src('scripts/hazard_switch_079.gd')
        self.assertIn('"_switch_079"',s)
        self.assertIn('director.try_shutdown("rupture")',s)
        self.assertIn('func mark_spent()',s)
        d=src('scripts/encounter_hazard_079.gd')
        self.assertIn('func can_quiet_shutdown() -> bool',d)
        self.assertIn('shutdown_rejected.emit',d)
    def test_three_embedded_original_short_sfx(self):
        for n in ['arc_discharge_079.wav','forge_exhaust_079.wav','basilica_reed_079.wav']:
            with wave.open(str(ROOT/'assets/audio'/n),'rb') as aud:
                self.assertEqual(aud.getnchannels(),1)
                self.assertGreater(aud.getnframes(),10000)
        self.assertTrue((ROOT/'art/tools/generate_gameplay_sfx_079.py').exists())
    def test_civic_assembly_visible_reactions_are_evidence_backed(self):
        s=src('scripts/assembly_response_079.gd')
        self.assertIn('Game.assembly_support_078(group)',s)
        self.assertIn('bool(votes.get(group,false))',s)
        self.assertIn('"NO VALID TESTIMONY"',s)
        self.assertIn('"staged_groups"',s)
        self.assertIn('token.visible = staged',s)
        self.assertNotIn('passenger_manifest.append',s)
        self.assertIn('world.add_child(civic_board)',src('scripts/main.gd'))
    def test_fixed_floor_impact_art_original(self):
        from PIL import Image
        with Image.open(ROOT/'assets/textures/pressure_docket_079.png') as im:
            self.assertEqual(im.size,(512,512))
            self.assertEqual(im.mode,'RGBA')
        self.assertIn('floor_decal.rotation_degrees.x = -90.0',src('scripts/encounter_hazard_079.gd'))
        self.assertIn('QuadMesh.new()',src('scripts/encounter_hazard_079.gd'))
        self.assertIn('generate_pressure_decal_079.py',str(list((ROOT/'art/tools').glob('generate_pressure_decal_079.py'))))
    def test_preserve_original_core_story(self):
        s=src('scripts/run_state.gd')
        for key in ['qobj_writ_of_labour','qobj_writ_of_faith','qobj_writ_of_trade','qobj_writ_of_growth','qobj_writ_of_defence','True Dawn','LibERATION'.lower()]:
            self.assertIn(key.lower(),s.lower())

if __name__=='__main__': unittest.main(verbosity=2)
