# The Ninth Exhale — after Build 06.5

The current codebase begins in a press bay, teaches first-person movement and combat, opens to the Hearth Nine Lung allocation, then has two Writ districts, a meaningful non-ownership hearing and a short two-Writ Edda development trial. It is **not** a full campaign, and after Build 03 no runtime execution has been independently verified here.

## P0 — live engine verification

- Import 06.5 in Godot 4.x on Linux; fix all parser/runtime errors before more scripted regions.
- Play from NEW NINTH; confirm the intake shutter actually blocks before encounter and opens after the valve, save/load stable.
- Check camera/weapon behavior, starter ammo and damage, furniture geometry orientation, Edda trial collision/AI, and no duplicated event XP or infinite resources.
- Log actual human play time to evaluate the target 20–35-minute slice. Give each outcome an authored consequence card rather than just numerical XP.

## P1 — game presentation

- Replace interim sprite art with completed Runway original PNG exports (three 06.5 images, four 06.4 weapon images, and 21 earlier texture/character/equipment assets) using asset manifest and alpha/pivot QC.
- Give fixed furniture more directional faces or cheap 3D meshes where the flat-plane side view is unconvincing; make some interactable, without obstructing doorways.
- Add practical motion/FX: Lumen pressure gauges, cloth/curtains, ventilation, bolt movement, mechanical repair and weapon sounds. Avoid per-frame AI-character drift.
- Introduce a local quest compass/map or light signage (not giant HUD prompts) so players can leave the initial ward easily.

## P2 — genuine campaign systems

- Expand the existing five-district plan: Ashmarket, Glass Orchard and Quiet Barracks; three unique founding Writs for full-game Lift access; public registry succession for every Writ.
- Implement 3 seeded NPC arcs out of 8 per run, and six short district hooks across the featured regions, with persistent life/death/consequence states.
- Integrate the complete equipment/armour/perk/consumable catalogue and social evidence route alternatives, with finite loot and resources.
- Implement anchored physically-valid MapPlans, seed-specific modular rearrangements and navigation/connectivity/retry tests; completed runs are immutable, new runs are separate.
- Add the non-slice Custodian confrontation, Engine archives, four true full-game endings, and True Dawn evidence/mandate requirements.
- Balance and QA 73–108-minute runs, difficulty/accessibility, performance and save migration.

## Protected original ideas

- Ninth is the ninth printed enforcement template, not canonically someone who died eight times.
- Nix only knows actual recorded failures and is not omniscient.
- Lumen power (Energy) and memory correction (Correction) cannot be interchanged.
- Rootkin is a free public-loaner consent participant, not owned or captured.
- The three first full endings must remain accessible to any build; True Dawn needs the three separate dossiers and a revocable public mandate.
