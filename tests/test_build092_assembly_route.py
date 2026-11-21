"""Build 09.2: the Assembly objective marker must not send the player to the
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

    def test_petition_verification_still_requires_core_copy(self):
        src = (ROOT / "scripts" / "run_state.gd").read_text()
        body = src[src.index("func verify_assembly_petition_078"):]
        body = body[:body.index("\nfunc ")]
        self.assertRegex(body, r'state\["core"\]\.get\("voluntary_petition"')


if __name__ == "__main__":
    unittest.main()
