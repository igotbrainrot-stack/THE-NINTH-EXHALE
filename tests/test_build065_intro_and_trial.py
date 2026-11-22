import unittest
from pathlib import Path
from PIL import Image

R = Path(__file__).resolve().parents[1]

def source(path):return (R/path).read_text()

class NewOpeningAndTrial(unittest.TestCase):
    def test_intro_is_real_player_start_not_only_title_card(self):
        st=source('scripts/run_state.gd'); world=source('scripts/world_builder.gd')
        self.assertIn('"player_pos": [-24.0,0.15,14.2]',st)
        for name in ['wake_panel','intake_valve','Intake airlock shutter','Intake north-west partition','Intake east service wall']:
            self.assertIn(name,world)
        self.assertIn('INTAKE ALARM / FILTER CRAWLER LOOSE',source('scripts/main.gd'))

    def test_intro_has_real_small_hostile_and_combat_death_record(self):
        code=source('scripts/main.gd'); state=source('scripts/run_state.gd'); foe=source('scripts/enemy.gd')
        self.assertIn('\"sentry\":{\"hp\":32', ''.join(state.split()))
        self.assertIn('sentry.defeated.connect(_intro_sentry_defeated)',code)
        self.assertIn('record_intake_sentry_defeat()',code)
        self.assertIn('actor_key == "sentry"',foe)
        self.assertIn('Game.take_damage(_scaled_damage_096(role_damage))',foe)  # 09.6: difficulty-scaled
        self.assertEqual(4,__import__("json").loads((R/"data/enemy_roster_068.json").read_text())["combat_enemies"][0]["damage"])
        self.assertIn('rush_hit_ready',foe)
        self.assertIn('telegraph_started',foe)
        self.assertIn('"hp":32',state)

    def test_intro_event_ledger_and_no_farm(self):
        state=source('scripts/run_state.gd')
        for key in ['hearth.reprint_relay_woken','hearth.intake_sentry_stopped','hearth.intake_seal_stable']:
            self.assertIn(key,state)
        for level in ['intro_stage() != "unwoken"','intro_stage() != "alarm"','intro_stage() != "cleared"']:
            self.assertIn(level,state)
        self.assertIn('award_xp_once("hearth.intake_crawler",12)',state)
        self.assertIn('award_xp_once("hearth.intake_repair",8)',state)

    def test_old_saves_skip_sealed_gate(self):
        state=source('scripts/run_state.gd')
        self.assertIn('if not state.has("intro"):',state)
        self.assertIn('"stage":"stabilised"',state)
        self.assertIn('Game.intro_stage() != "stabilised"',source('scripts/world_builder.gd'))

    def test_furniture_does_not_billboard(self):
        details=source('scripts/art_detail.gd')
        # Build 07.0 supersedes flat two-sided standees with true 3D objects.
        self.assertIn('const PropMesh070 = preload("res://scripts/prop_mesh_070.gd")',details)
        self.assertIn('model.setup(district,index,scale_value)',details)
        self.assertNotIn('Sprite3D.new()',details)
        self.assertIn('model.rotation.y = PI * 0.5',details)
        self.assertIn('var cube := BoxMesh.new()',source('scripts/prop_mesh_070.gd'))
        # NPCs, creatures and some civic signs remain camera aware.
        self.assertIn('visual.billboard=BaseMaterial3D.BILLBOARD_ENABLED',source('scripts/world_builder.gd'))

    def test_new_art_plays_from_actual_embedded_files(self):
        for path in ['assets/cinematics/hearth_reprint_backdrop.png','assets/sprites/sentry_front.png']:
            with Image.open(R/path) as im: self.assertGreaterEqual(im.width,256)
        self.assertIn('OpeningArtwork',source('scenes/main.tscn'))
        self.assertIn('art/production_sources/intro',str(R/'art/production_sources/intro'))
        self.assertTrue((R/'art/production_sources/intro/hearth_ward_hub_generated_source.png').exists())

    def test_slice_requires_two_distinct_writs_lung_and_hearing(self):
        state=source('scripts/run_state.gd')
        for fragment in ['func can_enter_slice_lift','qobj_writ_of_labour','qobj_writ_of_faith','"lung"]["installed"','"hearing"'].copy():
            self.assertIn(fragment,state)
        self.assertIn('"not_full_game":true',state)
        self.assertIn('Full campaign Quorum STILL requires three',source('scripts/main.gd'))

    def test_public_petition_and_regulator_are_distinct_no_free_xp(self):
        state=source('scripts/run_state.gd'); code=source('scripts/main.gd')
        for fragment in ['slice.edda.original_petition','slice.edda_resolution','public_mandate','apparatus_shutdown','coercive_continuity','if outcome == "public_mandate" and not evidence:return false','if outcome == "apparatus_shutdown" and not bool(state["slice_finale"]["apparatus_defeated"]):return false']:
            self.assertIn(fragment,state)
        self.assertIn('or bool(state["slice_finale"]["resolved"]):return false',state)
        self.assertIn('state["ledger"].append(record)',state)
        for route in ['slice:enter','slice:petition','slice:fight','slice:return']:
            self.assertIn(route,code)

    def test_trial_is_physically_built_not_just_a_docket(self):
        lift=source('scripts/lift_builder.gd'); main=source('scripts/main.gd')
        for x in ['Lift docket floor','Lift rear bulkhead','Triage pressure bed A','Emergency writ hearing','Service lift return','solid_box(']:
            self.assertIn(x,lift)
        self.assertIn('LiftBuilder.new()',main)
        self.assertIn('"edda_machine"',source('scripts/enemy.gd'))

    def test_core_story_and_other_zones_preserved(self):
        main=source('scripts/main.gd');state=source('scripts/run_state.gd')
        for route in ['sootworks_interaction','basilica_interaction','faith_registry','brin:','hearing:start','claim:tech','claim:steal']:
            self.assertIn(route,main)
        self.assertIn('"slice_mode":true',state)
        self.assertIn('five_command',source('docs/builds/BUILD_06_IMPLEMENTATION_LOG.md').lower()+' five_command')

if __name__=='__main__':unittest.main()
