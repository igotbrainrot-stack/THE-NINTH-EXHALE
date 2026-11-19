# Build 08.4 partial — QA and research audit

Base: complete Build 08.3. This is a focused gameplay code iteration, not the entire V8.4 redesign.

## Executed checks
- `python3 -m unittest discover -s tests -q`: 263 tests PASS (260 inherited + 3 new).
- `python3 tests/validate_project.py`: 14 project validations PASS.
- Archive integrity: verified after packaging.

## Not executed
- Godot editor import or GDScript parser validation (Godot binary unavailable).
- F5 actual playtest, safe-hub walkthrough, wall-corner collision test, UI frames at 640x400, graphics comparison, profiling.
- Art integration: Runway account verified and 3D catalog queried, but no newly generated/exported model or image file placed into project.
- GitHub remote push or remote tree check.

## Technical research
- Official Godot 4.4 NavigationAgent3D and NavigationObstacle3D docs: full navmesh integration should be scoped as a separate authored-navigation pass rather than adding agents to existing unbaked rooms.
  https://docs.godotengine.org/en/4.4/tutorials/navigation/navigation_using_navigationagents.html
  https://docs.godotengine.org/en/4.4/tutorials/navigation/navigation_using_navigationobstacles.html
- Godot 4.4 AudioStreamPlayer3D has per-player polyphony limits; verify burst sounds do not mask alerts.
  https://docs.godotengine.org/en/4.4/classes/class_audiostreamplayer3d.html
- 3D catalogue: Poly Haven `modular_industrial_pipes_01` and `metal_grate_rusty` identified as CC0 candidates; external download blocked by runtime network restrictions. Do not treat as bundled assets.
- Runway connected; prior eight-view turnaround and audio assets exist but were not exported/imported in this pass.

## Critical unresolved consistency conflict
- The V8.4 design requires an enemy-free Hearth Nine hub, while the current game has tutorial crawler and enforcer + optional hostile roster in the hub, and quest guards depend on their existing IDs. Relocation to an Intake Annex must preserve event ids and old-save state; omitted in this build to avoid breaking the intro.
