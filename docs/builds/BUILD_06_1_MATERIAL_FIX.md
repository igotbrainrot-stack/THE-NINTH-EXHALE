# Build 06.1 — Material compatibility fix

**User-reported failure:** `Error at (73, 41): Cannot find member "TEXTURE_REPEAT_ENABLED" in base "BaseMaterial3D".`

- Source: `scripts/world_builder.gd:73`, `make_material()`.
- Cause: `BaseMaterial3D.texture_repeat` is a Boolean in Godot 4; `TEXTURE_REPEAT_ENABLED` is a `CanvasItem` enum, not a `BaseMaterial3D` enum.
- Applied correction: `mat.texture_repeat = true`. This preserves triplanar UV and texture tiling, using Godot's actual `BaseMaterial3D` property.
- Regression coverage: `tests/test_build06_material_compatibility.py`.
- Scope: a parser compatibility repair. No quest systems, world assets, or gameplay logic intentionally changed.
- **Validation:** 47 Python source/data checks pass, plus package integrity check. A Godot engine import or interactive playtest was not performed because Godot is not installed in the packaging environment.

## Godot retest

1. Extract this updated ZIP into a separate folder and import `project.godot` from that folder.
2. Press **F5** and enter Hearth Nine.
3. Confirm the updated wall textures appear, then travel to Flood Basilica after the Lung quest.
4. Report any *new* parser message with its path/line and error text; a source check is not an engine compiler.

## API source

- `BaseMaterial3D.texture_repeat`: <https://docs.godotengine.org/en/stable/classes/class_basematerial3d.html>.
- `CanvasItem.TEXTURE_REPEAT_ENABLED` belongs to the 2D canvas API: <https://docs.godotengine.org/en/stable/classes/class_canvasitem.html>.
