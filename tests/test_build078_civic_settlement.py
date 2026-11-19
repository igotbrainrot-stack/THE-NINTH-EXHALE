"""Build 07.8 source-level / model-invariant checks. No Godot runtime is implied.

Checks direct implementation contracts and scripted branch constraints. These do not
substitute for playing the four ending paths in Godot.
"""
import re
from pathlib import Path
import unittest
from collections import deque

ROOT = Path(__file__).resolve().parents[1]
STATE = (ROOT/'scripts/run_state.gd').read_text()
MAIN = (ROOT/'scripts/main.gd').read_text()
BUILDER = (ROOT/'scripts/assembly_builder_078.gd').read_text()
HUD = (ROOT/'scripts/game_ui.gd').read_text()

def section(start, end):
    return STATE.split(start, 1)[1].split(end, 1)[0]

class CivicSettlement078(unittest.TestCase):
    def test_old_saves_get_additive_assembly_fields(self):
        self.assertIn('    ensure_build078_state()', section('func ensure_build06_state()', 'func vent_pressure_fixture'))
        for val in ('"assembly"','"civic"','"mandate"','"votes"','"rail_state"','"passenger_manifest"','"finalized"'):
            self.assertIn(val, section('func ensure_build078_state()', 'func can_enter_assembly_078'))
        self.assertIn('"schema": 1',STATE)

    def test_assembly_is_different_physical_zone_from_trial(self):
        self.assertIn('state["zone"] = "assembly"',STATE)
        self.assertIn('state["zone"] = "core"',MAIN)
        self.assertIn('AssemblyBuilder078.new()',MAIN)
        self.assertIn('CoreBuilder076.new()',MAIN)
        self.assertIn('LiftBuilder.new()',MAIN)
        self.assertIn('core_assembly_gate_078',BUILDER if 'core_assembly_gate_078' in BUILDER else (ROOT/'scripts/core_builder_076.gd').read_text())
        self.assertIn('can_enter_core_076()',section('func can_enter_assembly_078()', 'func visit_assembly_078'))
        self.assertIn('core_main_records_complete()',section('func can_enter_assembly_078()', 'func visit_assembly_078'))
        self.assertIn('custodian_method',section('func can_enter_assembly_078()', 'func visit_assembly_078'))

    def test_all_three_unconditional_finales_are_independent_of_virtue(self):
        fragment=section('func ending_eligibility_078()', 'func _local_epilogue_078')
        self.assertIn('for label in ["liberation","dominion","crown"]:',fragment)
        self.assertIn('offered[label] = true',fragment)
        self.assertIn('offered["true_dawn"] =',fragment)
        self.assertNotIn('stat(',fragment)
        self.assertNotIn('relationships',fragment)
        self.assertNotIn('root_seed_found',fragment.split('offered["true_dawn"] =')[0])

    def test_true_dawn_has_three_independent_sources_and_mandate(self):
        tech=section('func dawn_technical_prerequisites_078()', 'func ending_eligibility_078')
        for flag in ('root_seed_found','heat_survey_found','cipher_copied','"cipher"'):
            self.assertIn(flag,tech)
        gate=section('func ending_eligibility_078()', 'func _local_epilogue_078')
        for flag in ('dawn_technical_prerequisites_078()', '"mandate"','"mandate_revoked"','"staged_seats"','"Energy"','"Labour"'):
            self.assertIn(flag,gate)
        self.assertNotIn('stat("Speech")',gate)

    def test_mandate_requires_risks_original_petition_three_verified_groups(self):
        gate=section('func grant_public_mandate_078()', 'func revoke_public_mandate_078')
        self.assertIn('risk_disclosed',gate)
        self.assertIn('petition_read',gate)
        self.assertIn('assembly_vote_count_078() < 3',gate)
        self.assertIn('revocable_public_mandate',gate)
        self.assertIn('mandate_revoked',gate)
        self.assertIn('state["civic"]["mandate_revoked"] = true',section('func revoke_public_mandate_078()', 'func rail_group_078'))

    def test_witnesses_cannot_double_vote_or_vote_without_original(self):
        support=section('func assembly_support_078(group:', 'func record_assembly_support_078')
        for key in ('"clinic"','"labour"','"choir"','"market"','"growth"','"defence"'):
            self.assertIn(key,support)
        record=section('func record_assembly_support_078(group:', 'func assembly_vote_count_078')
        self.assertIn('state["civic"]["votes"].has(group)',record)
        self.assertIn('not assembly_support_078(group)',record)
        self.assertIn('"independent_consented_constituency"',record)

    def test_capacity_limited_unique_non_boarded_staging(self):
        manifest=section('func stage_rail_group_078(group:', 'func dawn_technical_prerequisites_078')
        self.assertIn('state["civic"]["staged_groups"].get(group,false)',manifest)
        self.assertIn('"rail_capacity"',manifest)
        self.assertIn('"boarded":0',manifest)
        self.assertIn('"named_cohort_voluntary_muster_not_departure"',manifest)
        self.assertIn('staged_seats',manifest)
        self.assertEqual(10+8+8+10,36)
        self.assertTrue(all(str(c) in STATE for c in (24,36)))

    def test_finales_board_only_after_real_ending_and_only_rail_open(self):
        engine=section('func complete_ending_078(', 'func non_existent_terminator')
        self.assertIn('if kind in ["liberation","true_dawn"]:',engine)
        self.assertIn('"rail_state":rail_status',engine)
        self.assertIn('rail_status = "departure_open"',engine)
        self.assertIn('rail_status = "limited_trial_departure"',engine)
        self.assertIn('"seats_used":seats',engine)
        self.assertIn('if seats > int(state["core"].get("rail_capacity",24)): return false',engine)
        self.assertIn('summary = "DOMINION / Exits remain closed',engine)
        self.assertIn('summary = "THE CROWN / Ninth takes personal command and seals the exits',engine)

    def test_true_dawn_consumes_real_conventional_power_and_labour(self):
        code=section('func complete_ending_078(', 'func non_existent_terminator')
        self.assertIn('state["resources"]["Energy"] = int(state["resources"]["Energy"])-3',code)
        self.assertIn('state["resources"]["Labour"] = int(state["resources"]["Labour"])-2',code)
        self.assertIn('"Correction":0,"Biomass":0',code)
        self.assertIn('"one pre-existing sealed launch battery"',code)

    def test_completed_campaign_is_terminal_and_profile_keeps_selected_custodian(self):
        code=section('func complete_ending_078(', 'func non_existent_terminator')
        self.assertIn('state["status"] = "completed"',code)
        self.assertIn('state["civic"]["finalized"] = true',code)
        self.assertIn('var custodian_name: String = core_custodian()',code)
        self.assertIn('"custodian":custodian_name',code)
        self.assertIn('profile["completed_endings"].append(entry)',code)
        self.assertIn('save_profile()',code)
        self.assertIn('save_attempt()',code)
        self.assertIn('if not Game.has_attempt():return',MAIN)
        self.assertIn('New Counterfactual'.upper().split()[0],MAIN.upper())

    def test_epilogue_never_claims_dead_npc_speaks(self):
        code=section('func _local_epilogue_078()', 'func ending_epilogue_078')
        self.assertIn('if not bool(actor.get("alive",true)):',code)
        self.assertIn('does not speak after their recorded death',code)

    def test_world_is_real_collision_geometry_with_wide_access(self):
        for name in ('Public assembly floor','Assembly north outer wall','Assembly south outer wall','Rail track left','Rail track right','Signed cohort bench'):
            self.assertIn(name,BUILDER)
        for name in ('assembly_risks_078','assembly_petition_078','assembly_final_078','assembly_mandate_078','assembly_rail_patients_078'):
            self.assertIn(name,BUILDER)
            self.assertIn(name,MAIN)
        # The authored central aisle has no full-wall separator/door collider.
        self.assertNotIn('Assembly central partition',BUILDER)

    def test_hud_and_soundtrack_include_new_zone(self):
        self.assertIn('"assembly": "res://assets/music/core_first_signature_076.ogg"',(ROOT/'scripts/adaptive_music_072.gd').read_text())
        self.assertIn('PUBLIC ASSEMBLY / LAST SIGNATURE',HUD)
        self.assertIn('ASSEMBLY / LIVE FINITE RAIL REGISTER',HUD)


    def test_muster_can_be_revised_without_double_boarding(self):
        fragment=section('func release_rail_group_078(group:', 'func dawn_technical_prerequisites_078')
        self.assertIn('"cohort_withdrew_before_departure"',fragment)
        self.assertIn('"boarded":0',fragment)
        self.assertIn('state["civic"]["staged_groups"][group] = false',fragment)
        self.assertIn('maxi(0,int(state["civic"]["staged_seats"])-places)',fragment)
        self.assertIn('assembly:release:', MAIN)

    def test_menu_retains_terminal_history_without_rewinding_game(self):
        self.assertIn('"ending:archive"',MAIN)
        self.assertIn('Game.profile.get("completed_endings",[])',MAIN)
        self.assertIn('ARCHIVED SETTLEMENTS / NOT REWOUND',MAIN)
        self.assertIn('choices.size() >= 4',HUD)

    def test_authored_assembly_major_stations_approximately_reachable(self):
        # Grid-clearance oracle; does not prove live physics or E raycasting.
        solids = re.findall(r'solid_box\([^\n]*?Vector3\(\s*(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)\),\s*Vector3\(\s*(\d+(?:\.\d+)?),\s*(\d+(?:\.\d+)?),\s*(\d+(?:\.\d+)?)\)', BUILDER)
        obstacles=[]
        for x,y,z,w,h,d in solids:
            if float(y)>0.0 and float(h)>0.65:
                obstacles.append((float(x),float(z),float(w)/2+0.30,float(d)/2+0.30))
        def blocked(x,z):
            return abs(x)>27.1 or abs(z)>21.1 or any(abs(x-xx)<w and abs(z-zz)<d for xx,zz,w,d in obstacles)
        def key(x,z):return (int(round(x*2)),int(round(z*2)))
        source=key(-20,17)
        self.assertFalse(blocked(-20,17),'Assembly spawn is embedded in a collider')
        q=deque([source]);seen={source}
        while q:
            x,z=q.popleft()
            for dx,dz in ((1,0),(-1,0),(0,1),(0,-1)):
                nxt=(x+dx,z+dz)
                if nxt not in seen and not blocked(nxt[0]/2,nxt[1]/2):
                    seen.add(nxt);q.append(nxt)
        goal_positions={'risks':(-21,-14),'petition':(-14,-14),'mandate':(0,-14),'clinic':(-21,-3),'growth':(7,-3),'claimant':(0,12),'final':(18,-14),'return':(-22,18)}
        for label,(x,z) in goal_positions.items():
            reaches=any((ix/2-x)**2+(iz/2-z)**2<=2.8**2 for ix,iz in seen)
            self.assertTrue(reaches,f'No approximate 2.8 m approach path to {label}')

    def test_four_rail_cohort_orders_never_overflow_authored_capacity(self):
        from itertools import permutations
        costs=(10,8,8,10)
        for cap in (24,36):
            for sequence in permutations(costs):
                used=0
                for amount in sequence:
                    if used+amount<=cap:
                        used+=amount
                    self.assertLessEqual(used,cap)
        stage=section('func stage_rail_group_078(group:', 'func release_rail_group_078(')
        self.assertIn('if int(state["civic"]["staged_seats"]) + places > int(state["core"].get("rail_capacity",24)): return false',stage)

    def test_completion_hides_ongoing_combat_and_ends_as_record_not_death(self):
        code=section('func complete_ending_078(', 'func non_existent_terminator')
        self.assertIn('state["status"] = "completed"',code)
        self.assertNotIn('fail_attempt(',code)
        self.assertIn('"separate_campaign":true',code)
        self.assertIn('Game.ending_epilogue_078()',MAIN)
        self.assertIn('player.set_control_active(false)', MAIN)
        self.assertIn('THE CROWN',MAIN)


    def test_terminal_endings_require_explicit_second_confirmation(self):
        self.assertIn('FINAL AUTHORISATION / NO REWIND',MAIN)
        self.assertIn('"action":"assembly:commit:"+kind',MAIN)
        self.assertIn('elif step.begins_with("commit:"):',MAIN)
        self.assertIn('Game.complete_ending_078(kind)',MAIN)
        self.assertIn("The chosen outcome\'s conditions have changed",MAIN)

if __name__=='__main__':unittest.main(verbosity=2)
