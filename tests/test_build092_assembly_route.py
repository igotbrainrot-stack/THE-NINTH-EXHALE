"""Build 09.2: objective-marker dead ends. The Assembly objective marker must not send the player to the
patient petition unless the Ninth copied it in the Core (Latch/Voss runs never
route there, so the marker stranded players at a NOT RECORDED console)."""
from pathlib import Path
import re, unittest

ROOT = Path(__file__).resolve().parents[1]


class AssemblyRouteTests(unittest.TestCase):
    def test_petition_route_requires_copied_petition(self):
        src = (ROOT / "scripts" / "main.gd").read_text()
        nav = src[src.index("func _nav_target"):]
        block = nav[nav.index('if zone == "assembly":'):nav.index('if zone == "core":')]
        line = next(l for l in block.splitlines() if "petition_read" in l and l.strip().startswith("if"))
        self.assertIn('voluntary_petition', line)

    def test_faith_route_offers_lay_council_before_wicket(self):
        src = (ROOT / "scripts" / "main.gd").read_text()
        nav = src[src.index("func _nav_target"):]
        block = nav[nav.index('if zone == "basilica":'):nav.index('if zone == "ashmarket":')]
        self.assertIn('"LAY COUNCIL","pos":Vector3(-8,0,-18)', block)
        self.assertLess(block.index("LAY COUNCIL"), block.index("FAITH PUBLIC WICKET"))
        self.assertIn("cantor_defeated", block)
        # Meet and question Ossa first, at her undecided position in the builder.
        self.assertIn('"SISTER OSSA","pos":Vector3(-19,0,5)', block)
        self.assertLess(block.index("SISTER OSSA"), block.index("LAY COUNCIL"))
        builder = (ROOT / "scripts" / "basilica_builder.gd").read_text()
        self.assertIn('"faith_council",Vector3(-8,0,-18)', builder)

    def test_trade_route_goes_to_collector_board_first(self):
        src = (ROOT / "scripts" / "main.gd").read_text()
        nav = src[src.index("func _nav_target"):]
        block = nav[nav.index('if zone == "ashmarket":'):]
        block = block[:block.index("    if zone ==", 10)]
        self.assertIn('"COLLECTOR\'S BOARD","pos":Vector3(14,0,4)', block)
        for flag in ("counting_lock_isolated", "collector_defeated", "intimidation_recorded"):
            self.assertIn(flag, block)
        builder = (ROOT / "scripts" / "ashmarket_builder.gd").read_text()
        self.assertIn('"market_collector_desk",Vector3(14,0,4)', builder)

    def test_petition_verification_still_requires_core_copy(self):
        src = (ROOT / "scripts" / "run_state.gd").read_text()
        body = src[src.index("func verify_assembly_petition_078"):]
        body = body[:body.index("\nfunc ")]
        self.assertRegex(body, r'state\["core"\]\.get\("voluntary_petition"')


if __name__ == "__main__":
    unittest.main()
