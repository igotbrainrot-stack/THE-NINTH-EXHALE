# Build 07.0 Remaining Work

- Godot runtime F5 import/playtest and 3D gallery compilation still need engine execution.
- Current mesh furniture is deliberately visual-only at 3D prop positions where the older decoration also had no collider. Some furniture can be walked through. Add collision in stages after path clearance tests rather than blindly blocking objectives.
- Light/normal/material UV consistency needs live visual QA; panel and material selection are source-validated only.
- New Runway image original PNGs cannot be embedded directly through current Runway connector; exported source files can be used in a later painted-material refinement.
- Next fidelity pass: artist-approved glTF Blender props or instanced MeshLibrary assets for dense furnishings if Godot profiling shows high node overhead.
