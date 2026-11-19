# BUILD 04 — ENGINE DEVELOPMENT LOG

Date: 17 November 2026. Base: the user's confirmed working Build 03, copied rather than rebuilt.

## Changed source files

- `scripts/sootworks_builder.gd`: new collidable Sootworks district and public interaction geometry.
- `scripts/brin_actor.gd`: civilian actor with persistent health, optional physical death, no postmortem interaction.
- `scripts/run_state.gd`: persists zone, return locations, independent Millwright/Brin actor state, Brin 4-stage story and Writ event, one-time district supplies, fail-chain-limited Nix provenance; loads Build 03 saves by filling missing state.
- `scripts/main.gd`: both-direction rail travel, new world instancing, Sootworks interactions, routes and dialogue, independent guard callbacks.
- `scripts/enemy.gd`: actor-key abstraction so the Sootworks keeper and old requisition enforcer don't overwrite one another's state.
- `scripts/player.gd`: remember per-zone positions; guard against a reload completing in a different attempt/area.
- `scripts/game_ui.gd`: current-zone objective, Labour Writ, Brin and reward records.
- `scripts/world_builder.gd`: rail label matches the newly implemented Sootworks link.
- `scenes/main.tscn`: build number/story description.
- `assets/sprites/brin.png`: original low-res placeholder generated procedurally; no third-party sprites.
- `tests/test_build04_sootworks.py`: new source invariants for distinct Writ IDs/route calls/actors.

## Canon and constraints

Original V5/V6 master unchanged. One Writ of Labour, actual source-backed original payroll, settled debt 43 years previously, a live Council + physically available post-keeper registry. City energy and correction remain separate. Brin's outcome is not auto-selected by world seed. Rewards give different advantages, and their full inventory functionality is future work. In this staging slice, Sootworks and Brin are fixed authoring anchors even if a future full-run WorldPlan selects a different trio of featured districts. A successful ending has not been implemented, so no fake win state is generated.

## Verification

`tests/validate_project.py`: 14 source/data tests passed.
`python3 -m unittest discover -s tests -p 'test_*.py' -v`: 14 supplemental source/startup tests passed (seven Build 04, two typing, five startup).
No Godot binary available in this sandbox. No live collision/nav/combat/3D FPS playthrough, human run timing, item equip UI or original art review executed. User will need to import this Build 04 project for the **actual** Godot compile and gameplay confirmation.

## First player acceptance walk-through

1. F5, start Witness, source-evidence bargain for Lung and install at Sela.
2. Use the rail console by the requisition corridor to enter the new Sootworks level.
3. Meet Brin, collect original payroll, return and investigate, support a safe strike at the Worker Council, return to Council for one Labour Writ, confirm +165 XP and Writ 1/3, find Brin for aftermath.
4. F5 save, F9 load and/or restart editor: district, council decision, acquired Writ, office keeper state and finite supply issue remain identical. Repetition does not award another Writ.
5. New Breaker run: obtain Lung through combat/theft, access Sootworks, challenge and defeat Millwright, claim Writ at public registry without Brin. Ensure no softlock when Brin is killed.
6. New Mechanist run: Tech 5 isolates regulator and costs Energy/Labour, then take Writ at Millwright board.
7. Verify shooter collider and NPC death warning by shooting Brin. No living Brin conversation should be offered after death; the Writ must remain obtainable.

If Godot reports a parse/runtime error, do not mark engine validated. Record the exact line and update the project without changing the canonical bible.

**Final intervention correction:** Disabling the Millwright control bus now also stops the actual powered keeper's chase/attack logic and changes the sprite's signal colour. This avoids a dialogue-only sabotage outcome. A separately defeated keeper still requires the real public registry to claim the Writ.
