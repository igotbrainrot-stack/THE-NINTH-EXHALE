# THE NINTH EXHALE — Build 08.2: Deep Regression & Refinement

Base: Build 08.1 Architectural Fidelity, source retained intact except the changes documented below.

## Corrected source defects

1. `scripts/main.gd` — `reload_district_world`: disable, detach and only then queue the prior district for destruction. The old code only queued it, leaving old colliders/AI in the SceneTree until the end of the frame. The fix reduces transient duplication of physical bodies and callbacks while new district nodes are built.
2. `scripts/player.gd` — `capture_position`: record authoritative `pitch`, not `camera.rotation.x` which can include temporary 08.0 shot impulse. This avoids saving a recoil offset as persistent player aim.
3. `scripts/player.gd` — `restore_position`: clear pending reload metadata, weapon/dash/intervention cooldowns, current camera impulse and movement velocity; recompute nail-overheat flag from the restored persisted weapon heat. Prevents transient actions from an older state completing after a load or crossing areas.
4. `scripts/world_builder.gd` — transition frames use one dynamic OmniLight per door and two unshaded luminous indicators instead of two dynamic OmniLights. Useful around clustered rail gates, with collision and quest logic unchanged.
5. `tests/test_build082_deep_regressions.py` — four explicit source contracts for teardown ordering, saved pitch, transient reset and doorway lighting budget.

## Deliberately unchanged

All district layouts and scene IDs, Writ and quest logic, Rootkin and civic assembly rules, finite resources, endings, saved state schema, character art and existing weapon art. No Runway exports were generated and no GitHub push was performed during this pass.

## Verification boundary

The Python tests and data validators pass; Godot 4.4+ is not installed or downloadable in this environment. Consequently no GDScript compile/import test, F5 playtest, 3D collision confirmation, GPU/fps benchmark or visual quality claim is made. Treat runtime claims as pending.
