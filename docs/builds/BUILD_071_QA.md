# Build 07.1 — Manual Godot QA

## Source tests

```
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
```

## Actual in-engine steps still needed

1. Extract the ZIP into a new folder. Godot 4.4+ import `project.godot`, press F5. Verify no GDScript parser errors.
2. From title choose `ENEMY GALLERY`; up/down across 0–8, space toggles walk/attack, left/right changes enemy. Verify all 17 figures, no missing file, no frame flicker or size changing.
3. From title choose `NPC ROTATIONS 1–8`; cycle Sela, Brin, Ossa, Oren and clerk; check the angle order, left/right orientation, art consistency, feet pivot and no pink halo.
4. From title choose `3D PROP GALLERY`: Q/E must step 45° each press. Ensure bed, locker, bench and desks remain genuine meshes with all sides visible; don't make them billboard sprites.
5. In the actual world, approach Brin, Ossa and Sela from front, both sides, diagonals and behind. Expected order: 1 front, 2 front-left, 3 left, 4 rear-left, 5 rear, 6 rear-right, 7 right, 8 front-right. Cross-angle boundaries must not rapidly jitter.
6. During combat, circle the crawler and a human enforcer: ensure sprite plane faces the camera, displayed character direction follows their **local orientation**, attacks and hit/death stay 12-stage animated, no mirror-only errors in asymmetrical equipment.
7. Save/load after acquiring Writs and after actor defeats: no state changes caused by image rotation; original IDs remain constant.
8. Watch for visually imperfect synthetic diagonals on the figures without individually painted eight-angle art. Record those for targeted redo rather than calling them final Runway art.

## Known limitations

- Actual in-engine visual, performance, collision and GDScript compilation tests **have not been run in this environment**.
- Only Brin has newly illustrated, separately generated all-eight views; other new diagonal slots are fixed-anchor interpolations, not true manual redraws. They will need final art direction and especially asymmetric side-by-side inspection.
- All 27 mesh profile objects already support arbitrary viewpoints. For future use as sprites, make eight proper renders from their mesh in an offline bake instead of generating inconsistent unrelated angles.
