# Build 07.9Z — Attack Telegraph & Spatial Fairness Polish

Baseline: **complete Build 07.9Y Combat Polish**, carried forward intact; no save schema or action IDs changed.

## Changes in code

- `scripts/enemy.gd`: Ranged windups now project a short, translucent amber beam from the actual attacker toward the present player position. The preview is clipped by collision layer 1 (structural world) and tracks the player during an active windup; it disappears when a shot commits, the actor dies, environmental stagger interrupts it or the enemy is isolated. Rush attacks continue to use the existing warning and cannot attack through sealed geometry. The real damage ray remains authoritative and untouched.
- `scripts/encounter_hazard_079.gd`: Furnace vent stagger only applies to an enemy inside the vent rectangle when a structural-world ray from the machinery to the enemy is unobstructed. No new XP or resource generation.
- `scripts/main.gd`: One-use pressure-cylinder bursts now require a structural ray to either the office guard or optional enemies before applying stun/damage. Player HUD says ENEMY INTERRUPTED only if at least one target was actually affected. Existing once-only save/event handling retained.
- `scripts/directional_npc_sprite.gd`: A stationary, pivot-safe brief hit tint method `hurt_079z`, without resizing, fake turn frames or positional animation.
- `scripts/brin_actor.gd` and `scripts/ossa_actor.gd`: Invoke the shared tint when shot, without changing their canonical life/death decisions.
- `tests/test_build079z_combat_review.py`: Four regression tests, including PNG-header dimension verification of 32 active eight-view atlas files.
- `project.godot`, `README.md`: Updated title and verified status description.

No new Runway asset exports or game audio were created in this pass. All existing sprites, audio, storyline, saved flags and modules are preserved.
