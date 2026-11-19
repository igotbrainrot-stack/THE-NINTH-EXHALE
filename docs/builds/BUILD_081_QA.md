# Build 08.1 QA

## Execution evidence

- `python3 -m unittest discover -s tests -p 'test_*.py'`: **251 passed** (includes six Build 08.1 visual resource/structure checks; log: `BUILD_081_UNITTEST_LOG.txt`).
- `python3 tests/validate_project.py`: **14 passed** (log: `BUILD_081_VALIDATION_LOG.txt`).
- ZIP CRC validation: see archive verification at packaging.
- Static checks verify assets exist, district configuration is wired, art has no collision node creation and critical original interaction IDs are retained.

## Not verified

- Godot 4.4+ startup, GDScript runtime parsing and scene imports.
- Materials under GL Compatibility at 640x400, object overlap, culling, frame budget, visual quality at gameplay distance.
- Old save F5/F9, active quest routes, combat encounter usability, hearing/assembly endings in-engine.
- New procedural texture study is not a gameplay capture.

## Manual Godot pass recommended

Run Hearth and Sootworks first; inspect portal shutters near transfer consoles, material brightness and piston motion. Then check Basilica arches, Orchard culture vats and Assembly door/rail. Watch for too-bright emissive surfaces and clipping, then check FPS with all decoration enabled and with an older active save loaded. Confirm player can reach each transfer console and that no decor looks like a gameplay affordance it does not provide.
