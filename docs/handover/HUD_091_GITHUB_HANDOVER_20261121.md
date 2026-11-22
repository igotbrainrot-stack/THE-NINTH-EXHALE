# THE NINTH EXHALE — HUD 09.1 art upload and weapon WIP

**Base:** `feature/build-091-cleanup-hud-handover-20261121` (PR #9)

This feature branch adds the entire 28-slot HUD_091 drop-in art set at `assets/ui/hud_091/`, all 23 original and programmatic production PNG masters at `art/production_sources/hud_091/`, `art/RUNWAY_HUD_091_MANIFEST.json`, `hud_091_slices.json`, visual contact sheets, Python verification and installation scripts. It does not change Godot gameplay code nor overwrite the old `hud_086` fallback assets. The HUD uses the existing override loader in `scripts/game_ui.gd`.

**Generator provenance:** the original high-resolution artworks were generated using OpenAI image tools, not exported Runway tasks. Source binaries and their SHA256 hashes are recorded in the manifest; Runway task IDs intentionally null and license review pending. Generated panels have no baked lettering.

**Visual tests:** An isolated Godot 4.4.1 importer and texture loading test previously passed 28/28, and the delivered source/runtime SHA256 verifier passes. Gameplay mock-ups in docs are composited previews, **not full Build 09.1 in-engine screenshots**. Full Build 09.1 real-game 640x400 HUD tests, modal tab interaction and focus, rendering/overlap review remain to be completed before merging.

**Weapon development:** `art/production_sources/weapons_concepts/covenant_pistol_8frame_WIP.png` is a white-background concept sheet only, not a usable game animation. No weapon runtime scripts or textures changed.

**Integration checks:** `python3 tools/verify_hud_091.py .`, `python3 -m unittest discover -s tests -p test_*.py`, `godot --headless --editor --path . --quit`, `godot --headless --path . res://tests/godot_hud_090.tscn`, `godot --headless --path . res://tests/godot_codefix_regressions.tscn`. The legacy `godot_hud_override_091.tscn` writes temporary overrides; run it in an isolated working tree, not over production art.

**Workflow:** Keep changes on a separate branch / draft PR, no force-push, no automatic merge.
