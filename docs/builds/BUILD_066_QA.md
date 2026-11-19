# Build 06.6 QA and test instructions

## Available execution evidence

- Automated regression suite: `python3 -m unittest discover -s tests -p 'test_*.py'` — **80 passed** (after updating three old tests that assumed obsolete literal code, without weakening behaviour invariants).
- Project source/data validator: `python3 tests/validate_project.py` — **14 passed**.
- Approximate 2D geometric occupancy checks for Sootworks and Flood Basilica — **3 passed** (included in 80 above). These **do not** test Godot collision, real stair clearance, capsule sweep, or opening tween behaviour.
- Embedded WAVs: 22050 Hz, 16-bit PCM mono, 8 distinct valid files; checked through Python wave reader.
- Godot engine binary: **not installed / not executable** in this environment; direct import, headless parser, F5 smoke test, save/load in-engine, frame rate, audio mix and actual player fun **NOT VERIFIED**.

## Mandatory Godot smoke/functional matrix — all PENDING

1. Fresh new attempt (`Witness`), visual intake relay, E interaction without repeated modal. Audible warning when crawler rush begins, visible overhead red/amber telegraph, cover or sidestep avoids charge.
2. Fire Covenant Pistol and hear original report; hit crawler and observe impact flash. Reload without ammo duplication. Repeat crawler with artificially depleted rounds and **F/right-click** until defeated; no XP/loot farm.
3. Use the **one-shot intake quench vent** near x=-11,z=14, observe temporary interrupt; second use must do nothing. Open valve, see shutter **move** out of travel lane, hear steam, and reach Sela.
4. Install Lung through at least two surviving branches (evidence bargaining/Tech/threat/steal); check physical ward light and the negative claimant allocation. Verify Sela doesn't claim nonexistent extra Lung.
5. Sootworks: seed 100 then 101; identify cover difference. Open optional union bypass, walk physically through extra x≈1,z≈-13.5 doorway, return by always-open center. Steam diversion should interrupt the Millwright only once. Verify Brin's recorded work status changes in-world.
6. Basilica: use E at lay-choir latch, physically cross north partition near x≈2,z≈-15; hearing UI should show **RISING**, **SHIELDED** or **EXPOSED** and visible signal tint. The optional resonator should provide exactly one opening observation for the first Attune. Test all-Press exhaustion and two different winning strategies; retry after withdrawal, check unique XP once.
7. Reach both Writ registries after holder death/tech isolation; actor deaths must not result in posthumous speech. Verify one-time reward flags. Return from both districts and from Edda lift.
8. Save/load after opening a shortcut and after partial hearing; the physical shutter stays open if recorded, NPC states and enemy HP persist, no extra grant of ammo, Writs, XP, or Cinder Lung.
9. Test at least seed 100, 101, 102 with `godot --path . -- --ninth-seed=<N>`; replay 100 twice and compare side-opening, cover and keeper spawn. Godot should validate physics body clearance, not Python approximation.
10. FPS check on a modest machine, static furniture always nonbillboard, warning sounds nonpainful, disable/silent sound availability, colourblind readability and keyboard-only control accessibility.

## Baseline not lost

Do not report failing to install Godot in the build container as a newly discovered user runtime fault; the owner has already confirmed 06.5 functional. At the same time, do not call untested 06.6 fully playable until an engine build and real playthrough verifies the new source.
