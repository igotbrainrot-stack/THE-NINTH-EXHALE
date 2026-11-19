# Build 07.7 implementation — phase log

**Base:** Build 07.6 First Signature. All earlier scenes, zones, content, stable quest IDs, save schema 1 and original three office routes retained.

## Phase A: Growth
- `scripts/orchard_builder_077.gd`: physical nursery and research district, service and interaction locations, practical lights and visibly separate rooms.
- `scripts/run_state.gd`: original control sample, independent research vote, Tech 5 finite feed isolation, powered apparatus flag, three durable registry paths, original `qobj_writ_of_growth` transfer.
- `scripts/main.gd`: Godot zone building, interaction menu routes, guarded boss and defeat handling, signed evidence.
- Venn meets, records, investigates, decides and reaches real aftermath. Multiple decisions are mutually exclusive; no automatic creature ownership.
- One finite ampoule and original `qobj_orchard_root_seed` artifact in inventory and event log.

## Phase B: Defence
- `scripts/barracks_builder_077.gd`: separate authored military-archive location with staffed cover, soldier memorial, command frame, service stations and gate radio.
- `scripts/run_state.gd`: independent analogue casualty roll and staffed rota, public assembly, Tech 5 signal isolation with 2E/2L cost and succession if command frame disabled; original `qobj_writ_of_defence` transfer.
- Kest's forged warrant and actual original reprint orders, with mutually exclusive choice and documented aftermath. Never retroactively asserts a player killing.
- One finite ampoule and original `qobj_deep_heat_survey` unique dossier item.
- Regional Commandant and central Marshal Voss are explicitly different.

## Phase C: Correct founding-office Quorum
- `founding_writs_recorded_077()` filters five known stable IDs and rejects invalid/duplicate credentials.
- `can_register_three_writ_quorum()` now accepts any three genuinely different Writs, plus installed Lung and completed mandatory hearing.
- One irreversible public authentication event still required before the full central archive. No ending is awarded.
- Preserved older event IDs and old-save defaults using `ensure_build077_state()`.

## Production support
- Four new hand-coded procedural district materials + two original musical loops; a provenance manifest.
- High-detail final eight-angle artwork for Venn/Kest/Gardener/Commandant still pending. No Runway output falsely presented as embedded.
- Updated music key, HUD objective hints, routes and source tests. Previous four-district routes remain.

## Testing truth
- Python tests are data/source and planar clearance checks, not native Godot compilation or human combat tests.
