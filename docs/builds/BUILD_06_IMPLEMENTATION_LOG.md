# Build 06 — implementation log and boundaries

## Completed in project source

- Preserved Build 05 source, art, Godot first-person controller and Build 04 Sootworks quest routes.
- Added `scripts/basilica_builder.gd`: distinct physically modelled **Flood Basilica** with collidable floor, perimeter, public/keeper partition, functional water/worship infrastructure, separate Writ hearing and office sites. Decorative flood sheet/field ring do not block routes.
- Added `scripts/ossa_actor.gd`: damageable Sister Ossa sprite; death becomes a persistent unique witnessed event and disables living aftermath.
- Added explicit Ossa NPC arc stages, original source reel, four authored outcomes, separate recorded finite material/reputation costs, inventory receipt for canonical Choirbreaker on help.
- Added Faith Writ unique office ID and three supported transfer methods: congregation vote, Tech 5 signal-bus isolation, or Cantor combat/registry succession; transfer grants 165 XP once.
- Added Bell Wretch signal keeper/enforcer model with a powered control bus, persistent HP/hostility/fate, and override after isolation.
- Added `hearing` authoritative per-attempt state: free public Rootkin loaner, one active participant, `Press/Attune/Brace/Observe/Withdraw`, pressure integrity, strain, observed rhythm, brace guard, append-only command transcript, free retry, no creature ownership reward, 110 one-time XP.
- Added three-district municipal travel, new Pressure Docket objectives, Build 05-compatible state migration and truthful zone-specific Nix death archive.
- Added three original tile materials and three original transparent 2D character/creature drawings. Preserved Build 05 Runway optional-import workflow.

## Deferred / NOT implemented

- No Canon Edda arena, no two-Writ lift, no resulting slice ending yet.
- No full three-of-five quorum runtime, no final three other districts, no four final endings, no alternate Custodians.
- No full sprite animation/8-angle turnarounds; Ossa and Echoforms are single-angle placeholders.
- Choirbreaker is **awarded as a unique recorded item** but has no working weapon-switch/fire system yet; only the Covenant Pistol is interactive.
- Godot movement, enemies, navigation clearance, door/path reachability, audio and controller use were **not executed in this environment**.
- This Build 06 authored district is fixed map geometry; the full bounded procedural reconstruction architecture remains a planned future gate.
- Limited reference five-resource impacts are recorded on the event ledger, but the general unified source-backed stock/economy system and all per-item effects remain unfinished.

## Checks actually run

`python -m unittest discover -s tests -p 'test_*.py' -v` — 31 source contract tests; PASS.

`python tests/validate_project.py` — 14 master/data and lexical source tests; PASS.

These tests examine Python models, references, text, script structure, source IDs and PNG integrity. They do not compile or execute Godot GDScript. Godot executable could not be obtained in this execution environment. A run of this actual project remains an open acceptance gate.

## Canon notes

- Master Bible §9 five shared hearing commands override archived species move tables; public loaner is *not* a caught creature.
- Four Ossa stages remain encounter/investigation/decision/aftermath. No posthumous speech.
- Power and mnemonic correction remain separate and finite. The sixth-note signal concerns coercion, not all of the congregation's faith.
- The full game still requires three unique Writs. Build 06 has two of the future slice's possible Writs, **without** creating an ending.
