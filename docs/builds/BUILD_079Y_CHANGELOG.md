# THE NINTH EXHALE — Build 07.9Y Combat Polish

Baseline: full 07.9X kinetic source archive. This is an incremental continued source pass, not a replacement for the unfinished full gameplay/animation roadmap.

## Actual changes

- `scripts/enemy.gd`: physical sightline-authoritative enemy attack streaks, role-coloured 75ms enemy firing traces, no Breath loss on a Basilica pull intercepted by geometry, explicit attack-state clock reset, death-state transition reset. No new rights/quest/loot flags.
- `scripts/encounter_hazard_079.gd`: Sootworks furnace cycle staggers live hostiles physically standing inside vent for 0.85 seconds once per pulse; player pressure damage now respects structural geometry collision mask 1 (no damage through sealed world walls).
- `scripts/main.gd`: one-use shootable pressure fixture also staggers and lightly damages optional enemies inside its burst zone, retaining the original once-only fixture state, XP and saved actor death systems.
- `tests/test_build079y_combat_polish.py`: five regression tests for LOS-linked Breath, tracer endpoints, animation phase transitions, vent geometry and pressure-fixture contracts.
- `project.godot`: 07.9Y title.

No new Runway images or audio were integrated. Original 07.9X muzzle effect and all eight-direction art were retained without regeneration.
