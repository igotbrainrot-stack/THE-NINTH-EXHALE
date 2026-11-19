# Build 07.8 → 07.9 Gameplay Comparison

This is a **source and design-contract comparison**, not a recording or measurement of live Godot play sessions. The creator's earlier playtests identified repetition and low engagement; the new build still requires human validation.

| Same authored route / same seed | Build 07.8 behaviour | Build 07.9 source behaviour | Expected player difference (not yet measured) |
|---|---|---|---|
| Hearth Nine, relay → crawler → valve | Crawler rush and one-shot quench vent | Same combat + marked repeating small electrical arc while alarm remains; E safety intervention or shootable breaker; movement avoids it | Player reads floor cues and can decide whether to spend resources on safety |
| Sootworks, Brin → Millwright | Enemy wind-up and finite pressure cylinder, optional bypass | Adds a separate repeating furnace cycle, safe flank, safety lever/rupture, sightline-dependent guard AI | Heat cycle changes positioning and gives consequence to an existing Brin choice |
| Basilica, Ossa → Rootkin/Cantor | Cantor line attack, acoustic resonator, hearing UI | A broader Breath-only acoustic pulse, quiet timing window, field circle reflecting actual hearing numbers | Players distinguish listening/timing from simply trading damage |
| Shooting any solid object | Sound and basic gun movement; most wall hits visually disappear | Short original 3D fragments based on struck material | Aiming and impact have local feedback even on misses against the environment |
| Ranged hostility | Sightline ray checked at moment of damage but actors could still pursue and wind up behind walls | Ranged wind-up requires current line of sight; brief search memory; concurrent nearby wind-ups staggered | Cover and target priority become clearer |
| Public assembly | Register, vote and rail roster described in text | Adds six evidence-driven lamps and visible tokens for registered (not boarded) cohorts | Recorded decisions become physically visible without inventing attendance |

## Actual changed player decisions
- Move around the marked hazard instead of simply absorbing it.
- Use **E** to safely isolate a hazardous machine at the cost of staffed time and Energy.
- Shoot its vulnerable safety switch for a louder destructive solution at a greater Energy cost.
- Time the Basilica isolation to a quiet acoustic interval and carry a factual observation into the existing fair Rootkin hearing.
- Rely on real cover and line-of-sight to interrupt incoming ranged pressure; staggered wind-ups provide distinct reaction windows.

## Same-seed deterministic authoring check
At period start the local hazard uses `float(abs(seed) % 3) * 0.42` as its offset. This changes initial timing but does not choose moral outcomes or hide required stations. The level's authored walls, Writ positions, evidence and mandatory quest route are unchanged.

| Seed | Initial added cycle offset | Safety |
|---|---:|---|
| 100 | 0.42 s | All three physical levers and alternative walking paths remain authored |
| 101 | 0.84 s | Same physics/cost rules, different initial warning timing |
| 102 | 0.00 s | Same physics/cost rules, different initial warning timing |

**Not tested:** Any actual before/after frame time, player completion time, fairness, navigation collisions or enjoyment in Godot. No claim of a full redesigned final chapter or complete procedural level generation is made.
