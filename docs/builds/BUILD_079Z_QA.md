# 07.9Z QA — verified and unverified

## Executed

- `python3 -m unittest discover -s tests -p 'test_*.py'`: **241 passed** (4 new since 07.9Y's 237).
- `python3 tests/validate_project.py`: **14 validations passed**.
- ZIP verified with `zipfile.testzip()` and a complete member listing. Source extracted from `The_Ninth_Exhale_Build_079Y_COMBAT_POLISH.zip` before editing.
- 32 eight-view atlas image files (sentry, enforcer, millwright, cantor, eight angles each) checked for PNG signature and 768 x 768 pixel bounds.

## Not executed

- **Godot 4.4+ editor import/F5/physics/scene execution.** No Godot binary was available.
- Manual aiming, camera-facing occlusion, visual beam anchoring, NPC tint/direction, save migration, frame-rate, music balance, human engagement testing.
- Runway export download/import, connected GitHub full-source push.

## High-priority runtime QA script

1. Import in Godot 4.4+ and run a clean F5, test new and active older saves.
2. Start combat in Hearth, Sootworks and Flood Basilica. Watch amber projected lane for ranged windups. Confirm the lane disappears on interrupted attacks, death and isolation; crouch behind sealed cover, move laterally during windup; verify no shots hit through cover.
3. Stand behind an occluding wall while a shootable fixture bursts; confirm only exposed targets stagger and affected/not-affected HUD truth.
4. Fire at living Brin and Ossa in a disposable test attempt: inspect reaction and ensure no posthumous speech. Also verify uninjured idle and talking cycles and eight-direction sprite pivots.
5. Reload after fixture discharge and quest choices; confirm no repeated resources, XP, Writs, testimony, votes, passengers or dead actor restoration.
6. Assess 640x400 visibility and visual overload at high enemy density. Compare projectile line cues against sound and muzzle flashes.

Static contract tests are not engine-playability tests.
