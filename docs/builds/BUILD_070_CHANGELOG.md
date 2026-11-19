# Build 07.0 — Environmental Depth / Prop Geometry

## User-facing correction
The original 27 prop artwork profiles were instantiated as **66 fixed Sprite3D surfaces**. They no longer rotated toward the camera, but the objects still had zero physical thickness when viewed obliquely. This pass replaces each instanced decorative object with true Godot 3D geometry.

## Changed files
- `scripts/art_detail.gd`: **all 66 historical placements retained**; now creates `PropMesh070` nodes instead of a flat sprite plus a few shadow/seat blocks. Previously duplicated flat furniture hints removed.
- `scripts/prop_mesh_070.gd` (new): 27 model profiles across three districts, with real frames, backs, legs, doors, handles, bottles, wheels, piping, gauges, shelves, shutters, fittings and side/back geometry. Original existing stylized painted materials wrap around the actual geometry using UV triplanar rather than front-view-only cutouts.
- `scripts/prop_gallery_070.gd`, `scenes/prop_gallery_070.tscn` (new): press **3D PROP GALLERY** on the title menu; rotate each model freely, select region and object.
- `scenes/main.tscn`, `scripts/start_screen.gd`: added the 3D prop gallery without removing the weapon or enemy galleries.
- `tests/test_build065_intro_and_trial.py`: updated the obsolete Build 06.5 assumption that furniture must still be Sprite3D.
- `tests/test_build070_props.py`: asserts all 66 placements, 27 distinct models, multi-sided 3D mesh geometry, non-billboarding, no new colliders, and title-menu gallery integration.
- `art/RUNWAY_PROP_VIEWS_070.json`: tracks four **newly generated** original Runway four-view modelling references, but does not falsely claim those raw PNGs were committed.

## Design decisions
- **Fixed furniture:** volume through 3D geometry, not sprites whose appearance changes when the camera rotates.
- **Characters:** keep directional billboard sprites, where they actually suit a classic sprite-era FPS.
- **Materials:** integrate paint, patina and wear using original textures already bundled in the Godot project; preserve controlled low-resolution filter.
- **Navigation:** no new object collision added in this source pass, so existing quest paths and authored collider footprints are unchanged. For large furnishings not already matched by an existing collider, physical obstruction is a follow-up after runtime clearance tests.
- **Performance:** one of the three regions is active at a time. The 66 placements are 22 per region; the mesh count/lighting performance needs a Godot FPS check. Grouping/instancing can follow profiling, not guesses.
- **Canon:** unchanged Cinder Lung, three-Writ full game requirement, voluntary Echoform hearing, Edda slice report.

## Source research
- Godot Sprite3D reference: 2D texture shown in a 3D scene, not a true volumetric static object.
- Godot procedural mesh tutorials: MeshInstance3D and reusable mesh resources for authored 3D geometry.
- GridMap and MultiMesh: sensible future path for repeated fixed 3D furniture when the game expands.

## Known limitations
- Neither an in-engine run nor actual player frame-rate profiling occurred in this execution environment.
- Runway-generated four-view references are finished in the user's Runway workspace, but source PNG download into this container was not possible. The **actual bundled upgrade is real 3D meshes + previously embedded original textures**, not a claim that four raw Runway PNGs are embedded.
- Aesthetic tuning, collision per fixture and material UV density need visual review from multiple sightlines.
