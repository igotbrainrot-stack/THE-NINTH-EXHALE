# Build 06.8 QA / actual evidence

## Verified in this environment

- Python unittest suite: 108 tests passed, covering previous Build 06.7 checks plus 11 new tests for enemy counts, identity, provenance, profiles, atlases, non-duplicate events, no-ammo path, intro isolation, deterministic selection, old-save migration, and hearing non-ownership.
- Image checks: 68 RGBA PNG atlases of exact 768×768, 12 opaque-pixel poses per direction with stable 243 px foot baseline in living poses.
- 17 complete Runway generation tasks in connected owner's workspace, task IDs recorded in `data/enemy_roster_068.json`.
- ZIP integrity checked after packaging, and all Python asset tools compile.

## Not tested in this environment

- Godot 4.4+ GDScript parser and runtime (Godot executable unavailable here).
- Actual enemy collision, pathfinding and reachability on the user's PC.
- Enemy spawn load against saved Build 06.7 user save.
- Visual quality/animation and comparative human gameplay engagement.
- Actual high-res Runway images in-engine (not imported yet).

## Quick manual Godot checklist

1. Import `project.godot` into Godot 4.4+. Press F5. First select **ENEMY SPRITE + ANIMATION GALLERY** from the title screen and inspect all 17 subjects (left/right to select, up/down to rotate, space to view attacks); return to the title and start a NEW Ninth.
2. In the first intake, confirm **only the crawler** attacks, its rush warning appears and side-dodging still works. Kill or use intervention; open the valve. Optional Hearth enemies should only appear after the valve opens.
3. Visit Hearth records; test that Registry Bailiff's physical cover is useful and Vent Whistler stays stationary. Use F/right click at zero ammo.
4. Visit Sootworks; observe the seeded two-of-three optional enemies and unchanged Brin/Labour Writ resolutions. Reload a save and confirm no duplicate kills or XP.
5. Visit Flood Basilica; inspect distinct moving silhouettes, hearing Rootkin and Bell Wretch animation, and original Press/Attune/Brace/Observe/Withdraw mechanics.
6. Enter the two-Writ **slice-only** trial to face Edda and a Triage Warden if selected; complete both combat and evidence resolutions.
7. Rotate around an enemy through 360 degrees: the subject should switch front/left/right/back art while its feet do not shift unpredictably. Check chairs and desks do NOT rotate.
8. Test three different `--ninth-seed=...` values (e.g. 14, 15, 16): show different optional enemy pairs, same seed repeats. Test old 06.7 active save and fresh run.
9. Review difficulty before calling the added populations fun or balanced. These are optional seeded encounters, not replacements for the core quests.
