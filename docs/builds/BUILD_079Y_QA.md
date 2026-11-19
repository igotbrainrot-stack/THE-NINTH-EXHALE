# Build 07.9Y QA — 18 Nov 2026

From extracted 07.9X source:
- `python3 -m unittest discover -s tests -p 'test_*.py'` — 237 tests, passed (exit 0).
- `python3 tests/validate_project.py` — 14 validations, passed (exit 0).
- ZIP CRC check — see packaging manifest.
- Godot 4.4+ binary not available; **no runtime import/F5, scene parsing, physics, FPS, audible mix, save/reload, animation preview or human playtest performed**.
- Geometry checks in Python validate the rectangle arithmetic only, **not** Godot collider placement, collision masks or actual movement.

Manual engine checks still required:
1. Observe signal/pull sightline around a closed metal wall. Breath must never drain when a pull ray is obstructed.
2. Shoot, sprint and flank across three zones; ensure the enemy projectile streak begins at actor muzzle and ends at cover/player, not behind walls.
3. Watch attack animation start in windup frame, and death in first death frame for all eight directions; verify no jitter.
4. In Sootworks, lure one live enemy onto vent during active cycle, observe one 0.85s stagger and continued ability to fight.
5. Fire the one-use fixture with multiple hostiles nearby; verify actor state persistence and no repeat XP or resource duplication after reload.
6. Test all 07.9B safety interactions, Writs, NPC quest state, Rootkin hearing, and civic mandates with both new and older active saves.

Testing claims are source-only; the ZIP is supplied as a complete Godot project, **not a certified engine-tested build**.
