"""Independent source and approximate route checks for the newly authored core chapter.
These checks do NOT execute Godot 4; human engine import and physics QA remain pending.
"""
from pathlib import Path
from PIL import Image
import unittest, math, re, json
ROOT=Path(__file__).resolve().parents[1]
def read(path): return (ROOT/path).read_text()
STATE=read('scripts/run_state.gd')
MAIN=read('scripts/main.gd')
CORE=read('scripts/core_builder_076.gd')

class Core076(unittest.TestCase):
    def test_three_writ_required_for_core_not_two_writ_test(self):
        gate=STATE.split('func can_enter_core_076()',1)[1].split('func visit_core_076()',1)[0]
        self.assertIn('quorum_audit',gate)
        self.assertIn('can_register_three_writ_quorum()',gate)
        self.assertNotIn('can_enter_slice_lift',gate)
        self.assertIn('if zone == "core":',MAIN)
        self.assertIn('if zone == "lift":',MAIN)
        self.assertIn('full_core',MAIN)
    def test_two_distinct_original_proofs_and_rail_charter(self):
        for id in ('core_conscription_order','core_architect_objection','core_rail_charter'):
            self.assertIn('"'+id+'"',CORE)
        self.assertIn('bool(core.get("order_read",false)) and bool(core.get("objection_heard",false)) and bool(core.get("rail_read",false))',STATE)
        for id in ('"order"','"objection"','"rail"'):
            self.assertIn(id+':{"key"',STATE)
        self.assertIn('Nix corroborates only fragments',MAIN)
    def test_one_custodian_from_worldplan_three_distinct_evidence_sources(self):
        self.assertIn('state["world_plan"].get("custodian","Canon Edda")',STATE)
        for custodian,flag in [('Canon Edda','voluntary_petition'),('Marshal Voss','independent_radio'),('Archivist Latch','excluded_wards')]:
            self.assertIn('"'+custodian+'": return "'+flag+'"',STATE)
            self.assertIn(custodian,MAIN)
        self.assertIn('core_target_evidence()',STATE)
    def test_resolution_routes_and_fate_vs_method_separation(self):
        segment=STATE.split('func resolve_core_custodian_076(',1)[1].split('func repair_rail_carriage_076()',1)[0]
        for method in ('"tribunal"','"abdication"','"containment"','"apparatus_shutdown"'):
            self.assertIn(method,segment)
        self.assertIn('state["core"]["custodian_method"] = method',segment)
        self.assertIn('state["core"]["custodian_fate"] = fate',segment)
        self.assertIn('"person_killed":false',segment)
        self.assertIn('"endings_offered":false',segment)
        self.assertIn('or not core_main_records_complete()',segment)
        self.assertIn('if stat("Speech") < 5 and stat("Insight") < 5',segment)
        self.assertIn('if not bool(state["core"].get("safety_bus_prepared",false))',segment)
    def test_tech_containment_cost_and_finite_rail_repair(self):
        bus=STATE.split('func prepare_core_safety_bus_076(',1)[1].split('func claim_core_cipher_076()',1)[0]
        self.assertIn('stat("Tech") < 5',bus)
        self.assertIn('int(state["resources"]["Energy"])-3',bus)
        self.assertIn('int(state["resources"]["Labour"])-2',bus)
        self.assertIn('if bool(state["core"].get("safety_bus_prepared",false))',bus)
        rail=STATE.split('func repair_rail_carriage_076(',1)[1].split('func record_rail_boarding_policy_076(',1)[0]
        self.assertIn('int(state["resources"]["Energy"])-2',rail)
        self.assertIn('int(state["resources"]["Labour"])-3',rail)
        self.assertIn('int(state["inventory"]["salvage"])-2',rail)
        self.assertIn('"rail_capacity"] = 36',rail)
        self.assertIn('"passengers_boarded":0',rail)
        self.assertIn('or bool(state["core"].get("rail_repaired",false))',rail)
        self.assertIn('"boarding_policy":""',STATE)
    def test_cipher_one_item_and_not_automatic_true_dawn(self):
        cipher=STATE.split('func claim_core_cipher_076(',1)[1].split('func record_core_actuator_defeat_076(',1)[0]
        self.assertIn('"object_id":"cipher"',cipher)
        self.assertIn('"consent_field":"blank"',cipher)
        self.assertIn('"dawn":"not unlocked"',cipher)
        self.assertIn('if not state["inventory"]["relics"].has("cipher")',cipher)
        self.assertNotIn('assembly_mandate',cipher)
        self.assertIn('The consent field is still blank',MAIN)
    def test_save_schema_additive_and_entry_and_return_wired(self):
        self.assertIn('    ensure_build076_state()',STATE)
        self.assertIn('if not state.has("core"): state["core"] = {}',STATE)
        self.assertIn('if not state["zone_positions"].has("core"):',STATE)
        self.assertIn('if not state["actors"].has("core_actuator")',STATE)
        self.assertIn('"core:enter"',MAIN)
        self.assertIn('"core:return"',MAIN)
        self.assertIn('Game.change_zone("hearth")',MAIN)
        self.assertIn('func core_interaction_076(interaction_id: String)',MAIN)
    def test_original_eight_direction_boss_and_music_present(self):
        for i in range(1,9):
            with Image.open(ROOT/f'assets/sprites/enemies_076/core_actuator_{i}.png') as im:
                self.assertEqual(im.size,(768,768))
                self.assertEqual(im.mode,'RGBA')
        self.assertIn('enemies_076/core_actuator_',read('scripts/enemy.gd'))
        self.assertIn('"core": "res://assets/music/core_first_signature_076.ogg"',read('scripts/adaptive_music_072.gd'))
        ogg=(ROOT/'assets/music/core_first_signature_076.ogg').read_bytes()
        self.assertTrue(ogg.startswith(b'OggS'))
        self.assertGreater(len(ogg),10000)
        for name in ('core_floor_076','core_wall_076'):
            with Image.open(ROOT/f'assets/textures/{name}.png') as im:self.assertEqual(im.size,(512,512))
    def test_lawful_removal_disarms_actuator_in_save_and_scene(self):
        method=STATE.split('func resolve_core_custodian_076(',1)[1].split('func repair_rail_carriage_076()',1)[0]
        self.assertIn('state["actors"]["core_actuator"]["alive"] = false',method)
        self.assertIn('state["actors"]["core_actuator"]["hostile"] = false',method)
        self.assertIn('state["actors"]["core_actuator"]["hp"] = 0',method)
        self.assertIn('state["core"]["actuator_disabled"] = true',method)
        self.assertIn('if resolved and is_instance_valid(guard):',MAIN)
        self.assertIn('guard.queue_free()',MAIN)
    def test_opening_and_archive_stations_roughly_accessible(self):
        # 0.5-m 2D grid oracle, ignores slopes/interactive camera raycasts.
        # Every core console should be approachable from its real entrance.
        import collections
        solids=re.findall(r'solid_box\([^\n]*?Vector3\((-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)\),Vector3\((\d+(?:\.\d+)?),(\d+(?:\.\d+)?),(\d+(?:\.\d+)?)\)',CORE)
        obs=[]
        for x,y,z,w,h,d in solids:
            if float(y)>-0.1 and float(h)>1.2:
                obs.append((float(x),float(z),float(w)/2+0.35,float(d)/2+0.35))
        def blocked(x,z):
            return abs(x)>29 or abs(z)>21 or any(abs(x-xx)<hw and abs(z-zz)<hd for xx,zz,hw,hd in obs)
        def cell(x,z):return (int(round(x*2)),int(round(z*2)))
        start=cell(-24,17); q=collections.deque([start]); seen={start}
        while q:
            x,z=q.popleft()
            for dx,dz in ((1,0),(-1,0),(0,1),(0,-1)):
                nxt=(x+dx,z+dz)
                if nxt not in seen and not blocked(nxt[0]/2,nxt[1]/2):
                    seen.add(nxt);q.append(nxt)
        goals={"order":(-19,-15),"objection":(19,-15),"rail":(-19,12),"safety":(19,-3),"custodian":(-8,-19),"return":(-24,18)}
        for label,(tx,tz) in goals.items():
            reachable=any((ix/2-tx)**2+(iz/2-tz)**2<=3.0**2 for ix,iz in seen)
            self.assertTrue(reachable,f'{label} console has no 3 m approach path')
    def test_authority_docket_not_embedded_inside_wall(self):
        # Approximate collision-space sanity check based on authored boxes.
        # A playable E raycast requires a reachable spot near the console.
        solid=re.findall(r'solid_box\([^\n]*?Vector3\((-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)\),Vector3\((\d+(?:\.\d+)?),(\d+(?:\.\d+)?),(\d+(?:\.\d+)?)\)',CORE)
        occupied=[]
        for x,y,z,w,h,d in solid:
            if float(y)>-0.1 and float(h)>1.2:
                occupied.append((float(x),float(z),float(w),float(d)))
        for name,x,z in [('executive',-8,-19),('boss',8,-11)]:
            overlaps=[(xx,zz) for xx,zz,w,d in occupied if abs(x-xx)<w/2+0.4 and abs(z-zz)<d/2+0.4]
            self.assertEqual(overlaps,[],f'{name} embedded in collidable obstacle: {overlaps}')
        # The central crossing wall must have an authored gap at z=0.
        self.assertIn('Vector3(0,2.4,-13.5),Vector3(0.75,4.8,17)',CORE)
        self.assertIn('Vector3(0,2.4,13.5),Vector3(0.75,4.8,17)',CORE)

if __name__=='__main__': unittest.main(verbosity=2)
