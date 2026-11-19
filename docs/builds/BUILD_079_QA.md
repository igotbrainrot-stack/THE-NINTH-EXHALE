# Build 07.9 QA — Source Pass / Engine Playtest Still Required

## Automated source and asset checks

From the extracted Godot project root:

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
```

The new source tests cover three warning cycles, finite resource accounting, scene hook presence, actual LOS checks, staggered enemy commitments, physical safety levers, floor-art/audio exports, old-save additive migration and fact-driven hearing/assembly visuals. These are **not** substitutes for an engine or user playtest.

## Immediate Godot 4.4+ smoke test

1. Extract into a new folder; import `project.godot`; use F5. Keep the known working previous build.
2. Check `Debugger → Errors` and Output for parse errors/missing textures/missing WAV import references.
3. Title → new attempt: relay / crawler / valve. Confirm crawler rush still works and electrical marker only activates during the alarm. Move away to avoid it; use E on its safety lever; shoot the lever in a second attempt.
4. Save/load mid-fight and after isolating. Confirm no duplicate resource spend, event or hazard reactivation.
5. Test all four RPG builds with no ammunition; F must remain usable and firing cannot create free ammunition.

## Three distinct combat encounters

**Hearth Nine** — seed 100: small readable electrical arc; 4 HP, marked floor; no activation before relay, no activation after valve phase; the main shutter remains accessible.

**Sootworks** — seed 101: Millwright may be confronted or bypassed as before. If hostile, pressure floor rises on a different period. Use cover, shoot a finite pressure cylinder, then optionally isolate the repeating cycle. Test a peaceful Brin-help save: the pressure cycle should remain quiet.

**Flood Basilica** — seed 102: provoke Cantor only if wanted; during hostility the large marked disc reduces Breath (not Health) while active. Try the safety lever during warning (should reject) and during its low-note interval (should record once). In the Rootkin hearing, observe the real-world disk change with Rising/Shielded/Exposed and actual strain/integrity. Quiet tuning should provide one observation, not skip the hearing. Ossa help should silence the hostile pulse.

## Main narrative regression

- Cinder Lung: fight, Tech, bargain and theft routes; claimant ward shortage still recorded.
- Any three distinct Writs from five; mandatory Echoform hearing still free and voluntary with Press/Attune/Brace/Observe/Withdraw.
- Brin and Ossa alive/dead outcomes; no posthumous speech.
- Two-Writ development slice remains separate from full three-Writ core.
- Core Custodian resolution and assembly gate; no ending before required facts.
- All four canonical endings, True Dawn survey/root/cipher/mandate, finite staged/boarded seats, terminal immutability.
- At least 3 seeds × 4 character builds × different Writ order (manual matrix).

## Performance/UX checks

- Proximity music transitions, new positional warning effects and gunshot sound levels.
- Narrow corridors and floor hazards at 640×400: warning colour must be legible; sprites must not clip; disable switch must be visible and reachable.
- Confirm `game_ui.gd` fullscreen brief damage flash does not block mouse input.
- Shoot a wall, a machine, a NPC and a living combatant. Check material impact effects and no unexpected damage to civilian NPCs from visual code.
- Watch Sootworks/Basilica hazards deactivate after legitimate nonviolent resolution and across save/loads.
- Reopen assembly and update constituency votes/rail staging; visible indicators must show only actual recorded facts.

No engine test or human playtest is being claimed in the source handover.
