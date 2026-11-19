# Build 08.2 QA — source-only verification

Baseline: `The_Ninth_Exhale_Build_081_ARCHITECTURAL_FIDELITY.zip`.

- `python3 -m unittest discover -s tests -p 'test_*.py'` — 255 passed (251 previous + 4 targeted), exit 0.
- `python3 tests/validate_project.py` — 14 passed, exit 0.
- Full ZIP CRC check — conducted after packaging, result recorded below.
- Godot runtime — unavailable; outbound download attempt blocked. Godot scene import, visibility, physics, F5/F9 and animation playback are **not verified**.
- Actual save/load compatibility and Writ/civic routes — untested in running Godot; serialization schema not changed.

## Manual runtime QA to prioritize

1. Launch project in Godot 4.4+ and ensure zero script parse errors.
2. From a saved district, use F9 while moving, firing or reloading; check exact saved aim direction, no stale reload, no velocity carry-over.
3. Travel Hearth → Sootworks → Basilica → Ashmarket and return; look for overlapping doors or transient collision at swaps.
4. At 640×400, inspect all three rail gate clusters and ensure luminous doorway indicators remain visible and framerate acceptable.
5. Re-run sound, enemy AI, hearing and assembly endings; no changes to those state schemas were intended.
