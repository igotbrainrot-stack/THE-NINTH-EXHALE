# Build 07.9C — Open Issues

## P0 — Runtime proof
Godot 4.4+ was unavailable, so GDScript parsing, environment collision, physical interactions, rendering and FPS were NOT tested. In-engine geometry and material tags must be verified, especially placement of vent lane and annular shelter with player capsule/occluders and save/load.

## P1 — Missing core redesign
- Brin and Ossa still rely on the existing menu sequence, not four compelling spatial beats or independent NPC/worker routines.
- Only hazard shapes/damage footprints were differentiated; meaningful enemy roles, arenas and technical/nonviolent encounter pacing remain to be built and playtested.
- Rootkin remains an authoritative five-command menu with reactive field readout, not the intended physically legible hearing.
- Civic assembly still lacks witnessed debate and rail departure staging.

## P2 — Assets and replayability
- In-game 8-way sprite fidelity remains unverified; Runway assets exist externally but are not imported in this build.
- Art/audio mix, evidence-driven level shortcuts and authored seeded variation are unfinished.
- More detailed per-collider authoring beyond structural `solid_box` objects needs coverage.

Use the uploaded `BUILD_079C_NEXT_AI_IMPLEMENTATION_PROMPT.md` as remaining implementation specification; do not report this partial pass as complete.
