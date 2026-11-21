# THE NINTH EXHALE — Weapon Art Continuation Handover
Date: 2026-11-22
Branch: `feature/weapon-art-092-20261122`
Target: `feature/build-092-immersive-sim-p1-20261122`
Pull request: https://github.com/igotbrainrot-stack/THE-NINTH-EXHALE/pull/11

## Current state
The four Runway-generated weapon masters and action sheets have been imported into the Build 09.2 Godot project. The import preserves the original sheets, AI-segmented alpha sources, runtime strips, manifests, checksums, contact sheets, alpha masks and animated previews.

Runtime art paths:
- `assets/weapons/anim_092/covenant/`
- `assets/weapons/anim_092/coil/`
- `assets/weapons/anim_092/nail/`
- `assets/weapons/anim_092/choir/`

Production sources:
- `art/production_sources/weapons_092/`
- `art/WEAPON_ANIM_092_MANIFEST.json`
- `art/ART_ANIMATION_COVERAGE_092.csv`

## Animation coverage and acceptance gaps
| Weapon | Idle | Fire/action frames | Distinct action poses | Remaining |
|---|---:|---:|---:|---|
| Covenant Pistol | 4-frame micro-breath from one master | 4 | 4 | reload, dry, draw, intervene |
| Coil Shotgun | 4-frame micro-breath from one master | 6 | 4 (two holds) | reload, dry, draw, intervene; additional distinct discharge poses |
| Nail Storm | 4-frame micro-breath from one master | 2 | 2 | reload, dry, draw, intervene, vent; more piston-cycle poses |
| Choirbreaker | 4-frame micro-breath from one master | 5 | 4 (one hold) | reload, dry, draw, intervene; idle shutter/resonator ripple |

The current idle strips are small positional variations (<=2 px) from a single master image, not fully authored mechanical idle animations. Reload, dry, draw and intervene use existing procedural fallbacks. Nail vent and Choir shutter ripple are not yet authored as image states.

Muzzle/shell anchors are provisional. Recheck them in the rendered game. The capture harness label/timing defect was corrected in commit `b2b3bd585dbe1af8bd17ffb6c0e6e18cb2dd7019`: it now begins a Witness attempt, grants the four test weapons to the temporary test inventory, equips each weapon through `Game.equip_weapon()`, and captures 20 ms after fire so the 75 ms muzzle flash is still visible. This correction still needs a fresh rendered capture run for final visual sign-off.

## Engine and package
Godot version: 4.4.1 stable Linux x86_64.
Workflow: `.github/workflows/package-godot-092.yml`.
It imports the project, runs the Python regression suite, runs Godot scene/animation/weapon/perception/HUD tests, performs a 420-second rendered playbot run, then packages the complete project source/assets together with the official Godot 4.4.1 Linux executable. The package contains `RUN_GAME.sh`, `RUN_TESTS.sh` and a runtime README. Download the Actions artifact from the workflow run after completion; do not assume the artifact exists until the upload step has succeeded.

The previously uploaded Godot binary from an older chat was not mounted in the current workspace. The package workflow therefore fetches the official Godot 4.4.1 stable Linux x86_64 release, verifies its version, and includes it. This is the same engine version, not the exact prior attachment.

## Research / source models
- Four Runway Tripo H3.1 models are recorded in the weapon manifest at approximately 1.4 million triangles each. They are source references only and must not be used as runtime meshes without retopology and LOD.
- 3D-Shep-Bot searches were performed for industrial steel, leather and ceramic references. No third-party asset was close enough to the four weapon designs to justify importing. Any third-party licensing review remains pending.
- Research notes: `docs/handover/WEAPON_092_RESEARCH_NOTES.md`.

## Current external generation constraint
The connected Runway workspace returned an out-of-credits error when submitting a new Nail Storm four-pose piston-cycle sheet. Do not retry with another model. Existing imported assets remain available; new Runway generations require the workspace credits to be replenished.

## Next work
1. Finish the current Godot package workflow and download the artifact.
2. Extract the packaged project and run `RUN_TESTS.sh` with the included Godot binary locally; verify `RUN_GAME.sh` starts.
3. Review the full 420-second playbot summary and screenshot captures. Do not call a partial playbot ending a completed campaign.
4. Fix the weapon capture harness label issue and verify each weapon's actual runtime sprite, muzzle anchor, recoil and HUD name.
5. After credits are replenished, generate missing unique frames: Nail Storm piston/vent cycle; Choirbreaker shutter ripple; reload/dry/draw/intervene states for all four weapons.
6. Add weapon-specific muzzle effects (Coil electrical discharge, Nail compressed-air/mandrel effect, Choir acoustic pressure effect) instead of reusing the generic muzzle burst.
7. Preserve original Runway files and source hashes. Do not overwrite or delete old weapon assets until runtime comparisons pass.
8. Do not merge PR #11 until package verification, anchor review and missing-state coverage are explicitly accepted.

Do not change the civic story, Writ uniqueness, Rootkin five-command public hearing, finite resource economy, campaign save invariants or endings while doing this art integration.
