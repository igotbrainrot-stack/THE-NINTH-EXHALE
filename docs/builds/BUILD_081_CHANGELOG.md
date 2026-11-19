# THE NINTH EXHALE — Build 08.1 Architectural Fidelity

Baseline: Build 08.0A Weapon/Door Fix. Existing 08.0 syntax repairs, saves, districts, interactions, Writs, Rootkin hearings, assembly accounting and endings are untouched.

## Implemented in source

- `scripts/industrial_art_pass_081.gd`: a non-colliding, 3D art layer instantiated on **every district rebuild**. Unique models for all nine built locations (Hearth, Sootworks, Basilica, Ashmarket, Orchard, Barracks, Core, Assembly, Lift): physical dimensionality from vessels, pressure gauges, arches, copper piping, cultivation vats, embossed shield bands, docket coils, civic pilasters and rail warning chevrons.
- Sootworks now has small, animated reciprocating piston rods. Existing mechanical fans acquire cast/copper material finishes and protective visual guards in `scripts/ambient_machinery.gd`.
- `scripts/world_builder.gd`: formerly generic, flat-shaded portal facades now have distinct retro-FPS silhouettes: ribbed two-leaf rail shutters, a split freight door and a civic keystone arch. The original interaction consoles keep their IDs and collision volumes. The gate facades are **not traversable openings**; they visually frame the transfer interaction.
- New authored surfaces in `assets/textures/architectural_081/`: deterministic 256x256 riveted iron, enamel crazing, patinated copper, salt wash and oxidized forge. Files are bundled; the new models reference the textures with triplanar mapping.
- Original shared district materials now differentiate hard enamel/stone-like roughness from metal finishes, rather than giving every surface roughness 1.0.
- `project.godot`: updated display title to 08.1.
- `tests/test_build081_environment_visuals.py`: six structural/asset tests.
- `docs/BUILD_081_MATERIAL_STUDY.png`: visual palette study of the actual new texture files, not a Godot screenshot.

## Preserved

All prior Build 08.0A weapon-alpha asset corrections and transition interactions are retained. Original Godot scene structure, canonical quest IDs and finite resource rules are unchanged. No new blockers, loot or NPCs were added. New meshes use only `MeshInstance3D`, `Label3D`, and decorative `OmniLight3D`, with no `StaticBody3D` or `CollisionShape3D` in the art layer.

## Limits

This is a meaningful environmental art pass, not proof that every actor/room has final visuals. No actual Godot 4.4+ import/F5, screenshots, FPS or in-engine collision tests were available in this environment. Door art still represents interaction-controlled transfer rather than a physically traversable corridor. GitHub has not been updated in this release.
