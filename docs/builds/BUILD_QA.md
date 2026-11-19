# Build 08.0 — source QA

Baseline source is complete Build 07.9Z from uploaded ZIP. Source checks and ZIP checks are recorded below. Godot not installed, so engine F5, in-engine video, FPS, camera settings, character playback, old-save compatibility and human playtest are NOT verified. Runway exports not integrated, GitHub full source not pushed.

Verification run: 244 Python unittests pass; 14 source validations pass. ZIP archive integrity will be checked after packaging. No Godot runtime tested.

- Source test: `python3 -m unittest discover -s tests -p 'test_*.py'` — **245 passed**.
- Source/data validator: `python3 tests/validate_project.py` — **14 passed**.
- `launch_linux.sh` executable permission preserved in ZIP; extracted ZIP members still need host filesystem exec permissions.
- No Godot 4.4+ binary available, therefore no F5 import, physics, save migration, animation playback, FPS, audio or actual combat-feel validation.
- Side-by-side PNG is an authored preview of existing source frames with new trigger assignments, not a running-game capture.
- No new Runway media exports integrated; no full GitHub source push verified.


## Build 08.0A source-only checks
- Repacked weapon PNGs after alpha-edge cleanup.
- Confirmed transition-frame helper inserted into the shared world builder and active district builders.
- Godot runtime verification still pending.
