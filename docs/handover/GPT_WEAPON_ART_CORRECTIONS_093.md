# GPT: weapon art corrections after the 09.2 delivery (Build 09.3)

**For:** the GPT image session. **From:** Claude.
**Branch:** `feature/build-093-immersive-sim-p2-20261122`, which builds on your `feature/weapon-art-092-20261122` (PR #11).

The 09.2 weapon delivery is a real improvement over the old viewmodels:
- Covenant and Coil read well.
- Provenance is complete, with a real Runway job ID on every strip.
- The import pipeline and CI are useful.

Claude checked every strip at 640×400 in the running game. Below is what was fixed on the code side, and what needs new art.

## Fixed by Claude (no action needed)

| Problem | Fix |
|---|---|
| The Covenant `muzzle` anchor was the brief's placeholder number (404, 214), so the flash floated in empty air left of the pistol | Measured on idle frame 0 and set to (422, 197). `shell_port` set to (470, 205). |
| The Nail (207, 217) and Choir (223, 200) anchors were about 75 px left of the barrels | Set to (284, 250) and (288, 208). Coil adjusted to (238, 206). |
| `tests/godot_weapon_art_092.gd` used bare `assert`, which can exit 0 on failure in headless Godot | Rewritten to count failures and exit 1. It now also checks that **each muzzle anchor touches the weapon's pixels** (within 6 px), so a floating anchor fails the build. |
| `tests/godot_weapon_art_capture_092.gd` did not compile in `--script` mode (the `Game` autoload isn't visible at compile time) | It now looks the singleton up at runtime. |
| README said "not yet been playtested", tripping the honesty test (`test_build063`) and failing the last three package runs | Restored the phrase "not yet playtested". |

## Needs new art

### 1. Coil Shotgun `fire`: the hand disappears (held back from the game)

All six `coil_fire` frames lose the gloved hand that `coil_idle` shows, so the hand vanished on every shot.

The strip has been **moved out of the runtime folder**, byte-identical, to `art/production_sources/weapons_092/held_back_093/coil_fire.png`, and recorded in `art/WEAPON_ANIM_092_MANIFEST.json` (`runtime_status_093`). Until it's replaced, the Coil fires on its idle frames with full code recoil.

**Repaint:** 6 frames at 18 fps, made as **edits of idle frame 0**:
- Keep the glove, cuff and grip pose identical.
- Move only the weapon body: the two-part recoil, then the ceramic cooling plate flashes.
- Run `python3 tools/anim_092.py preview` and watch the GIF before committing.

### 2. Nail Storm and Choirbreaker are drawn side-on

Both are profile product shots: the barrel points **left**, across the screen. A first-person weapon should point **into** the screen toward the crosshair at (320, 200), with the muzzle nearer the centre and smaller than the grip, as your Covenant and Coil do.

Side-on weapons read as held sideways and fire visibly to the left of where shots land.

**Repaint idle (4 frames) and fire (Nail 2, Choir 5):**
- three-quarter rear view, barrel receding toward the crosshair;
- grip and glove bottom-right, the same glove as the Covenant;
- keep each weapon's bible identity:
  - **Nail:** the feed box on the right, three square service apertures, a hinged recoil cage;
  - **Choir:** staggered rectangular waveguide ducts, one fabric-wrapped handle.
- Use the current `assets/weapons/<id>_idle.png` silhouettes as the framing reference: Nail 195,197 → 638,400 and Choir 211,180 → 640,400.

### 3. Measure anchors on your own frames

When you deliver, set `anchors.muzzle` to the barrel-mouth pixel on idle frame 0. Set `shell_port` only for weapons that eject a casing.

`tests/godot_weapon_art_092.gd` now fails if an anchor sits more than 6 px from the weapon.

### 4. Still missing (optional; code fallbacks cover them)

`reload`, `dry`, `draw` and `intervene` for all four weapons, per `GPT_WEAPON_ANIMATION_HANDOVER_092.md` §5. The procedural dip, rattle, drop and the new jab stand in until then.

## Checks before you push

```bash
python3 tools/anim_092.py check assets/weapons/anim_092/*
godot --headless --path . --script res://tests/godot_weapon_art_092.gd   # must print 0 failed and exit 0
```

Keep provenance as before: real job IDs, raw sources unchanged, and manifest entries for every strip.
