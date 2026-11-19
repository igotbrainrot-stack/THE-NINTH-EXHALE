# Build 07.5 — Implementation changelog

## Phase 1: Ashmarket level and audiovisual foundation

- Added `scripts/ashmarket_builder.gd`, a 52 × 44 m collidable floor plan with multiple traversable aisles, physically present economic infrastructure, legal records and linked rails.
- Added multiple service rail routes in Hearth Nine, Sootworks and Flood Basilica; route state and positions persist on save/load.
- Added distinct lighting support in `scripts/main.gd`, `scripts/district_mood_074.gd`.
- Added three new original procedural tile textures and their generator `art/tools/generate_ashmarket_art_075.py`.
- Added a distinct original retro-phonk exploration loop `assets/music/ashmarket_bonded_hours.ogg`, sourced from deterministic synthesised composition `art/tools/generate_ashmarket_music_075.py`; registered the music with `scripts/adaptive_music_072.gd`.
- Added `assets/sprites/enemies_075/collector_1..8.png` and playable Collector security; visuals use adapted 07.4 enforcer base as an interim rig, **not an independently drawn complete Collector**.

## Phase 2: branching Trade Writ and original material side quest

- `scripts/run_state.gd` adds `trade` default fields, first-witness evidence, public coalition, counting lock power/labour costs, intimidation evidence and relationship penalty, combat registry succession, and distinct `qobj_writ_of_trade` ownership.
- One source and one transaction per public evidence/side quest. All new events use unique IDs; recurring visits cannot duplicate XP or supplies.
- Distinct physical water tank, public tariff investigation, and authored Price of Rain resolution. No Air/Correction resource fabricated from water.
- Collector defeat connects to the existing enemy model, attack telegraph and death state; registry survives the keeper.

## Phase 3: attribute milestones and public quorum

- Two finite attribute points at levels 3 and 5 (per V6 bible). Select via Tab dossier and persist in active attempt; old saves receive missing milestone claims but no duplicates.
- `register_three_writ_quorum()` checks three specifically named original Writs, functioning Lung and completed hearing. It stores *verified quorum* only, not an ending.
- New physical public authentication console at Hearth Nine.
- Dossier objective and run-plan copy explicitly separates three playable offices from unimplemented procedurally featured future districts.
- Retained the two-Writ development-slice Edda confrontation as a distinct compatibility route.

## Source and implementation files

`run_state.gd`, `main.gd`, `world_builder.gd`, `sootworks_builder.gd`, `basilica_builder.gd`, `ashmarket_builder.gd`, `player.gd`, `game_ui.gd`, `enemy.gd`, `start_screen.gd`, `district_mood_074.gd`, `adaptive_music_072.gd`, material/audio/collector assets, three art tools and `tests/test_build075_ashmarket.py`.

## Test scope

Python source/regression tests, project/data validation, decoded textures/atlases, Ogg header, and approximate 2D map reachability. There is **no actual Godot F5 compilation or combat playtest** in this environment. See manual QA.
