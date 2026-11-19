# Build 07.9C — Partial Spatial Encounter Pass (18 November 2026)

## Implemented, source-level only
- `scripts/world_builder.gd`: physically collidable authored boxes now carry `surface_kind` metadata derived from their material assignment. Impacts no longer have to fall back to stone for these structural bodies.
- `scripts/main.gd`: pending quiet-service confirmation is cleared on world rebuild, loading and choosing a non-quiet intervention; previous 07.9B confirmation/resource safeguards remain.
- `scripts/encounter_hazard_079.gd`: Sootworks now uses a narrow rectangular steam vent damage lane and floor footprint, rather than the shared circular radius. Flood Basilica's acoustic pulse has a physically safe central shelter inside its annulus, visually indicated with a green central disc. Hearth retains its introductory circle. District-specific labels reflect the danger topology. Underlying finite resource costs and shutdown rules are unchanged.
- `scripts/sootworks_builder.gd`: payroll evidence and four established Brin outcomes produce distinct physical props and signage in the existing district, based on saved quest state. No extra Writs, NPCs or resources are created.
- `scripts/basilica_builder.gd`: original hymn evidence and existing Ossa outcomes change physical scene furniture, lighting and signage; no invented testimony or character action is added.
- `tests/test_build079c_spatial.py`: added five source contract regressions.

## Not implemented
Brin and Ossa still progress through existing menu decision logic; this is NOT the required four-beat in-world quest remake. Moving workers, fresh spatial objectives, enemy synergy, Rootkin tactical redesign, civic finale, authored procedural sockets, finished eight-angle sprite repairs, live engine verification, Runway binary imports and audio mix are outstanding.

No save schema or canonical endings changed.
