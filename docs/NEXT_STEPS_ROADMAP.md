# The Ninth Exhale — current progression after Build 05

## Where the playable source stands

Build 03's startup and first scenario were confirmed working by the user. Build 04 added the second district, Sootworks, Brin's four-stage authored scenario and the Labour Writ with evidence/council, Tech, and keeper-death registry routes; it still needs a user Godot runtime check. Build 05 carries those systems forward and adds a non-colliding detailed architecture/material/sprite art pass. Godot runtime is still not available to this authoring environment.

## Ordered implementation gates

| Gate | Deliverables | Must be observed before moving on |
|---|---|---|
| G1 visual/slice foundation (current) | Review Hearth Nine + Sootworks art pass, check save/load, visible consoles, no occlusion of actors | User completes Lung + one Labour Writ path in Godot without new errors |
| G2 Flood Basilica | Authored flood, chapel and service-room modules; Sister Ossa meet/evidence/decision/aftermath; Faith Writ via council, technical intervention or holder-death registry | Return journey, alternate quest branch, nonviolent Writ and registry fallback all tested |
| G3 Echoform hearing | 5 commands Press/Attune/Brace/Observe/Withdraw; loaner Rootkin; actual counter-field; retry and transcript; one active participant; no captured creature prize | Win, lose, Withdraw and retry with no lockout; true five-command input UI works |
| G4 Vertical-slice finale | Slice-only two-Writ Freight Lift; independent analogue evidence; Canon Edda confrontation by at least two methods, conditional end cards | 20–35 min slice actually playable; 2-Writ condition never leaks into full-game 3-of-5 logic |
| G5 Gameplay depth | 6-stat level/perk UI and 7 levels, 16 weapons over time, 20 mods, capped inventory, finite vendors, equipment animation and damage feedback | No duplicate item claims, unique XP awards, guaranteed starter weapon and ammo safety |
| G6 Roguelite | Bounded module assembly with fixed anchors, seeded five district contexts, stream-state saves, run death/new seed/Nix verified testimony, blueprint offer persistence | 1000 layout samples/region pass real capsule collision and navigation fallback checks |
| G7 Full campaign | Five regions, three distinct Writs, 8 optional NPC arcs, 20 short quests, 3 Custodians, 4 endings incl. Dawn tripartite solution + mandate | No mandatory quest/item softlocks, every build can finish; terminal endings immutable |
| G8 Art/balance/accessibility | Consistent 8-angle NPCs/Unsaid and walk-cycles, complete environment texture kit, audio/telegraphs, controller/text sizing and IP QA | Recorded playtests and user review; no legal clearance inferred from AI art |

**Recommended next coding sprint:** Flood Basilica world, Sister Ossa's entire 4-stage quest state, Faith Writ success and succession fallback, plus one short game storylet there. Do not preemptively replace the combat system or create new canon for a single artwork problem.

**Recommended art sprint:** consistent wall/floor modules for all three slice spaces; physically meaningful industrial props, human silhouettes, and the Covenant first-person animation set. Build a single character master/reference before eight-angle baking. Runway is used for design/texture sources, not independently generated walk-cycle frames.
