# Build 08.5 — Engine and source QA

Baseline: the complete Build 08.4 Godot Runtime Fix ZIP. Engine: **Godot 4.4.1 stable Linux x86_64**.

## Executed

- `python3 -m unittest discover -s tests -p test_*.py -q` — **267 passed**.
- `python3 tests/validate_project.py` — **14 passed**.
- `godot --headless --path . res://tests/godot_scene_smoke_084.tscn` — **8 district loads passed** (sootworks, basilica, ashmarket, orchard, barracks, core, assembly, hearth).
- `godot --headless --path . res://tests/godot_witness_threat_085.tscn` — **14/14 live witness checks passed**: Brin/Ossa spawn, threshold event, state, guard response, uniqueness, saved HP, and state after district reload.
- `godot --headless --path . --quit-after 120` — title started without GDScript parser errors.

## Limitations

- No graphical F5/F9 playthrough, no visual screenshot, no audio audition, no frame-time profiling or complete ending playthrough.
- Godot still reports `16 resources still in use at exit` and related ObjectDB leak warnings.
- The smoke test creates and saves a temporary Witness attempt: use an isolated HOME/user_data while testing.
- Runway account and existing generated assets were inspected but no new media was exported into the archive; CC0 Poly Haven geometry was identified but not imported.
- GitHub repo inspected (main only 9 KB skeleton); no complete runnable project push made.

## Runtime commands

`godot --headless --path /path/to/project res://tests/godot_witness_threat_085.tscn`
`godot --headless --path /path/to/project res://tests/godot_scene_smoke_084.tscn`
