# THE NINTH EXHALE

An original industrial-civic horror FPS/RPG developed in **Godot 4.4.1**.

> **Repository state (19 November 2026):** the playable **Build 08.5** exists as a separate complete project archive, but **has NOT yet been committed to this GitHub repository**. This repository is a staging/recovery skeleton until the complete source and binary assets are imported and verified. Do not treat the current tree as runnable.

## Current complete build

**Build 08.5 — Witness Response (Godot tested)** is the current authoritative project archive. It contains Godot scenes, gameplay scripts, art/audio, tests, and design records. Ask the project owner for `The_Ninth_Exhale_Build_085_WITNESS_RESPONSE_GODOT_TESTED.zip`, then follow [the import guide](docs/BUILD_085_IMPORT_GUIDE.md).

The project preserves the five founding offices, independent Writ quorum, non-coercive Rootkin hearing, finite resources, public assembly, and four endings. Godot 4.4.1 headless startup, eight-zone smoke tests and witness tests were performed on the packaged build; full graphical playthrough is not yet certified.

## Repository layout after full import

| Path | Purpose |
| --- | --- |
| `project.godot` | Godot entry point |
| `scenes/` | Scene definitions |
| `scripts/` | Game logic, state and actors |
| `assets/` | Runtime sprites, materials, audio and UI |
| `data/` | Narrative/game data |
| `tests/` | Regression and Godot smoke tests |
| `art/` | Provenance and production sources |
| `docs/` | Game bible, change logs and QA |
| `tools/` | Developer utilities |

## Build and test after import

1. Install Godot **4.4.1**.
2. From the project root run `godot --headless --editor --path . --quit` to import resources.
3. Run `godot --path .` to open the project.
4. Read the latest `BUILD_085_QA.md` and tests before claiming gameplay certification.

## Preservation / collaboration

- **Do not merge** a partial import over the game without review.
- Do not rewrite or remove the foundational game bible, run-state constraints, asset provenance, or four endings.
- Use a feature branch and draft pull request for large imports.
- Do not commit `.godot/` caches, temporary exports, local test outputs, ZIPs, or installed engine binaries.
- Preserve original art/audio rights and provenance; include only assets available for redistribution.

See [repository status](docs/REPOSITORY_STATUS_20261119.md) and [Build 08.5 import guide](docs/BUILD_085_IMPORT_GUIDE.md).
