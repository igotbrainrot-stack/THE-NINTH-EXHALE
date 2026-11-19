# The Ninth Exhale — Build 06.4 release notes

## Status
Source-only Godot 4 project, requires a live Godot F5 import/playtest. No binary export has been made.

## New
- **Weapon Art + Motion Gallery** on the Godot title screen, giving immediate noncanonical inspection of all four guns (2–5 swap, click fire, R reload, Escape return) without altering the save state
- Distinct four-weapon viewmodels (Covenant, Coil, Nail, Choir), 640×400 transparent textures
- Recoil recovery, limited muzzle flash, ejected casing arc, walking sway, slow idle drift, timed reload lowering/tilt, weapon switch, dry-fire
- Per-weapon damage/magazine/reload cadence and finite reserves; shotgun pellets, Nail Storm heat
- Finite staffed tool issue in Sootworks for one of two heavy tools; Choirbreaker still only through Ossa's existing quest
- Save-compatible weapon-state initialization on older attempts
- Four new Runway images generated, with exact task IDs and importer for exported original PNGs
- Video preview showing the procedural key poses (illustration, NOT engine capture)

## Critical limitations
- Runway originals are in the user's Runway workspace; the new PNG bytes could not be transferred directly into the local sandbox. Four game-ready images in the ZIP are *fallback viewmodels*: detailed Covenant original from prior in-conversation art, and interim lower-resolution three-tool references from the project poster.
- Godot engine not present in build environment. Source tests are not engine tests.
- No final weapon-specific animation of physical slide, live casing model, hand skeleton or authored reload keyframes yet. Visual animation moves the consistent single viewmodel image to avoid AI temporal instability.
- Sound design not yet implemented.
