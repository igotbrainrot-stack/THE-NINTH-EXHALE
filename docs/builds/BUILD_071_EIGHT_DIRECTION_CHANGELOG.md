# THE NINTH EXHALE — Build 07.1 / Exact 0–8 sprite directions

## Scope

This continues the working-source lineage of Build 07.0 (which extended 06.9). **Gameplay quest records, item IDs, NPC life/death handling, world navigation and existing 3D prop meshes are not replaced.**

### Direction convention (user-required)

| ID | Actor direction relative to the viewer | Used for |
|---|---|---|
| 0 | Universal graphic, same image from every view | only deliberate non-rotating/symmetric sprite visuals |
| 1 | Direct front view | 0° |
| 2 | Diagonal front-left | 45° left |
| 3 | Left side | 90° left |
| 4 | Diagonal rear-left | 135° left |
| 5 | Rear/back | 180° |
| 6 | Diagonal rear-right | 135° right |
| 7 | Right side | 90° right |
| 8 | Diagonal front-right | 45° right |

The 1–8 direction is chosen by the angle between the camera and **the actor's local forward (-Z)** in eight equal sectors; the sprite plane itself faces the camera to avoid becoming edge-on, while its drawn texture changes to show the corresponding angle. 0 denotes universal-image mode and **is not a ninth 45-degree view**.

### Runtime changes

- New `scripts/sprite_rotations_071.gd`: a single shared 8-sector angle index with clear left/right ordering.
- `scripts/directional_npc_sprite.gd`: loads 1–8 for Sela, Brin, Ossa, Oren, and clerk; left and right are separate; optional universal 0 support; fallback to legacy originals when not available.
- `scripts/enemy.gd`: loads eight 4×3 atlases per enemy, each containing 12 original animation stages; preserves previous attack and quest logic. `sprite_rotation_mode=0` explicitly supports a single universal view if desired.
- `scripts/animated_echoform_068.gd`: Rootkin and Bell Wretch also use eight angle slots during the civic hearing, with mode 0 support.
- `scripts/enemy_gallery_068.gd`: up/down cycles 0–8 so visual ordering can be inspected, including attack cycles.
- New `scenes/npc_gallery_071.tscn` + `scripts/npc_gallery_071.gd`: civilian eight-direction inspection from the title.
- `scripts/prop_gallery_070.gd`: Q/E steps exactly 45° when inspecting 3D objects. Furniture retains **full 3D** rather than being downgraded to eight cardboard cutouts.

### Art regenerated and integrated

- 17 combat/hearing figures × 8 angle files = **136 enemy/hearing atlases**; each atlas has 12 animation cells. That's 1,632 indexed pose cells (the four original cardinal slots are reused). Existing 06.8 atlases remain untouched.
- 5 civilians × 8 angle files = **40 civilian sprite files**.
- Original freshly generated **Brin eight-view sheet** is included at `art/production_sources/brin_eight_view_imagegen_071.png` and its actual eight view sprites are embedded.
- The *other* added diagonal files are temporary **optical-flow-guided single-source warps between the four original source directions**, not independently authored perspective redraws. They are explicitly tracked in `art/EIGHT_VIEW_ASSET_MANIFEST_071.json`. The source Python tool is reproducible and accepts Pillow, numpy, OpenCV; Godot itself requires none of those Python packages.
- Sources created earlier in Runway are still not automatically embedded. Replacing provisional angles with original Runway exports remains an art-production task.

### Existing environment props

The 27 profile types / 66 authored positions from Build 07.0 remain **real fixed-orientation 3D meshes** that display continuously across all angles and have normal geometric occlusion. They already exceed the required eight views. 0–8 sprite rotation is not applied to solid objects unless a specific prop is intentionally authored as a sprite.

### Not changed

- Gameplay/quest state and full-game three-Writ requirement.
- 15 combat archetypes, two hearing actors, animations and collision.
- Player's first-person weapon display and unchanged current FPS camera.
- Original content and copyright/IP protections.

## Testing status

`tests/test_build071_directions.py` checks angle order, eight assets for every figure, atlas size and alpha, cardinal source preservation, galleries and 3D prop safety. These are **source-data checks, not Godot execution**.
