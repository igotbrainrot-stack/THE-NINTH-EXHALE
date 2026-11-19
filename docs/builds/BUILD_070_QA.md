# Build 07.0 — Runtime QA

## Source validation performed
- `python3 -m unittest discover -s tests -p 'test_*.py'`
- `python3 tests/validate_project.py`

These validate source organization, legacy story and mechanical contracts, art references, 27 object profiles and 66 authored placements. They **do not** execute the Godot engine.

## Required Godot editor / runtime checks
1. Import `project.godot` with Godot 4.4+; run F5. Check Output/Debugger for parser errors.
2. Select `3D PROP GALLERY` from the title. Cycle nine object types per region with Left/Right, districts with Up/Down, Q/E to rotate, Space toggles automatic rotation, Esc returns to title.
3. Specifically check view from back and side: clinic bed, privacy screen, waiting bench, workbench, locker, worker console, Basilica bench, wooden shelf and queue stanchions.
4. In Hearth Nine, Sootworks and Basilica, check that furniture is 3D from side and rear and does not pivot in response to camera yaw. Inspect materials / UV tiling and lighting. Verify 640x400 readability.
5. Complete the existing intro, travel to both Writ districts, complete at least one non-combat route and re-enter an area after save/load to check fixture duplication.
6. Check previously known collision objects (beds/counters) still match furniture and walkways are open; new decorative geometry does not add collision.
7. Measure FPS and draw calls when facing densely decorated corners. Reduce mesh detail or share materials if needed.
8. Check the 3D gallery's title buttons at the intended window size and verify weapon and enemy galleries still load.

## Known unverified
- Godot 4 GDScript runtime compilation, collision, draw call performance, and aesthetic quality are not independently verified here.
