# THE NINTH EXHALE

Original retro-style first-person RPG / roguelite set in the city of Vesper, built in **Godot 4.4** (GL Compatibility renderer, 640×400 internal resolution).

**Current build: 08.5 — Witness Response.** This is the complete, runnable Godot project.

## Run it

1. Install Godot 4.4.x (standard, not .NET), or put the Godot executable next to `launch_linux.sh`.
2. Linux: `./launch_linux.sh`. Any OS: open `project.godot` in the Godot Project Manager and press **F5**.

Controls: WASD + mouse to move and look · LMB fire · R reload · 2–5 switch weapon · E interact · F / right-click intervene · TAB or ESC opens the dossier.

## Status

Verified on 2026-11-19 with Godot 4.4.1 stable (Linux x86_64):

| Check | Result |
|---|---|
| `python3 -m unittest discover -s tests -p 'test_*.py'` | 267 passed |
| `python3 tests/validate_project.py` | 14 passed |
| `res://tests/godot_scene_smoke_084.tscn` (headless) | all 8 districts load |
| `res://tests/godot_witness_threat_085.tscn` (headless) | 14/14 witness checks |
| Title screen start (headless) | no script errors |
| Rendered capture of each district | all 8 render with HUD and weapon |

**Not yet playtested by a person.** No full F5 playthrough, ending playthrough, audio check or frame-time measurement has been done on this build. The last build confirmed playable by hand was Build 03.

Known issues: see `docs/builds/BUILD_085_OPEN_ISSUES.md`. Godot also reports `16 resources still in use at exit` (an ObjectDB leak warning) on every run.

Run the engine checks with an isolated `HOME`, because the witness test writes a temporary save:

```
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_scene_smoke_084.tscn
HOME=$(mktemp -d) godot --headless --path . res://tests/godot_witness_threat_085.tscn
```

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
