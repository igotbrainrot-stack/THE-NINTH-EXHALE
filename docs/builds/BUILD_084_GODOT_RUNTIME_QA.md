# THE NINTH EXHALE — Build 08.4 Godot 4.4.1 engine verification

## Engine

Uploaded `Godot_v4.4.1-stable_linux.x86_64` (version `4.4.1.stable.official.49a5bc7b6`) was successfully executed on Linux x86_64.

## Reproduced runtime issue and fix

In the original Build 08.4, loading `scenes/hearth_nine.tscn` emitted three engine errors:
`Parent node is busy setting up children, add_child() failed`.

Cause: each of the three Hearth Nine directional NPC sprites called `Grounding074.add_contact_shadow(parent)` in its `_ready()` while that parent actor's subtree was still being assembled. The helper synchronously called `actor.add_child(decal)` on the busy actor.

Fix: `scripts/sprite_grounding_074.gd` schedules the purely cosmetic shadow with `actor.add_child.call_deferred(decal)` instead. Updated the older source contract test that incorrectly required synchronous insertion.

## Actual Godot runs

- `--headless --path PROJECT --quit-after 120`: title scene started successfully.
- `--headless --path PROJECT res://scenes/hearth_nine.tscn --quit-after 120`: Hearth Nine started. Pre-fix showed 3 `add_child()` errors; post-fix showed none.
- `--headless --path PROJECT res://tests/godot_scene_smoke_084.tscn`: created a new Witness attempt then rebuilt Sootworks, Flood Basilica, Ashmarket, Glass Orchard, Quiet Barracks, Core, Public Assembly and Hearth Nine. All 8 zone smoke checkpoints logged successful.

**Limit:** Tests use the actual Godot runtime and scene trees but in headless mode. They do not constitute a human gameplay test or prove collision, player input, image fidelity, audio playback or stable frame rate. Godot printed ObjectDB/resource leak warnings at process exit in the initial and final scene runs; these require further diagnosis.

## Repeatable smoke check

`./Godot_v4.4.1-stable_linux.x86_64 --headless --path /path/to/project res://tests/godot_scene_smoke_084.tscn`

**Warning:** The smoke scene creates a new local attempt and writes test save/profile data under the process user account. Use an isolated `HOME`/user-data folder when running outside a disposable test environment.
