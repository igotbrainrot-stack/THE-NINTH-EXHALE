# Build 07.8 — Godot Manual QA and Acceptance Checklist

**Status:** Godot has NOT been run by the authoring environment. Complete every engine check below before considering this a stable build.

## 0. Import and baseline
1. Extract in a clean directory and import `project.godot` into Godot 4.4+.
2. Press F5. Confirm menu, Start/Resume, prologue, weapon sprites, music and Five-Writ rail link.
3. Check the debugger for *parser errors, invalid resources, blocked collisions and missing UI signals*. If any error occurs, capture the exact file:line.
4. Save a new attempt, restart, resume. Also try a copy of an older active 07.7 save. `civic` and `zone_positions.assembly` should be added without changing the old Writs.

## 1. Main route through five office alternatives
1. Install the Cinder Lung, pass the voluntary Rootkin hearing.
2. Obtain three unique Writs from *any* three offices. Confirm duplicates are not possible and Writ holder death never deletes the public register.
3. Authenticate in Hearth Nine at the public Quorum console; enter **core**, not the two-Writ `lift` trial.
4. Copy the original signed conscription order, objection and rail charter. Verify the current seed's Edda/Voss/Latch selection.
5. Use one available Custodian route (tribunal evidence, abdication, safety bus, defeated actuator). Verify physically hostile machine is removed from scene and remains removed after F9 load.
6. Return to the executive station or find the new **Public Civic Assembly Gate** at approx. x=-10,z=18. Enter the new `assembly` location.

## 2. Public assembly and physically grounded muster
1. Verify floor/wall texture, public benches, 3D rails and closed platform shutter are present and not camera-facing planes.
2. From x=-20,z=17, confirm the risk notice, petition, six constituency registers, four platform rosters, final decision desk and return to core are physically approachable.
3. Record risks. Read the original voluntary petition from core and present it again in assembly. Confirm no duplicate reward from repeating either station.
4. Help Brin and Ossa earlier, keep at least one other public constituency positively evidenced, and count three *distinct* votes. Confirm public mandate cannot be recorded with only two.
5. Confirm a refused/unsupported witness cannot be counted using a high Speech stat alone.
6. Revoke a passed mandate and verify True Dawn becomes unavailable while the other three endings remain.
7. Register patients (10) and families (8) on the 24-seat rail. Try to register claimant residents (10); it should be rejected at 28/24. Withdraw families, then register claimants; the tally should become 20/24. No one is reported boarded.
8. In another run, repair a carriage for **2 salvage + 3 Labour + 2 Energy** at the core. Confirm capacity is **36**, that it charges once, and that all four cohorts then fit exactly 36/36.

## 3. Separate final ending tests (FOUR separate attempts or snapshot copies)
- **Liberation:** Choice available after mandatory route even without good NPC relationships, Survey, Seed or Cipher. Confirm second confirmation. If cohorts were staged, `passenger_manifest` is a list of those real cohorts only; `rail_state=departure_open`; `seats_used <= rail_capacity`. If none staged, no passengers invented.
- **Dominion:** Choice available to all builds. Confirm `rail_state=closed`, `seats_used=0`, no passenger departure, different charter language from Crown. Any staged rosters do *not* count as evacuated.
- **The Crown:** Available without having killed the Custodian. Confirm accurate method/fate in epilogue, exit closed and no invented executions.
- **True Dawn:** Collect the **Orchard Root Seed**, **Deep Heat Survey** and one `cipher`; disclose actual risks, copy voluntary petition, register three independent public constituencies, receive revocable mandate, stage at least one cohort, and retain 3 Energy and 2 Labour. Verify the only relevant ending unlocks with these exact facts, charges both operating resources once, allows limited departure, and describes uncertainty/blackouts rather than complete cure.

## 4. Permanent terminal discipline
1. Immediately after each ending, player movement should be disabled, and a completed settlement report offered.
2. Return to register. **RESUME** should not load a completed attempt. **ARCHIVED SETTLEMENTS** should show past terminal attempts.
3. Start a new reconstruction. Its new seed and quest/rail records must be independent. Previously archived endings must not be claimed to be magically undone.
4. If an NPC died in a previous side quest, its epilogue entry must not attribute dialogue or heroic rescues to the dead.
5. F5/F9, death reconstruction and load/save must not duplicate passengers, costs, signed Writs or mandate votes.

## Tests available without Godot

```sh
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
```

These are static/source checks and a coarse geometry oracle. They cannot establish genuine raycast interactions, framerate, visual quality, sound mix or complete runtime story reachability.
