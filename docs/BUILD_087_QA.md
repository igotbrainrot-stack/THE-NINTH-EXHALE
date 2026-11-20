# Build 08.7 — QA report

- Godot engine: **4.4.1.stable.official.49a5bc7b6** (user-supplied Linux binary).
- Python: `python3 -m unittest discover -s tests -p 'test_*.py'` (expected 272 passing).
- Project source validator: `python3 tests/validate_project.py` (14 tests passing).
- Import: `godot --headless --editor --path . --quit` — exit 0 after script/resource import.
- HUD scene: `godot --headless --path . res://tests/godot_hud_086.tscn` — zero failures.
- Asset scene: `godot --headless --path . res://tests/godot_asset_runtime_087.tscn` — zero failures; checks nine icons and 14 actor WAV files, equipment heat conditional, and reticle textures.
- District smoke: `godot --headless --path . res://tests/godot_scene_smoke_084.tscn` — loaded 8 districts.
- Render capture: under `xvfb-run` (not `--headless`), generated 640×400 screenshots from `tests/godot_hud_visual_capture_087.tscn` and `_closed.tscn`. Verified screenshots were real framebuffer captures, not mock-ups.
- ZIP integrity and all embedded PNGs tested programmatically before release.

### What these tests do not prove

A screenshot is not a full manual playthrough; nobody has confirmed all combat, Rootkin hearing, endings or audio balance through speakers. Headless audio warns that ALSA is unavailable and falls back to dummy. Godot still emits the pre-existing ObjectDB/resource-in-use warnings on shutdown. Source registry references are **not** proof of every asset appearing during normal play. No successful Runway media download occurred.
