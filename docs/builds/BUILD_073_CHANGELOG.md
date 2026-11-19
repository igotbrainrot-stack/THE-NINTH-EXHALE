# Build 07.3 — Genuine Eight-View Sprite Correction

## The verified failure in Build 07.2

The earlier project included nominal 1..8 direction files, but several enemy images were effectively duplicates of a single FRONT drawing. In the audit contact sheet, Sela/Brin/Ossa/Oren/clerk already showed real perspective variety, whereas creatures including Bell Wretch, Sentry, Choir Reed, Chain Hauler, Cantor, Millwright, and Enforcer had minimal or no back/side distinction.

This was an art-source failure, NOT merely a missing Godot `Sprite3D.billboard` setting. Changing an asset filename or applying a subtle optical-flow warp cannot construct true back-facing artwork.

## Runtime correction

- `art/tools/render_true_8way_073.py` builds original industrial-low-poly **three-dimensional** maquettes for ALL 22 actor identities and renders **eight actual camera positions** at 45-degree intervals with stable scale and foot anchor.
- Eight physical views for each of the 17 enemy/hearing actors are baked into the active Godot runtime atlases under `assets/sprites/enemies_073/`. Each angle has 12 motion-proxy frames, compatible with the existing enemy animation controller. True full eight-angle views; **not** 12 individually hand-painted motion frames.
- The five civilian NPCs retain their more detailed, already-distinct painted `assets/sprites/directional8/` views. Equivalent real 3D maquette turnarounds for all five are included for optional future use under `art/production_sources/turntable_073/`.
- `enemy.gd`, `animated_echoform_068.gd`, and `enemy_gallery_068.gd` now load `enemies_073` FIRST and retain `enemies_071` fallback to preserve compatibility.
- The enemy gallery now uses **T** to compare the earlier near-duplicate 07.2 sprites against the actual eight-view 07.3 sprites. UP/DOWN cycle 0..8 viewing conventions.
- No quest ID, save schema, combat stat, music, furniture collision or dialogue changes.

## Higher fidelity regenerated Runway art

- A second 22-character Runway generation batch has been completed with stricter prompt wording: eight physically different 45° views, recognizable side profiles and true back views, never eight front poses.
- Exact task identifiers and source-export filenames live in `art/RUNWAY_073_REGENERATION.json`.
- The remote completed Runway PNG bytes are NOT inside this ZIP. Do not claim they have been integrated. The connected workspace has the original results.
- `art/tools/import_runway_true_eight_073.py` enforces 22/22 export completeness by default and **rejects near-duplicate images before altering a working active sprite atlas**. It generates a review contact sheet. Manual visual review remains mandatory to catch facial orientation, eye count and left/right item mistakes.

## Proof / verification

- `art/ACTIVE_EIGHT_WAY_INDEX_073.json` documents every active actor file, angle, category and measured pairwise RGB difference.
- `tests/test_build073_true_eight.py` requires 17 x 8 active enemy/hearing atlases with all 28 pairs measurably distinct, plus 5 x 8 painted NPC directional images with all pairs distinct. It also confirms the code paths actually use these files and duplicate imports are rejected.
- The static 3D prop kit remains real geometry and deliberately has no sprite-angle requirement.

## Known limits

The procedural 3D-turntable fallbacks are deliberately **lower fidelity** than the pending finished Runway artwork. They are a correctly rotating stopgap, not a polished replacement for the entire character-art pipeline. Walking, attacking, hit and death stage motion remains procedurally derived rather than separately animated from a single full 3D rig. Live Godot compilation and playtesting were not available in this environment.
