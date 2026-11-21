# THE NINTH EXHALE

Original retro-style first-person RPG / roguelite set in the city of Vesper, built in **Godot 4.4** (GL Compatibility renderer, 640×400 internal resolution).

**Current build: 08.7 — Asset Integration**, with the 08.5 code-fix pass ported on top. This is the complete, runnable Godot project. 08.7 adds the textured "Pressure Docket" HUD (Enamel Service Window art, nine icons) and a registry of every runtime media file; see `docs/BUILD_087_CHANGELOG.md`, `docs/BUILD_087_QA.md` and `docs/BUILD_087_OPEN_ISSUES.md`.

## Run it

1. Install Godot 4.4.x (standard, not .NET), or put the Godot executable next to `launch_linux.sh`.
2. Linux: `./launch_linux.sh`. Any OS: open `project.godot` in the Godot Project Manager and press **F5**.

Controls: WASD + mouse to move and look · LMB fire · R reload · 2–5 switch weapon · E interact · F / right-click intervene · TAB or ESC opens the dossier. In any docket, number keys 1–9 pick a choice and ←/→ or Q/E switch the dossier's tabs.

## Status

Verified on 2026-11-21 with Godot 4.4.1 stable (Linux x86_64):

| Check | Result |
|---|---|
| `python3 -m unittest discover -s tests -p 'test_*.py'` | 277 passed |
| `python3 tests/validate_project.py` | 14 passed |
| `godot --headless --editor --path . --quit` | clean import |
| `res://tests/godot_scene_smoke_084.tscn` (headless) | all 8 districts load |
| `res://tests/godot_witness_threat_085.tscn` (headless) | 14/14 witness checks |
| `res://tests/godot_hud_086.tscn` (headless) | HUD art checks pass |
| `res://tests/godot_asset_runtime_087.tscn` (headless) | asset/icon/fallback-audio checks pass |
| `res://tests/godot_rpg_089.tscn` (headless, exits 1 on failure) | 33/33 checks, perks, XP caps, trust, lockout warning, hearing balance |
| `res://tests/godot_art_088.tscn` (headless, exits 1 on failure) | 39/39 actors render the 08.8 art |
| `res://tests/godot_hud_090.tscn` (headless, exits 1 on failure) | 54/54 notice slips, stamps, keycaps, number keys, docket tabs, vignette, bar trail, hit marker, level-up reminder, hearing layout |
| `res://tests/godot_prompts_090.tscn` (headless, exits 1 on failure) | all 122 interactables in 9 districts have written prompts that fit; all 45 route targets lead to something usable |
| `tools/playbot_090/run_playbot.sh out/ 420` (rendered) | scripted playthrough: title → Liberation ending in ~6 min bot time; frames + log |
| `res://tests/godot_codefix_regressions.tscn` (headless, exits 1 on failure) | 36/36 regression checks incl. HUD icon/border layout, clean exit |
| Rendered 640x400 captures | gameplay HUD, Nail Storm heat, docket modal, 09.0 slips/stamp/low-health/tabbed docket |

**Not yet playtested by a person.** No full F5 playthrough, ending playthrough, audio check or frame-time measurement has been done on this build. The last build confirmed playable by hand was Build 03.

Known issues: see `docs/BUILD_087_OPEN_ISSUES.md` and `docs/builds/BUILD_085_OPEN_ISSUES.md`. The old `16 resources still in use at exit` warning is fixed for every in-game quit path (menu, window close, tests); Godot's own `--quit-after` developer flag bypasses the game's quit handling and can still print it.

Run the engine checks with an isolated `HOME`, because the witness test writes a temporary save:

```
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_scene_smoke_084.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_witness_threat_085.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_hud_086.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_asset_runtime_087.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_codefix_regressions.tscn
```

Quit the game from code with `Music.request_quit()`, not `get_tree().quit()`: it stops every audio player first, which is what prevents the exit leak.

## Layout

| Path | Contents |
|---|---|
| `project.godot`, `scenes/`, `scripts/` | Godot project, scenes and GDScript |
| `assets/` | Runtime assets: textures, sprites, weapons, UI, FX, audio, music, cinematics |
| `art/` | Production source art (`production_sources/`), previews, import tools and Runway provenance manifests |
| `data/` | Game data: master IDs, enemy roster, reference catalogue |
| `tests/` | Python source tests and Godot headless test scenes |
| `tools/` | Asset generation scripts |
| `docs/` | Design docs (`MASTER_GAME_BIBLE_FINAL.md` is the source of truth). Ignored by the Godot importer. |
| `docs/builds/` | Per-build changelogs, QA reports, open issues and checksum manifests, Build 02 → 08.5 |

## Rules

- `main` holds the current runnable build. Do larger work on feature branches and merge once the tests above pass.
- Keep the two-channel Lumen Engine, the three distinct Writs for full-game progression and the ethical Echoform hearing.
- Art is original to this project. Do not add assets from Unity, Unreal, DOOM, Fallout, Pokémon, BioShock or any other third-party game. Generated art still needs a human visual/IP review (`docs/PROTECTED_ORIGINALITY_REGISTER.md`).
- Runway task IDs and provenance are recorded in `art/*RUNWAY*` manifests. A task ID is not an imported asset; only files present in this repo are in the game.
