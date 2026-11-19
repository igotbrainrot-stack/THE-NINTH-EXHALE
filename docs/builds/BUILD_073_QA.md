# Build 07.3 Godot & Art QA

## Automated regression

```sh
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
```

Both commands were executed in the current sandbox, not through the Godot engine. Verify expected pass counts against the packaged `docs/BUILD_073_TEST_LOG.txt`.

## Manual in-engine test (F5)

1. Extract to a NEW folder and import `project.godot` in Godot 4.4+.
2. From title screen choose **ENEMY GALLERY**.
3. Pick Sentry, Enforcer, Millwright, Cantor, Edda machine, Chain Hauler, Bell Wretch and Rootkin.
4. Use UP/DOWN to inspect angles 1–8. Check for distinct front, front-left, left, rear-left, back, rear-right, right, front-right. Angle 0 intentionally uses the universal view.
5. Press **T** to compare the 07.2 front-copy sprites and new 07.3 3D-turntable sprites.
6. Press SPACE for attack/walk proxy animation; verify feet do not teleport across the sprite base, and inspect eight-direction boundaries at 22.5° increments.
7. Enter Hearth Nine and fight the intro crawler, then travel to Sootworks, Flood Basilica and the Edda trial. Check combat animations, collision, size, occlusion and fog.
8. Open **NPC ROTATION GALLERY**; all five painted NPCs should still have side and rear views, and working idle motion.
9. Confirm the retro-phonk exploration/combat music, F10 mute, and no changes to save or dialogue states.

## New Runway paintings

Once exported as `sela.png`, `brin.png`, etc. for all 22 identities:

```sh
python3 art/tools/import_runway_true_eight_073.py --source /path/to/22/exported/PNGs --dry-run
python3 art/tools/import_runway_true_eight_073.py --source /path/to/22/exported/PNGs
```

Review the generated `art/previews/BUILD_073_IMPORT_REVIEW.png`; automatic duplicate detection is not enough to validate anatomy, angle order or asymmetric props. The game retains fallback atlases if an external sheet is rejected.

## Unverified

- Godot editor import/compilation, physical runtime, and in-game camera orbit behaviour.
- Semantic correctness of each *Runway* eight-view generation, because those source PNGs remain externally hosted until exported.
- Full hand-animated gait and combat cycles (only timing/motion proxies presently exist).
