# Open issues / Build 06.8

- **Engine runtime:** Project has no Godot execution log from this environment. F5 test by owner required.
- **Runway source transfer:** 17 original completed Runway renders are not embedded into the ZIP; only their task IDs and rebuild pipeline are included. Replace author placeholder sources with downloaded originals and rerun baking.
- **Animation quality:** All enemies have 12 distinct fixed-baseline sprite poses per orientation, but limb motion is procedural cutout animation and should be replaced with a hand-corrected bone/parts pipeline for a final release. Avoid independent AI generations of every frame.
- **Enemy balance/navigation:** Seeded enemy pairs must be observed in-engine for placement, collision, cover strategy, performance, line-of-sight and no-ammo success. Potential aggression overlap if two optional enemies wake at once.
- **Broader content:** 5 districts/3 unique Writs/full four endings not implemented; this feature adds only to current 06.7 playable areas.
- **GitHub binaries:** Source game and new PNGs packaged in ZIP; still need pushing to project GitHub. Do not confuse the Runway task register or repository README with asset binary upload.
