# Build 08.0 — preliminary combat / animation integration

Base: exact complete 07.9Z ZIP. Preserve all existing progression / quests.

- `scripts/main.gd`: Brin and Ossa directional speaking poses now triggered by the corresponding actual in-world witness interactions; absent actors cannot gesture.
- `scripts/directional_npc_sprite.gd`: separate timed talk and listening state using existing four-frame original idle strips, preserving native sprite bounds/pivot. No claim that missing animation poses are finished.
- `scripts/player.gd`: bounded recoil camera impulse on successful firearm fire, with exported on/off and adjustable strength; ray origin, finite ammunition and core hit code unchanged.
- `ART_ANIMATION_COVERAGE.csv`: honest preliminary per-actor state matrix; all runtime checks marked unverified.
- New tests in `tests/test_build080_animation_and_combat.py`.

Not implemented: three complete authored encounters, full Runway animation replacements, in-engine playtest, complete GitHub source push.

- `scripts/enemy.gd` and new `scripts/combat_corpse_080.gd`: short-lived noncolliding final-death-pose sprite reusing the real final atlas frame; automatically removed on time expiry or district teardown. No rewards or persistent actor duplicates.


## Build 08.0A visual readability patch
- Cleaned first-person weapon alpha edges to remove chroma spill and prevent viewmodel cut-out artefacts.
- Added framed transition portals, guide lights and clearer labels to service rail gates, the Sootworks gate, the freight lift and the public assembly entrance.
