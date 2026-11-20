# CLAUDE.md — THE NINTH EXHALE
**Handover refreshed: 2026-11-20.** Godot 4.4.1, GL Compatibility, native 640×400 first-person industrial-civic horror RPG in Vesper.

## IMPORTANT — current repository vs authoritative build
GitHub **main is a complete runnable Build 08.5** at commit `625152e07b8163b5ac4bc4e603ea5ed79e89ff3d`. It is NOT the historical skeleton. Do not revert it.
The newer complete **Build 08.7** is a separate local archive, `The_Ninth_Exhale_Build_087_ASSET_RECONCILED_GODOT_TESTED.zip` (SHA256 `375bbd75c9471cdece0aecebdb6e1ff4a747d12cacfbc587bf52e2c47401a15c`, **2,150 entries, CRC passed**). It has NOT been committed to GitHub as of this handover. Get the actual archive before attempting to import 08.7; docs or task IDs are not game binaries. The archive root is `The_Ninth_Exhale_Build_087_ASSET_INTEGRATION/`.

The active Claude fix branch `fix/085-code-errors` (draft PR #3, commit `5f226c488258c11ac4044d45881477e3eabfb306`) is based on **main Build 08.5**, not 08.7. **Do not wholesale overwrite 08.7 scripts with PR #3**: both modify `scripts/game_ui.gd`, HUD placement, and supporting runtime state. Review and port each relevant fix onto a fresh 08.7 integration branch, retaining tests.

## Read this in the complete Build 08.7 ZIP
1. `docs/MASTER_GAME_BIBLE_FINAL.md` — authoritative lore, RPG and quest constraints.
2. `docs/BUILD_087_CHANGELOG.md`, `docs/BUILD_087_QA.md`, `docs/BUILD_087_OPEN_ISSUES.md`.
3. `art/BUILD_087_RUNTIME_ASSET_REGISTRY.json`, `art/BUILD_087_ASSET_USAGE.csv`, `art/BUILD_087_ASSET_POLICY.md`.
4. `art/BUILD_087_EXTERNAL_RUNWAY_QUEUE.json`, `art/BUILD_087_BYTE_IDENTICAL_GROUPS.json`, `art/RUNWAY_HUD_086_MANIFEST.json`.
5. `docs/HUD_087_RUNTIME_GAMEPLAY.png` and `docs/HUD_087_RUNTIME_MODAL.png` (actual Godot 640×400 captures).

## Build 08.7 accomplishments and limits
- Integrated Pressure Docket HUD with nine canonical live icons: health, breath, ampoule, ammo, heat, Writ, evidence tab, interact and route arrow. Nail Storm heat icon only when the weapon is actually owned/equipped.
- Fixed bottom controls-legend overlap at 640×400. Preserved live counters, progress bars, player equipment state, prompts and dialogue.
- Removed 18 unused HUD size variants; all canonical 24px icons and full-resolution sources retained.
- Tracked **778 media files** in an asset registry and retained **360 historical fallback/gallery items** where dynamic loading or tests might still need them. Source-path audits do NOT prove each asset appears in play.
- Retained 14 working procedural actor WAVs. Runway audio and character-turnaround jobs remain external and unembedded.
- HUD reference board A is Runway task `c9d38ddd-b52b-49d4-bcbb-7d00d5af135f`, but delivered 08.6 individual HUD assets were locally generated from a surrogate board. Individual `runway_task_id: null` is accurate; do not falsify provenance.
- Prior Build 08.7 QA reports **272 Python tests, 14 project validations, Godot 4.4.1 import, HUD and asset scenes, eight-zone smoke, 640×400 captures**. Audio device/playthrough/endings/combat balance are NOT manually verified.

## PR #3 fixes to reconcile, not blindly merge
Claude PR #3 targets HUD label sizing, objective/route text, exit music resource leak, metallic-black prop rendering, pooled tracer/impact resources and eight-voice action audio, colinear look_at warnings, return-zone facing, real death locations, restoring reconstruction after restart, F9 anti-abuse and HP cap increases. PR #3 reports its own 32/32 Godot regression assertions plus 267 Python/14 validators; those results are sourced from PR metadata and have not been rerun in this handover. Retain `tests/godot_codefix_regressions.tscn` when porting.

## Canonical constraints — do not rewrite
Five founding offices; exactly three unique independent Writs for quorum; six RPG attributes; the consensual public Rootkin hearing with **Press, Attune, Brace, Observe, Withdraw**, unlimited retries; three Custodians; six constituency eligibility checks; revocable three-vote mandate; 24/36 finite rail capacity with staged != boarded; finite Energy and Correction; four terminal endings including True Dawn evidence and consent gate. No repeat rewards or duplicated action IDs. No talking after NPC death; Nix only narrates witnessed events. Brin Harker and Sister Ossa remain civilians; saved intimidation under 60% HP. Hearth Nine should eventually be enemy-free but existing tutorial combat needs migration to a separate area, not deletion.

## Next sequence
1. Import the actual verified 08.7 archive on a new branch from current `main`; keep all game binaries and code, exclude `.godot/` and ZIPs.
2. Port PR #3 fixes per file after comparing to 08.7; rerun full regression suite and screenshots.
3. Reconcile all changes with new registry. Integrate only downloaded, byte-verified Runway assets (never task IDs alone).
4. Validate all 8 districts, old and new saves, safety of resource limits, Rootkin consent, four endings, enemy animation and FPS feel.
5. Open a **draft** PR. Do not automatically merge, force-push main, or delete historical branches.

## Validation after importing Build 08.7
```bash
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
godot --headless --editor --path . --quit
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_scene_smoke_084.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_witness_threat_085.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_hud_086.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_asset_runtime_087.tscn
# After PR #3 cherry-picks/port:
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_codefix_regressions.tscn
```
Expect Godot 4.4.1. Tests are smoke checks, not a replacement for human playtesting.
