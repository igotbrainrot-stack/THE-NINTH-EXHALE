# Build 06.7 — Living Wards: actual source changes

**Baseline:** Previously prepared Build 06.6, descending from the owner's confirmed functional but boring 06.5. No files rebuilt from scratch; original story, side quests, item IDs, health/ammo rules and two-Writ *test* ending remain. This is a targeted interaction and encounter pass, not a claim that the full game has been completed.

## Changes

1. **`scripts/enemy.gd`:** committed-direction 0.38-second crawler rush (not perfect homing), plus conditional lateral positioning for Millwright and Cantor. Warning and recovery remain. Seeds determine a reproducible strafing direction after attacks.
2. **`scripts/pressure_fixture.gd` (new):** shootable/strikable one-use cylinder with exposed status ring, working collision layer for weapon raycasts, damage threshold 14 and spent visual state.
3. **`scripts/main.gd`:** three combat-area pressure vessels in Sootworks, Basilica and test Lift; discharging near a keeper interrupts its attack for 2.8 seconds and within 4.5 m applies 10 mechanical impact. Visible feedback, sounds and source-backed finite consequences; no repeat XP. Also includes nonblocking objective pointer and direct physical discovery interactions.
4. **`scripts/run_state.gd`:** additive `pressure_067` and `discovery_067` fields for existing save migrations, zone-specific one-use proof, ledger source record, one worker relief item, and optional Basilica hearing observation. No old state/event keys changed.
5. **`scripts/ambient_machinery.gd` (new):** fixed-location 3D rotating municipal service fans and subtle status lamps, not billboarded furnishing.
6. **`scripts/sootworks_builder.gd` / `scripts/basilica_builder.gd`:** two optional cache consoles near existing alternative-route entries. The original mandatory centre passages remain.
7. **`scripts/game_ui.gd`:** unobtrusive pointer and source-record summary in Tab dossier.
8. **`assets/textures/pressure_vessel_067.png` + `art/tools/generate_pressure_texture_067.py`:** original deterministic industrial material art, no third-party image files.
9. **`tests/test_build067_living_wards.py` (new):** runtime-independent source, provenance and approximate navigation contracts. Two previous tests were updated to recognise valid immediate-E handler pathways as well as `match` cases; no checks removed.

## Design / canon guardrails

- Combat devices are not magical pickups and never create Energy/Correction/Air; each event is single-use and accounted for. If Energy is already zero, discharge is physically permitted without a negative resource value.
- All Writ recovery routes, four-stage NPC lives/deaths, free Rootkin loaner and five civic hearing actions remain intact.
- Full canonical campaign requires three distinct Writs; the two-Writ Lift and Edda record here are a **development test** only.
- No new licensed/copyrighted media is introduced. The previous locally produced original character, world and weapon assets are retained.

## Deferred

Actual Godot parser/physics run; human playtesting; better full 3D cover AI; multi-angle walking sprites; full five-district/three-Writ campaign; four canonical endings; GitHub binary project push.
