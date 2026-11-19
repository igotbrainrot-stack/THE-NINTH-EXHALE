# Build 06.5 — implementation and test record

## Changes on top of the unchanged 06.4 game base

- New authored Hearth Nine intake bay walls, a physical lockable shutter, reprint pressure relay and a manual valve.
- A two-shot (Covenant Pistol at close range) hostile inspection crawler; 32 HP, 4 damage; alarm/combat/repair records separately once, with no respawning or duplicated XP.
- Short first-awakening modal and stage-sensitive objective in the Pressure Docket.
- Fix for rotating furniture: `Sprite3D.billboard = BILLBOARD_DISABLED`, double-sided fixed standees, authored yaw and 3D underframes for furniture. Creatures and NPCs remain camera-aware.
- New title background uses a previously generated original Hearth Nine painting; new transparent original fallback sprite for inspection crawler. 3 new Runway productions in external workspace, not misreported as in-zip originals.
- Additional physically built short Freight Lift test chamber and Edda hearing. Requires exactly Lung + the two existing distinct Writs + the completed hearing for this **development-slice gate only**; preserves three-Writ rule in the master bible. Evidence/forced shutdown/continuity routes are different and recorded. All consume finite sourced machine/staffing resources; no zero-cost creation.
- Existing Brin, Ossa, original five hearing commands, honest event records, acquisition methods and weapons retained.
- Old 06.4 save migration opens intake shutter instead of softlocking a character whose timeline predates this new prologue.

## Static tests and limitations

- 69 Python source/regression tests passing, including 10 new 06.5 tests.
- 14 project source/data validations passing.
- Grid flood fill of collidable authored opening boxes found the starting bay connected to wake and valve while shutter closed, clinic and east wing unreachable until shutter opens, then both reachable. This is a **geometry estimate**, not actual Godot navigation/physics validation.
- Zip integrity and Python art asset validation should be rechecked at package creation.
- **Godot runtime unavailable** — no claim that new GDScript compiles or F5 playtests have passed.

## Required manual Godot test

1. Extract a new folder. Import project.godot. Press F5, choose new Witness. Verify full viewport title and first modal.
2. Move / aim in intake. Verify you cannot pass north through shutter, but you can approach wake relay and valve. Press E at wake relay.
3. Verify crawler appears **once**, is visible, fires for low damage, can be hit and defeated, and does not respawn if saved/reloaded. Verify ammo and HP rules.
4. Verify valve becomes usable, opens the shutter, and the player physically passes into main ward. Save with F5, reload F9, ensure door stays open and no duplicated XP.
5. Walk around hospital bench, desk, foundry workbench and Basilica pew. Props must not billboard around camera. Check whether the standee depth and static mesh supports are acceptable.
6. Sela/Clerk/Lung four outcomes; transfer to Sootworks and Flood Basilica, acquire two Writs and complete hearing; return to Hearth, inspect trial berth.
7. Test Edda petition → public mandate; a fresh attempt with completed prerequisites → apparatus defeat → physical shutdown; a fresh attempt → continuity. Ensure resources decrease once and state persists on save/load.
8. Check F5 output for GDScript parser/scene issues, shadows, frame rate and collision. Any engine error must be fixed before calling this release playable.

## Not yet implemented

The final full five-district procedural campaign, True Dawn discoveries, three-Writ terminal Lift, full equipment/armour/perks, extensive enemy AI, character animations, mature combat balancing and four canonical endings. This is a development-slice **source build**.
