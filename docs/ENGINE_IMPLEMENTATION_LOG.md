# THE NINTH EXHALE — G0/G1 Initial Engineering Log

Date: 2026-11-17. Source authority: user's `MASTER_GAME_BIBLE_FINAL(1).md` and protected originality register. This is the first engine-source pass, not a completed game. The original Weatherloom starter setting has NOT been carried over.

## Created files and mechanical intent

| Subsystem | Actual source file | Current scope |
|---|---|---|
| Godot project and physical scene | `project.godot`, `scenes/main.tscn` | Editable Godot 4 project with a default first-person avatar |
| Existing 3D architecture | `scripts/world_builder.gd` | Authored Hearth Nine, genuine colliders, connected requisition room, service consoles, visible NPC sprites, original materials |
| Player and weapons | `scripts/player.gd` | Body collision, camera, sprint/dash/Breath, first-person pistol raycast, ammo, reload, interaction ray |
| Basic enemy | `scripts/enemy.gd` | Office-enforcer placeholder combat AI, cover obstruction, chase and line-of-sight damage, death event |
| Narrative/RPG state | `scripts/run_state.gd` | Four 18-point six-stat presets, seeded abstract `WorldPlan`, one-time quest XP, finite Lung reallocation, immutable event IDs for supported actions |
| Local saves | `scripts/run_state.gd` | Versioned JSON attempt/profile, temporary candidate write + parse + rename, active attempts, death/failed-loop provenance; not yet crash/corruption fuzz tested |
| On-map quest wiring | `scripts/main.gd` | Sela, Oren, clerk, archive, rack, Tech panel, ammo locker, Nix receiver; bargain, fight, Tech bypass, steal, installation |
| UI | `scripts/game_ui.gd` | Pressure Docket, start presets, contextual interaction, current health/Breath/ammo, status text, read-only dossier, first-person firearm graphic |
| Data canon | `docs/MASTER_GAME_BIBLE_FINAL.md`, `data/master_ids.json` | Master bible copied without alteration; IDs derived from Appendix E and uniqueness-checked |
| Reference catalogue | `data/v6_reference_catalogue.json` | Earlier supplied V6 table retained for mechanical look-up; **historical appearance cells are not art authority**. Use Master §11 for silhouettes |
| Original placeholder assets | `assets/sprites/*.png`, `assets/textures/*.png` | Generated from scratch using Pillow; replace systematically only after in-engine visual QA |
| Local checks | `tests/validate_project.py` | 14 passing source and data checks; does not compile GDScript or test physics |

## G0: partial implementation, not yet passed in Godot

- A Godot project bootstrap, canonical source copy, master IDs, and reference catalogue are present.
- Seeded planning selects 3 featured of 5, 3 NPC arcs, 2 local hooks per featured district, 1 Custodian and 1 hearing district among first two. These **data choices are not level geometry**.
- Six attribute presets, XP thresholds, initial inventory and a transaction event ledger are wired. Full 18 perks, equipment catalogue runtime instantiation, typed Godot Resources, persistent RNG stream states and gameplay tests remain open.
- Prototype `RunState` deliberately has no fabricated Writs, NPC arc victories, hearing pass or ending.

## G1: source implemented, Godot verification required

- Controller uses `CharacterBody3D` + `move_and_slide()` and a capsule, rather than the earlier fictive collision proof.
- Pistol uses a physics ray from the current camera against colliders, 24 base damage, 0.42-second attack spacing, six-round magazine and 1.8-second reload. Enforcer HP target 70. These are **provisional** V6 targets.
- The ward is a hand-authored static area with a real floor, perimeter, service partition and accessible doorway. The project has no instantiated navmesh test or procedural layout validation.

## G2: first authored quest prototype, not a finished district

- Full route names are `fight`, `bargain`, `tech`, and `steal`; only one reservation can be claimed per attempt.
- Bargain needs the actual public record and Speech+document >=6. Tech needs Tech >=5. Assault needs the enforcer to be defeated in physical gameplay. Steal uses the real rack and imposes a claimant-ward relationship cost.
- Returning the acquired module to Sela yields the **single** `hearth.lung_installed` event and 140 unique XP. It subtracts one Energy and one Correction integrity while reallocating 8 ward units from 5 claimant + 3 idle capacity. It creates neither a free spare nor new mnemonic correction.
- The finite emergency ammo locker can be claimed once and is never restocked by room reentry.
- On observed combat death, the run is sealed; retry creates a new seed and the analogue Nix references only that chain's recorded death(s). New Game by a separate route intentionally begins a fresh counterfactual chain.

## Automated validation in this execution environment

Executed:

```
python tests/validate_project.py
Ran 14 tests in 0.029s
OK
```

These tests check schema counts, ID collisions, resource strings, required source calls, asset PNG integrity, source-level interaction coverage and a crude lexical bracket scan. **This is not Godot parsing, scene import, 3D collision testing, screenshot evidence, or human playtesting.**

The installed tools did not include a Godot binary and network download was unavailable. Therefore project launch is **unverified**, and the G0–G2 engine gates are not marked passed.

## The immediate next execution order

1. On a machine with Godot 4.7.2, run `godot --headless --editor --path . --quit`, record exact errors, and repair scripts/scenes if needed.
2. Open the game visually; run through one Witness negotiation and one Breaker enforcer fight and document hit responses, movement and collision.
3. Save in the requisition wing while the guard is injured, restart, and confirm exact guard HP, hostility and position are retained.
4. Attempt the 1-time locker and Lung grant 20 times over save/restart; neither may duplicate.
5. Die, reconstruct, and separately start a new game; confirm Nix's speech is truthful in both.
6. Only then implement Sootworks, the first founding Labour Writ with verified public-registry fallback, and the Brin arc's authored four-stage action triggers.
7. Next add Flood Basilica/Ossa, then the physical five-command civic hearing, then the explicit two-Writ **slice-only** Edda test lift. Never silently change the full game's 3-of-5 requirement.

## Unresolved before actual production

Asset polish/Runway multi-angle sprite atlases; weapon inventory/skills/mods; actual SaveCodec migrations/recovery from a crash; capsule door reachability and navigation; NPC witness/death consequences beyond the supported guard; 3D Sootworks and Basilica; hearing; Writ Quorum; endings; controller, auditory accessibility, sound FX, contrast, legal review, six to twelve human play sessions and pacing measurements.
