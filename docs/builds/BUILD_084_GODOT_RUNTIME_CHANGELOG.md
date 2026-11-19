# Build 08.4 runtime fix

- Changed `scripts/sprite_grounding_074.gd` to defer cosmetic contact-shadow children to avoid Godot 4.4.1 actor-subtree setup errors.
- Updated `tests/test_build074_visual_polish.py` to assert the safe deferred insertion.
- Added `tests/godot_scene_smoke_084.gd` and `.tscn` for actual Godot scene startup and eight-zone loading checks.
- Added `BUILD_084_GODOT_RUNTIME_QA.md` with real runtime evidence and limitations.
- No quests, finite resources, Writ/ending conditions, art or combat logic changed.
