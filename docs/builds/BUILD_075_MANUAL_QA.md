# Build 07.5 — Manual Godot acceptance and playtest

**Requires Godot 4.4+ and a new extracted folder.** Automation does not substitute for the checks below.

## Engine startup

1. Import `project.godot`, run **F5**, inspect editor Debugger/Errors and Output for parser errors, missing textures or Ogre collisions.
2. Title → Enter Hearth Nine → New Ninth. The existing 07.4 intake relay, crawler, valve and Sela Lung transfer should all still work unchanged.
3. Resume a copied 07.4 active save, check old Writs, dialogues, hearing and Cinder Lung states. New Trade fields should appear without changing prior recorded decisions.
4. Confirm title galleries and NPC/enemy 8-view rotations still work.

## Ashmarket traversal and content

5. Install the Lung and travel to Ashmarket at the Hearth Nine rail console. The zone must load; player must spawn near x=-21,z=9, not inside a wall/desk.
6. Walk from the starting market aisle to the physical original contract archive (-20,-12), buyer testimony (-20,6), buyer council (-18,14), cistern (-6,-17), counting lock (18,-8), Collector office (14,4), public Trade registry (20,14), and return rail (-22,19). Objects must be accessible using E without clipping or impossible angles.
7. Return from Ashmarket to Hearth Nine, Sootworks and Flood Basilica. Confirm each region persists and the travel option remains available.
8. Check all four original light points, three procedural materials, 3D canopy/stalls, and distinct ambient music. No static props should face/rotate toward the player.

## Route acceptance (do these on separate new attempts)

9. **Mechanist:** Tech 6 -> counting-lock isolation costs 2 Energy and 1 Labour -> public registry grants Trade Writ. Confirm no second transfer and original evidence is still readable.
10. **Breaker:** Force 6 -> intimidate Collector -> Trade relationship penalty recorded -> registry signature transfers Writ. No repeat intimidation reward.
11. **Witness:** Acquire XP from Hearth Nine, Sootworks, Flood Basilica and hearing. At levels 3/5, press TAB and allocate two points to Speech, reaching Speech 7. Inspect duplicate contracts, witness testimony, record buyer coalition -> present to Collector -> obtain Writ. Confirm zero XP duplicates.
12. **Combat:** Trigger Collector, check visible telegraph and movement, defeat him, claim surviving Trade Writ via public registry. Keep the market physical witnesses and records accessible.

## Side quest and finite resources

13. Investigate cistern physical dial. In different attempts choose open public tank or private levy. Verify the public path costs real Labour/Energy and both outcomes are retained after leaving/reloading.
14. Claim market emergency locker once. Confirm second visit and save-load do not restock Ledger Slugs or medical items.

## Three-Writ progress and existing trial

15. With Lung + Labour + Faith + Trade + passed Rootkin hearing, return to Hearth Nine, operate THREE WRIT PUBLIC AUTHENTICATION. Must record once and clearly state the remaining chapters are not finished.
16. Without any of those requirements, the desk must refuse and the dossier must identify missing progress.
17. The old 2-Writ Edda development trial must still be accessible independently and must not claim the canonical Liberation/Dominion/Crown/True Dawn endings.

## Visual/performance/UX

18. Test camera-visible Collector from all 8 directions and in attack/walk/hit/death. Current visuals are a deliberately provisional service-officer derivative; note if silhouette lacks identity.
19. Check notification/interaction prompts, the new Ashmarket objective chain and tab dossier stat choices. Menu options are in a scrollable modal.
20. Check 640×400 retro viewport, contrast under GL Compatibility, ambient/combat audio transitions and absence of clipping/shimmer.

**Pass criterion:** all main routes physically reachable, no GDScript parser/runtime errors, old state/load preserved, no reward multiplication, and at least one noncombat and one combat path played end to end.
