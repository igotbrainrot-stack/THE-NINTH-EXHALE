# Build 09.2 completion gap register

This is a completion tracker, not a claim that the full game is finished. Statuses separate reference data, runtime implementation and QA verification.

## Verified baseline

- Godot 4.4.1 Linux project import and packaging succeeded.
- **290** Python tests passed; **14** project validations passed.
- Godot animation tests: **18/18**; perception: **25/25**; HUD overrides: **8/8**; scene smoke and weapon-art loader checks passed.
- The new procedural intervention-jab fallback was tested for both missing and authored intervention strips.
- Both full-campaign policies completed: combat reached **VESPER / LIBERATION** at 361.0 simulated seconds; pacifist reached **VESPER / LIBERATION** at 361.2 simulated seconds.
- Both runs obtained the Labour, Faith and Trade Writs, reached Assembly, and passed the living-witness invariant (**0 records without a living witness**).
- Campaign test summaries: combat averaged 58.6 FPS (minimum 12); pacifist averaged 65.1 FPS (minimum 18). These minima are a performance follow-up, not an acceptable final performance claim.
- The headless exit reports 3 resources still in use; investigate cleanup.

## Remaining production gaps

| Area | Bible target | Current runtime status | Acceptance gate |
|---|---|---|---|
| Weapons | 16 | 4 runtime weapons | Add remaining 12 with original assets, distinct fire/reload/dry/draw/intervene, audio, acquisition and tuning; test each. |
| Mods | 20 | Reference catalogue exists; gameplay integration incomplete | Mod slots, costs, effects, exclusions, UI, save migration and tests. |
| Armor | 8 sets | Reference catalogue exists; runtime coverage incomplete | Mitigation, tradeoffs, acquisition, inventory UI and balance tests. |
| Consumables | 23 | Limited runtime inventory | Effect, finite uses, HUD, ledger record and tests for each. |
| Echoforms | 12 | Limited hearing/contract integration | Distinct creature behaviors, acquisition/contract/release systems, art and encounter tests. |
| Major NPC arcs | 8 | Brin, Ossa, Venn and Kest have runtime arcs; others need implementation/review | Multi-stage branches, outcomes, NPC survival, reward and ending carryover. |
| Local storylets | 20 | Catalogue data exists; runtime delivery not fully verified | Random hooks actually appear, are completable, record run-specific evidence and cannot soft-lock main route. |
| Districts | 5 founding offices | Five district builders plus Core, Assembly and Lift exist | Full route verification for every office, three-of-five Writ quorum, optional routes and no soft locks. |
| Endings | 4 terminal outcomes | Ending code exists; Liberation verified in both playbot policies | Direct tests for Dominion, Crown and True Dawn; narrative review of all endings. |
| Safe hub | Hearth Nine enemy-free | **P0 gap:** current 09.2 spawns the enforcer, intake crawler, optional hostiles and an environmental hazard in Hearth Nine. | Move opening combat and Lung reserve to a separate Intake Annex. Test zero hostiles/hazards in Hearth Nine on new, mid-intro and post-intro states. |
| Audio | Distinct hub, district, battle and ambience; weapon/NPC cues | Existing and procedural fallback audio | Human device check, mix, clipping, cues and distinct zone tracks. |
| Art/animation | HUD, enemies, NPC states, world detail and weapon states | 4 weapon drop-ins; many fallback sprites/states | Native-resolution visual audit, no missing art, unique states, anchors/timing and NPC animation review. |
| Save/reprint | Roguelite death record/reconstructed run | JSON save/profile and run-state logic exist | Old/corrupt save migration, death archive, reprint continuity, ending profile and crash recovery. |
| QA/release | Full campaign, side quests, balance, accessibility and performance | CI and two scripted policies reach Liberation | All endings, side content, human playthrough, performance profiling, controls, accessibility and Linux release sign-off. |

## Completion order

1. **P0 safe hub separation:** move hostile encounters, intro crawler, Lung reserve and service controls to a separate Intake Annex; add a regression test.
2. **P0 campaign acceptance:** test all endings and alternate routes; investigate the low FPS minimums and resource cleanup.
3. **P1 weapon runtime expansion:** remaining 12 weapon identities, gameplay, original art and animations.
4. **P1 NPC/sidequest completion:** remaining arcs and fully verified randomized storylets.
5. **P1 inventory systems:** mods, armor, consumables and Echoforms.
6. **P2 art/audio/balance:** missing assets, music/SFX, visual polish, accessibility and human QA.

No release-complete claim until the safe hub and all P0 gates are closed and the remaining scope has been accepted.
