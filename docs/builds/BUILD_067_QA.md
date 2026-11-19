# Build 06.7 — QA and test evidence

## Independently executed in this file-producing environment

- `python3 -m unittest discover -s tests -p 'test_*.py'`: passes source/regression and approximate 2D reachability tests. Test count and detailed output in `BUILD_067_UNIT_TEST_OUTPUT.txt`.
- `python3 tests/validate_project.py`: all project source/data validations pass; output in `BUILD_067_PROJECT_VALIDATION.txt`.
- Deterministic texture recreated from `art/tools/generate_pressure_texture_067.py`, valid PNG (256x256).
- ZIP checked via Python `zipfile.testzip` and entry names.

## Not executed here

No Godot binary installed and remote engine downloads are blocked. This does **not** mean the owner's older functional build was unplayable. **Current 06.7 source has not been run in Godot**; physics collisions, scene import, lighting, audiovisual performance, framerate, UI layout, and fun require live testing.

## High-priority F5 walkthrough

1. Fresh new character, relay, dodge crawler, valve. Ensure no empty-ammo softlock (F intervention still works).
2. Confirm navigation pointer points to the actual relay/valve/Sela and respects choices (steal, speak, Tech, fight).
3. Save prior to a Sootworks pressure cylinder. Shoot it. Check stagger timing, recorded Energy ledger and visible spent body; save, load, switch district and return; verify no duplicate event or regained cylinder.
4. Try Sootworks worker relief cache twice; verify one ampoule total.
5. Visit Basilica, claim independent notes, start Rootkin hearing. First turn should have an initial observation, without granting or owning a creature. Withdraw and retry.
6. Fight Millwright / Cantor while circling and behind physical cover. Test locked crawler rush and non-homing movement at 100, 101, 102 seeded runs.
7. Finish two-Writ Edda trial and verify finale remains expressly noncanonical.
8. Check 4 different previous Build 06.6 and 06.5 saves, including one before/after a sector switch; check old states acquire safe `pressure_067`/`discovery_067` defaults.

## Human playtest still required

At least three real human sessions with timings, observations of confusion/boredom, and subjective feedback. This file contains no fabricated playtest feedback or success percentages.
