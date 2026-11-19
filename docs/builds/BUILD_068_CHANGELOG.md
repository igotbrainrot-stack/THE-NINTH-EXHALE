# Build 06.8 — Enemy Ecology and Animated Sprite System

This branch continues from Build 06.7 Living Wards. It does not replace the story or reset the user's working gameplay progression.

## Gameplay additions

- Ten optional combat archetypes: Pressure Mite, Registry Bailiff, Vent Whistler, Rivet Courier, Slag Sifter, Chain Hauler, Choir Reed, Saltbound Porter, Sluice Beadle, Triage Warden.
- All 15 combat identities (including the existing 5) have independent named entries, stable IDs, health, attack interval, speed, range, damage, activation range, region, actor state and Runway art provenance.
- Distinct mechanics: rush (direction fixed on commitment), line pressure shot, heavy long-windup shot, acoustic signal shot, heavy shield mitigation while braced, mobile skirmishing, stationary acoustic turret, finite 4-Breath chain-haul drain. Existing pressure/cover obstruction remains physical.
- Up to two optional archetypes are chosen per existing area, seeded deterministically; Edda's trial has one additional optional warden. **Not all ten simultaneously spawn.** The starting tutorial remains the single crawler until the airlock is opened. Side foes do not hand out XP, repeatable loot or Writs.
- Old 06.7 saves receive additive enemy-state defaults. Defeated optional enemies are recorded once and do not respawn in the same attempt. Runway artwork import can later replace the provisional sprite art without changing spawn or behavior IDs.

## Sprite animation

- `scripts/enemy.gd`: four-view camera-relative 12-pose atlas playback and 0.70-second death animation. Fixed sprite size/foot baseline and existing cover and combat telemetry retained.
- `scripts/animated_echoform_068.gd`: voluntary Rootkin and Bell Wretch hearing visuals animate without becoming player-collectible FPS enemies.
- `scripts/basilica_builder.gd`: hearing fixtures use the new visual component.
- `art/tools/build_enemy_sprite_atlases_068.py`: reproducible Pillow + NumPy bake and transparent sprite export. `art/tools/render_068_motion_preview.py` generates a demonstration video.
- Generated `assets/sprites/enemies_068/*.png`: 17 subjects × 4 directions × 12 frame cells = **816 stable atlas cells**. Runway raw source exports are **not embedded**; runtime sheets are produced from clearly marked, built-in originals and procedural temporary silhouettes. The Runway workspace has 17 completed production-source generations.

## Files and preservation

New: `data/enemy_roster_068.json`, `scripts/enemy_roster_068.gd`, `scripts/animated_echoform_068.gd`, `assets/sprites/enemies_068`, `art/ENEMY_ANIMATION_MANIFEST_068.json`, `art/RUNWAY_ENEMY_ANIMATION_068.md`, the two art scripts, preview images/video and 06.8 regression tests.

Modified: `scripts/enemy.gd`, `scripts/main.gd`, `scripts/run_state.gd`, `scripts/basilica_builder.gd`, `project.godot`, three stale tests updated to check their preserved numerical values in the new data catalogue. **Cinder Lung IDs, old bosses, Sootworks/Flood Basilica Writs, Rootkin command vocabulary and Edda test gates preserved.**

## Known limitations

This is source-verified but **not Godot-runtime-verified here**. The existing Build 06.5 was previously user-playtested; these new changes have not received an independent live test. New enemy locations, pathfinding, difficulty and art appearance need F5 verification. Runway original high-resolution PNGs need export/approval and atlas regeneration. Directional art for unexported new enemies uses interim drawings; the movements are deterministic sprite transformations, **not a hand-drawn per-frame multi-angle walk cycle**. NPC death may be deferred until the short collapse completes. No new full-game districts, canonical endings or creature collection mechanic were added.
