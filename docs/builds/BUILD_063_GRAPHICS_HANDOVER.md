# The Ninth Exhale — 06.3 graphics handover

## What changed

* Replaced flat wall/floor assets in Hearth Nine, Sootworks, Flood Basilica with five unique high-resolution 512×512 processed tiles. All original generation PNGs preserved as source art.
* Added original new main-NPC 4-face 192×280 images for Sela, Brin, Ossa, Oren, and the municipal clerk; all five are actually referenced by the Godot directional actor loader.
* Replaced the generic hostile portrait with three separate static illustrated images for office Enforcer, Millwright and Cantor. Four repeated pose frames are intentionally identical pending a proper rigged locomotion animation; avoids scaling/jitter from arbitrarily mismatched generated frames.
* Added 27 individual high-detail sprite-era 2D furniture standees and 22 per-district instances (66 placements) to existing collidable room structures. They add no new collision blockers; actual collision/furniture occlusion should receive an in-engine pass before claiming physical fidelity.
* Replaced the Covenant Pistol's 256×144 blocky placeholder with a 600×450 RGBA original illustration and repositioned its canvas UI.
* Added a reproducible asset converter and source hashes, retaining the `art/RUNWAY_BATCH_MANIFEST.json` list of the 21 independently generated Runway source art tasks; **Runway originals are not automatically copied into this build**.

## Source-level checks and limitations

Run `python3 tests/test_build063_production_assets.py` or all tests in the `tests` folder. No Godot executable available in this build environment, so **visuals, gameplay, parse status and navigation have NOT been verified in the engine**. The user reported Build 03 playable, not this version.

### Need live Godot QA

1. Open in Godot 4 and press F5; note any script import errors.
2. Check Hearth Nine floor/seam consistency and transparency fringing at 320×200.
3. Walk near each of the 22 standees in each area; test depth sorting, visibility, collision and prompt access.
4. Verify Oren, clerk, Brin and Ossa have four views; check body scaling and feet during camera orbit.
5. Fire and reload the Covenant Pistol; inspect silhouette, position, HUD overlap and perspective.
6. Complete the Lung, Labour, Faith and hearing routes; reload/die and verify one-time outcomes unchanged.
7. Human-review generated imagery and any Runway exports for originality and thematic consistency.

## Source control

The user's repo is `igotbrainrot-stack/THE-NINTH-EXHALE` (public). This package contains source PNGs and game assets. GitHub connector initialized README only; full source and binary art require publishing actual files. Use `./publish_to_github.sh` on a Linux host with GitHub git credentials to push a non-destructive feature branch. **Do not claim those files uploaded until GitHub lists them**.
