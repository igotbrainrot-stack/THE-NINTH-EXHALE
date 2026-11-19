# Build 03 — Godot GDScript parse fix

User-reported error: `Error at (88, 28): Cannot infer the type of "destination" variable because the value doesn't have a set type.`

## Root cause

`scripts/enemy.gd` has `var player` without a declared static type. The previous `var destination := player.global_position+Vector3(...)` asked the GDScript parser to infer the type of a value accessed through this untyped player reference, which is impossible.

## Applied change

```gdscript
# Build 02
var destination := player.global_position+Vector3(0.0,1.25,0.0)

# Build 03
var destination: Vector3 = player.global_position + Vector3(0.0, 1.25, 0.0)
```

An explicit destination type means GDScript need not infer it through `player`. No gameplay parameters were changed.

## Verification

- The exact original failure expression is absent, explicit declaration present.
- Existing source/data/startup unittest checks re-run.
- **No Godot binary is installed in this execution environment. The GDScript compiler and real game play were not executed.**

## On the user's Linux machine

Extract the new Build 03 ZIP to a fresh folder; import its `project.godot` in Godot 4.x, run F5. In Godot, look for new errors at the bottom Debugger/Errors panel. Do not merge the new folder with older Builds 01 or 02.
