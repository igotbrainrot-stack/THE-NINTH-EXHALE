# THE NINTH EXHALE — Pressure Docket HUD 09.1 asset integration

**Date:** 21 November 2026
**Target:** `feature/build-091-cleanup-hud-handover-20261121` or newer, Godot 4.4.1.

## Delivery

- 28 complete `assets/ui/hud_091/*.png` alpha textures, matching the actual slot names in `scripts/game_ui.gd`.
- `hud_091_slices.json` with verified corner margins. Does not include the hidden `hud_banner_alert` slot.
- 11 byte-identical original OpenAI image generation files, plus 12 original 4x procedural master sources (23 source PNGs total) in `art/production_sources/hud_091`.
- `art/RUNWAY_HUD_091_MANIFEST.json` with per-file source/runtime SHA256, source provider, real recorded generator job IDs where available, null Runway task IDs (none of these are exports from Runway), pixel dimensions and processing steps. Licence review remains pending.
- Contact sheet, 12px icon readability sheet and two 640x400 composited UI examples (not screenshots of Godot gameplay).
- No code changes, no modifications to `assets/ui/hud_086/`, no GitHub merge.

## What changed visually

- Repainted brass and cold-steel frames, additional thin route frame, dark prompt service window and dossier modal designed around live Godot text.
- Live button states: paper normal, brighter brass hover, visibly recessed dark pressed.
- Corrected 9-slice corner geometry for compact 204x54 / 248x28 HUD placements.
- Created paper notice slip, red stamped border, tactile keycap, two docket tab states.
- Bars: recessed pressure channel with three tileable horizontal fill colours; no horizontal gradients or cap stretching.
- New outlined reticles with open centers, and nine clean transparent non-plaque icons based on an original generated 3x3 concept sheet. Four icons (health, ampoule, ammo, interact) were redrawn by hand as original pixel sprites to remain distinct at 12px; see `HUD_091_12PX_ICONS.png`.
- Docket modal source included decorative button bars; these were intentionally removed from the shipped skin to avoid duplicated interactable buttons. Original high-resolution download was kept byte-identical.

## Tests performed

- PNG format: 28/28 RGBA with expected exact source dimensions.
- Source and output SHA-256 checks: 28/28 passed, raw image downloads preserved.
- 9-slice margin constraints: passed for every sliced slot using stricter `< half source height` rule.
- Godot 4.4.1 headless editor import of an isolated 640x400 texture test project: exit 0.
- Godot 4.4.1 texture/StyleBoxTexture scene smoke: 28/28 loaded, exit 0.
- Composited design preflight: `HUD_091_640x400_LAYOUT_MOCK_PLAY.png` and `HUD_091_640x400_LAYOUT_MOCK_DOCKET.png`.

## Not yet verified

The full Build 09.1 branch currently exists on GitHub, but **the full project was not downloaded into this execution sandbox**, so there was no actual 09.1 engine gameplay test. The two layout mocks are preflights, not engine screenshots. In-game clip, font alignment, input focus, modal scrolling, stamp animation and HUD performance still require testing on an installed Build 09.1 checkout.

## Installing into game

Unzip this package into its own folder, then run:

```bash
bash tools/install_hud_091.sh /path/to/THE-NINTH-EXHALE
```

This checks `project.godot` and the 09.1 override loader, then copies the exact slot names, source files, manifest, and QA report into the game. It leaves `hud_086` and game code untouched. After installing:

```bash
cd /path/to/THE-NINTH-EXHALE
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
godot --headless --editor --path . --quit
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_hud_090.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_codefix_regressions.tscn
# Execute res://tests/godot_hud_override_091.tscn in an isolated worktree:
# it temporarily writes test override images and may replace user artwork while running.
```

Use `tools/playbot_090/run_playbot.sh` from the 09.1 branch to record real 640x400 frames and check each UI state. Do not interpret isolated asset smoke checks as full gameplay testing.

## Open issues / review

1. Source OpenAI art retains very fine material grain. After downscale it is intentionally simplified; inspect at 1x on a real display.
2. Generated high-resolution sprites used implicit conversational prompts; their exact tool prompt strings are not recoverable and are recorded as `null` rather than invented.
3. The generated icon concept sheet had a baked pale checkerboard. It was keyed out and verified against dark/light backgrounds; a future icon cleanup can remove remaining near-white pixels if visible.
4. User review of original artwork usage/terms remains pending (`license_review: pending`).
5. No game-code changes or GitHub push were made in this asset pass.
