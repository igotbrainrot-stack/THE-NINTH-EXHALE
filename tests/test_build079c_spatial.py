"""07.9C authored geometry and state-driven world regression contracts."""
from pathlib import Path
import unittest
ROOT = Path(__file__).resolve().parents[1]
class Spatial079C(unittest.TestCase):
    def read(self, name): return (ROOT / 'scripts' / name).read_text()
    def test_impact_metadata_from_authored_box_material(self):
        src = self.read('world_builder.gd')
        for x in ['body.set_meta("surface_kind", surface)', '"metal"', '"ceramic"', '"wood"', '"stone"']:
            self.assertIn(x,src)
    def test_authored_furnace_vent_damage_footprint(self):
        src = self.read('encounter_hazard_079.gd')
        self.assertIn('vent.size = Vector3(2.6,0.055,8.4)',src)
        self.assertIn('absf(local_player.x) < 1.3 and absf(local_player.z) < 4.2',src)
    def test_basilica_inner_shelter_and_annulus(self):
        src = self.read('encounter_hazard_079.gd')
        self.assertIn('planar_distance > 1.25',src)
        self.assertIn('disc.top_radius = 1.25',src)
    def test_visible_consequence_driven_by_save_state(self):
        soot = self.read('sootworks_builder.gd'); basilica=self.read('basilica_builder.gd')
        self.assertIn('str(Game.state.get("brin",{}).get("decision",""))',soot)
        self.assertIn('str(Game.state.get("ossa",{}).get("decision",""))',basilica)
        self.assertIn('"help"',soot)
        self.assertIn('"exploit"',basilica)
    def test_pending_quiet_state_reset_on_load_and_world_rebuild(self):
        src = self.read('main.gd')
        self.assertIn('func _load_now() -> void:\n    pending_quiet_service_079 = ""',src)
        self.assertIn('func reload_district_world() -> void:\n    pending_quiet_service_079 = ""',src)
if __name__=='__main__': unittest.main()
