# Build 07.2 — Manual Godot QA

Automated checks are not equivalent to launching the game in Godot.

1. Import the project in Godot 4.4+; press F5. Check title music plays quietly and menus work.
2. Enter Hearth Nine and start a new Witness (or resume a prior attempt). Test game camera and all existing intro actions.
3. From the title, open the **NPC Rotation Gallery** and **Enemy Sprite Gallery**: change all 1–8 views and ensure a stable scale and constant ground contact. Validate 0 mode only for intentionally universal billboards.
4. Visit Sela, Oren, clerk, Brin and Ossa. Verify the new 4-frame ambient idle doesn't create foot-hop or a harsh seam across the torso.
5. After a crawler/enemy becomes hostile within ~23m, verify the exploration theme smoothly transitions to combat music. Defeat it or retreat; ensure the combat track remains ~7s before smoothly returning to the district theme.
6. Approach story-critical non-hostile enemies (Millwright/Cantor) without starting combat. Confirm the score does not wrongly enter battle until aggression.
7. Travel to Sootworks and Flood Basilica: verify unique ambient themes, no repeated music players or scene-loop pops.
8. Press F10 in title and in-game to mute/unmute music. Confirm existing attack/feedback SFX still play, and F5/F9 save/load works.
9. Test each optional enemy and the Edda regulator; inspect telegraph audio clarity under combat track. Test that enemy deaths immediately release the battle state after the hold period.
10. After exporting Runway source files, run both importers and repeat rotation/collision/leg-pivot checks; manually correct any AI turnaround with wrong left/right equipment or perspective.

## Automated

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
```

## Open risks
- Godot audio stream loop settings must be confirmed live; the embedded Ogg loops are short instrumental *sketches*, not the richer Runway-composed music.
- The Runway eight-view sheets may require manual cell-level corrections even though every character generation completed.
- Current enemy frame atlas action states remain prior procedural animation until full new hand-authored cycles are made.
- NPC idle strips are subtle secondary motion, not a full walking locomotion system.
