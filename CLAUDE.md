# CLAUDE.md — THE NINTH EXHALE
**CURRENT HANDOVER: Build 08.7 — Asset Reconciled, 19 November 2026**

You are inheriting a real Godot 4.4.1 first-person RPG / industrial-civic horror game set in Vesper. **Do not rebuild from scratch or substitute a design-only project.**

## SOURCE-OF-TRUTH WARNING
The default GitHub branch has historically contained only a README/art-manifest skeleton. This handover branch is **NOT the complete game**, unless and until the 08.7 full-import branch is verified. Do not claim GitHub includes a playable game just because this file exists.

The authoritative, complete *local* archive is:
`The_Ninth_Exhale_Build_087_ASSET_RECONCILED_GODOT_TESTED.zip`
SHA-256: `375bbd75c9471cdece0aecebdb6e1ff4a747d12cacfbc587bf52e2c47401a15c`
ZIP: 2,150 files, 187,755,694 uncompressed bytes. Internal top directory: `The_Ninth_Exhale_Build_087_ASSET_INTEGRATION/`.

**Ask the owner to provide this ZIP if `project.godot`, `scenes/main.tscn`, and runtime `assets/` are not actually in the checked-out Git tree. Do not infer or fabricate missing files.** Use the import guide in `docs/BUILD_087_GITHUB_IMPORT.md`.

## PROJECT DIRECTORIES AFTER VERIFIED FULL IMPORT
`project.godot` — engine root (Godot 4.4.1)
`scenes/` — entry scenes
`scripts/` — FPS, AI, UI, state/serialization, worlds, encounter logic
`assets/` — runtime PNG/WAV/materials/meshes
`data/` — roster and narrative/quest data
`tests/` — 272 Python tests and Godot smoke/UI/asset scenes
`art/` — original high-resolution production sources, Runway queue, manifests and asset provenance
`docs/` — authoritative game bible, historical audits, release logs

### READ THESE IN ORDER
1. `docs/MASTER_GAME_BIBLE_FINAL.md` — canonical story, roles, progression and endings; do not substitute summaries.
2. `docs/BUILD_087_CHANGELOG.md`, `docs/BUILD_087_QA.md`, `docs/BUILD_087_OPEN_ISSUES.md`.
3. `art/BUILD_087_RUNTIME_ASSET_REGISTRY.json` and `art/BUILD_087_ASSET_USAGE.csv`.
4. `art/BUILD_087_ASSET_POLICY.md`, `art/BUILD_087_EXTERNAL_RUNWAY_QUEUE.json`, `art/BUILD_087_BYTE_IDENTICAL_GROUPS.json`.
5. `art/RUNWAY_HUD_086_MANIFEST.json` for HUD provenance.

## WHAT IS IMPLEMENTED AND TESTED IN BUILD 08.7
- Integrated Pressure Docket HUD: live vitals, weapons, objectives, dockets, interaction and route display. All **nine canonical HUD icons** have intended code-level connections. Nail Storm heat icon is conditional on owned/equipped weapon.
- 640x400 lower-controls-legend overlap fixed. Real Godot framebuffer captures included at `docs/HUD_087_RUNTIME_GAMEPLAY.png` and `docs/HUD_087_RUNTIME_MODAL.png`.
- Removed 18 redundant HUD size variants; retained the unsuffixed runtime icons and high-resolution source PNGs. Removal evidence in `art/BUILD_087_REMOVED_REDUNDANT_EXPORTS.json`.
- Enemy and NPC art fallback trees preserved so older scene/gallery paths do not break; 360 historical fallback/gallery items deliberately not purged.
- Maintained 14 procedural fallback actor WAVs and existing story/gameplay systems.
- Registered the remaining **778** media resources and checksums in the authoritative runtime asset registry. This is a code-level registry, **NOT proof every asset was visibly used**.
- Full ZIP integrity verified, and prior QA reports **272 Python unittests, 14 project validations**, Godot 4.4.1 editor import, HUD resource test, asset resource test, eight-district smoke, and actual 640x400 captures. Do not upgrade that claim to a complete interactive combat/endings/audio playthrough.
- Godot shutdown resource warnings and dummy-audio/ALSA limitations are still open.

## CRITICAL: RUNWAY PROVENANCE IS NOT RUNTIME INTEGRATION
The approved original Runway HUD concept is task `c9d38ddd-b52b-49d4-bcbb-7d00d5af135f` (Style A). **The individually shipped HUD PNGs came from a separate local image-generation pass using a surrogate board**, not exported individual Runway tasks. Per-element `runway_task_id: null` is intentional: do not change it to invented task IDs.

Unembedded Runway audio: conversational grunts `ea9e09a1-c650-4653-876a-2b797fbab8d5`, mechanical combat `550078cf-d09e-4e2e-b88a-4136d4e4e387`, creature combat `995831bf-e03c-4a16-b478-f7734aa4e6b3`, Foundry ambience `9457e19b-73bf-4667-98a2-d36a5209d2ad`, Basilica ambience `e5a9a5d8-f6a4-4362-80c2-3f9f51edcf3a`. Character turnaround tasks are tracked in `art/BUILD_087_EXTERNAL_RUNWAY_QUEUE.json`. None of those cloud media binaries is currently claimed as embedded. **Download bytes, validate license and hashes, convert/trim/alignment, wire them to Godot nodes, test in-engine, and only then update manifest statuses.**

## CANONICAL GAME RULES — DO NOT BREAK
- Vesper's five founding district offices; precisely **three independent unique Writs** for quorum, no duplicated awards.
- Rootkin public, consensual hearing with five actions **Press, Attune, Brace, Observe, Withdraw**, unlimited retries; no forced ownership.
- Six RPG attributes, three Custodians, six constituency checks, revocable three-vote civic mandate.
- 24/36 finite rail capacity and distinction between staged vs actually boarded; finite Energy/Correction/resources.
- Four terminal endings, including True Dawn's earned evidence and consent gates. Completed campaigns do not resume as playable.
- Nix speaks only witnessed events. Dead NPCs cannot talk; save/load action IDs are deduplicated.
- Hearth Nine is intended as an enemy-free hub but historical enemy assignments still require a careful migration; do **not** just delete enemies and break the introduction.
- Brin Harker and Sister Ossa under-60%-HP intimidation responses are implemented in 08.5+; preserve their civilian/non-combat role and saved consequence state.

## NEXT WORK IN PRIORITY ORDER
1. Confirm complete game upload (root `project.godot`, scripts, assets, tests, docs) is actually present on remote; do not claim until verified.
2. Keep the game opening and all eight zone loads working; use actual Godot 4.4.1 binary for every feature.
3. Finish canonical Runway binary import for 8-direction actors and audio: sprites must have consistent pivots, transparent outlines and all directions; add state animation rather than image stand-ins.
4. Maintain HUD 08.6 readability at 640x400; address unused artwork without manufacturing fake usage.
5. Safe-hub migration with real Intake Annex encounter handoff, improved Sootworks authored combat, visible doors/gates and more physical NPC reactions.
6. Preserve 4 endings and role-playing alternatives while improving performance and FPS visual fidelity.
7. Revisit legacy duplicate groups **only after** dynamic fallback/gallery references and actual Godot scene checks.

## RUN TESTS (FROM REPOSITORY ROOT ONCE FULL SOURCE IS IMPORTED)
```bash
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
godot --headless --editor --path . --quit
godot --headless --path . res://tests/godot_hud_086.tscn
godot --headless --path . res://tests/godot_asset_runtime_087.tscn
godot --headless --path . res://tests/godot_scene_smoke_084.tscn
```
Run a graphical manual playthrough before calling gameplay, audio or endings fully validated.

## BRANCH DISCIPLINE
Use one feature branch for each substantial change. Do not force push main, delete historical branches, merge an incomplete project, or commit engine binaries, `.godot/` cache, compressed build ZIPs or temporary renders. Use draft PRs until runtime-tested. Include exact commit SHA and asset hashes in handoff.
