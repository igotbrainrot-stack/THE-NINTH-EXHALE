# Build 06.4 — Weapon art and animation integration

This build is a change to the real Godot FPS controller and viewmodel, based on Build 06.3; it is NOT only a set of generated concepts.

## Implemented

- Stable idle art at 640×400, transparent RGBA; each weapon has its own viewmodel and pistol no longer teleports after shooting.
- Weapon selection with physical 2–5 keys; key 1 still heals.
- Deterministic visual recoil with recovery, muzzle flash, shell arc, micro-sway, distinct reload lowering/tilt, equip lowering, and empty trigger response. Same painted source object throughout animation to avoid AI frame jitter.
- Four actual firing profiles: Covenant Pistol (24 dmg / 0.42 sec / 6 mag / 1.8 sec reload), Coil Shotgun (8 pellets×8 / 1.05 sec / 2 mag / 1.6 sec reload), Nail Storm (8 dmg / 0.085 sec / 60 mag / 2.5 sec reload, +3 heat per round / heat cools 18 per sec / overheating at 90), Choirbreaker (30 dmg / 0.44 sec / 12 mag / 2.2 sec reload).
- Sootworks finite one-tool issue physically placed in the foundry; one choice of Coil Shotgun or Nail Storm, not free duplicates. The tool grant has 10 Coil Shells total (2 loaded + 8 reserve) or 120 Rivets total (60 loaded + 60 reserve), never a loaded-magazine bonus. Choirbreaker help reward carries 24 Waking Tape (12 loaded + 12 reserve). Choirbreaker remains unlocked by Ossa's existing quest decision.
- Ammo and equipped weapon persisted inside the attempt, preserving legacy Covenant counts and old save compatibility. Interrupting reload by switch never duplicates rounds. Automatic fire only for Nail Storm.

## Art provenance / limitations

- Four new unique source images generated through the connected Runway workspace. See `art/WEAPON_RUNWAY_064_MANIFEST.json` for task IDs.
- The connector does not transfer those remote PNG bytes directly to the local Godot container. Runtime Build 06.4 therefore contains a usable, previous in-chat generated Covenant Pistol and *interim* Coil/Nail/Choir sprites from the project-specific concept poster. These 3 interim sprites are lower resolution and have more generic shapes than the authoritative bible and Runway renderings. They must be replaced before art sign-off.
- The import script `art/tools/import_runway_weapon_exports.py` converts your downloaded four Runway images into aligned transparent game viewmodels, preserves originals and can be run more than once. It does not fake a completed remote-image upload.
- Generated keyframes are not used to animate the weapons. All timing is deterministic in `scripts/game_ui.gd` so perspective/hand silhouette stays consistent.

## How to test in Godot

1. Import `project.godot`, press F5 and choose **WEAPON ART + MOTION GALLERY** to inspect four viewmodels without altering the story save. Select 2–5, click to animate the firing pose, R for reload, Escape to return to title.
2. Enter Hearth Nine and begin a new Ninth. Test Covenant Pistol with left-click (one shot per press), reload R, idle walk with WASD, and interrupt reload by opening a docket.
3. Install Lung at Sela, use the service rail to Sootworks, locate **Worker tools issue**, use E, choose a finite **Coil Shotgun** or **Nail Storm**.
4. Use 2 pistol, 3 Coil or 4 Nail when owned. Switch during a reload and verify no spare rounds are created. For Nail, hold left click and verify the overheating cage blocks shots until it cools.
5. Follow Ossa's help route to receive Choirbreaker, then key 5. It should not appear before earning that reward.
6. F5 save, reload, restart and confirm ammo totals, owned tools and selected weapon persist. Test across district transitions, and on a save from Build 06.3.

## Test honesty

Python static/regression tests and source inspection do **not** certify Godot runtime compilation. The local environment does not have a Godot executable or external download access. A live Godot F5 import/gameplay QA pass is necessary before merging.

## Roadmap

After 06.4: export/import full-quality Runway originals; add independently drawn moving slide/cylinder/feed components where necessary; tune muzzle flash placement to each new image; add equip/shot/reload sound effects; connect all finite ammo types to shops and pickups; improve weapon pickup models; human IP/art review.
