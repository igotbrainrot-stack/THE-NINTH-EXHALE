# Build 08.7 — Asset Integration and Provenance

Baseline: complete Build 08.5 source with integrated HUD 08.6 artwork. This is a targeted integration and cleanup release, not a wholesale replacement of the original enemies or soundtrack.

## Implemented

- Installed all nine canonical HUD icons into actual GUI nodes or live use: health, breath (bellows), ampoule, ammo, weapon heat, Writ, evidence tab, interaction and route arrow. The heat indicator appears only when a genuinely owned Nail Storm is equipped; it is hidden for non-heat weapons and when no active attempt exists.
- Preserved health/breath counters, live progress bars, weapon selection, modal buttons, text, resource state and story logic. No game logic was rewritten.
- Removed 18 unreferenced derived icon sizes `icon_*_16.png` and `icon_*_24.png`, preserving the unsuffixed 24×24 runtime texture and all full-resolution production sources. Their exact SHA256 hashes and paths are recorded in `art/BUILD_087_REMOVED_REDUNDANT_EXPORTS.json` for reversal.
- Fixed a 640×400 UI overlap: the input legend formerly obscured the Vitals/Equipment panels; it now occupies the deliberate lower-center gap. Real Godot render captures are included in `docs/HUD_087_RUNTIME_GAMEPLAY.png` and `docs/HUD_087_RUNTIME_MODAL.png`.
- Corrected HUD provenance: original Runway board A is an approved design reference only, while individual HUD source images were locally generated against a surrogate. Their `runway_task_id` remains `null`; claims that they were exact Runway exports were removed. Runtime/source SHA256 and licensing status are included per item.
- Built `art/BUILD_087_RUNTIME_ASSET_REGISTRY.json` and `art/BUILD_087_ASSET_USAGE.csv` for all remaining 778 media resources, including SHA256, code-level classification, conditional loading and historical fallback status.
- Produced `art/BUILD_087_EXTERNAL_RUNWAY_QUEUE.json` for the approved board, NPC/enemy grunts and ambience tasks that have not been embedded; retained the existing 14 functional procedural audio fallback WAVs.
- Preserved the older directional atlas, static historical sprite art and duplicate-hash groups when code has fallback logic, gallery modes or archived test expectations. No risky deletion of actor families.
- Added Python regression tests and a real Godot 4.4 runtime asset integration scene.

## Explicitly not completed

The Runway cloud media binaries could not be downloaded into this environment. No external character turnarounds or Runway audio are represented as in-game assets. Therefore the full Runway replacement and actor animation pipeline is still open. The remote GitHub repository was not modified by this release.
