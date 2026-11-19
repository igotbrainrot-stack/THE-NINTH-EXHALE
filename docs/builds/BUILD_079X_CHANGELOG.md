# The Ninth Exhale — 07.9X Kinetic Combat / Sprite-State Pass

Baseline: `The_Ninth_Exhale_Build_079C_PARTIAL_SPATIAL_PASS.zip`, preserving all older Writ and civic systems.

Changes in runtime: `scripts/player.gd` walk 3.8→5.2, sprint cap 6.2→8.5, dash speed 11→13.5 and duration 0.18→0.24; existing finite Breath cost maintained. Fire cooldown 0.88× authored interval (floor 0.09), existing ammo/reload/heat unchanged. Shots emit tracer endpoints; `scripts/combat_tracer_079x.gd` renders 75ms collision-free line; `scripts/main.gd` wires them. `scripts/game_ui.gd` uses four-step original generated muzzle strip and faster recoil decay. `scripts/combat_impact_079.gd` boosts shards 7→11 with shorter duration. `scripts/enemy.gd` shortens telegraphs, increments attack tempo with LOS protection, role-specific rates in Hearth/Sootworks/Basilica, new alert visual state, wound priority, extended three-cell death sequence. `scripts/directional_npc_sprite.gd` has a timed talk gesture triggered via `scripts/player.gd` E interactions (on eligible actors with script). `project.godot` title refreshed. `tests/test_build064_weapons.py` updated for intentionally revised cooldown.

Limits: no new enemy groups/arena geometry; no wholly new walk/cover/reload directional sheets; no external Runway exports bundled. This is a meaningful kinetic/source pass, not the completed full animation and three-encounter overhaul requested. Full visual correctness needs Godot 4.4+ playtesting.

New reproducible FX source: `tools/generate_muzzle_079x.py`. GitHub partial asset commit: `7eca6acbdc7e206aa23aa6ac1df32ccfdcebf23d` (not complete game push).
