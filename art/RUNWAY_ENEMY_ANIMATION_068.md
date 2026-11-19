# The Ninth Exhale — Runway enemy artwork / Build 06.8

**Original Runway generation completed:** 17 separate **2×2 turnaround** renders (15 combat hostiles, Bell Wretch and voluntary public-loaner Rootkin). They remain in the owner's connected Runway workspace. **The actual Runway source PNGs are not present in this ZIP**, because the connector returned asset URLs and task records but could not materialise their bytes into the Godot working container.

**Runtime animation implemented:** each subject has four directional atlases, each 4 columns × 3 rows × 192×256 pixels. These are fully bundled and are used in game. They were baked from six existing pre-generated source sprites, two hearing source sprites, and hand-authored interim mechanical silhouettes, **not downloaded Runway originals**. Every atlas uses a common foot anchor so walking, attacking, hit-reacting and dying will not inflate or shrink the sprite.

| Frame | Animation |
|---|---|
| 0 | idle/step 0 |
| 1–3 | three walking poses |
| 4–5 | wind-up / telegraph |
| 6–7 | attack and recovery |
| 8 | hurt |
| 9–11 | three collapsing/death poses |

## Replace interim artwork with the approved Runway sprites

1. In Runway, export the original PNG for each item recorded by **task ID** in `data/enemy_roster_068.json` and `runway_hearing_tasks`.
2. Name it `<enemy_id>.png`. Place it under `art/production_sources/enemies_068/`. Every export is expected to have four direction cells: **front top left, left top right, right bottom left, back bottom right**.
3. From this project root run `python3 art/tools/build_enemy_sprite_atlases_068.py` (requires Pillow and NumPy). It keys out the magenta background and bakes the same stable motion poses for all four views.
4. Run `python3 art/tools/render_068_motion_preview.py` and `python3 -m unittest discover -s tests -p 'test*.py' -q`.
5. Import the refreshed project using Godot 4.4 or newer and manually test each sprite's direction and frame alignment. Review regenerated images visually before considering them final production sprites.

The source PNG should remain checked in under `art/production_sources/enemies_068/` and the runtime sheets under `assets/sprites/enemies_068/` after export. Never say that an external Runway image has been bundled if its exact PNG file is absent.

## Originality

All prompts are original civic-industrial creatures, apparatus or personnel; no copyrighted franchise monsters or visual sprites are used. The game's four endings, ethical hearing, voluntary public loaner, three-Writ full-game quorum and the five original keeper IDs are unchanged. Human art/IP review is still required.
