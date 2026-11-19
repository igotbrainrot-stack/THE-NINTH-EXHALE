# Changelog

Full per-build notes, QA and open issues for every build since Build 02 are in `docs/builds/`.

## 08.5 — Witness Response (2026-11-19)

Base: Build 08.4 Godot Runtime Fix.

- Brin and Ossa become persistently "threatened" when directly attacked below 60% HP (27 of 45). The intimidation is recorded once as evidence and alerts the district's living guard.
- Threatened NPCs show a fearful movement cadence, colour and wounded-witness signage, and keep their foot anchoring.
- New Godot headless regression test (`tests/godot_witness_threat_085.tscn`) plus Python regression tests.
- Writs, hearings, endings, energy accounting and existing saves unchanged.

Details: `docs/builds/BUILD_085_CHANGELOG.md`, `BUILD_085_QA.md`, `BUILD_085_OPEN_ISSUES.md`.

### Repository reorganisation (same date)

- The full Godot project is now on `main`, replacing the earlier notes-only repository.
- Build notes from the project root and `docs/` moved to `docs/builds/`. `docs/` is ignored by the Godot importer.
- `ART_ANIMATION_COVERAGE.csv` moved to `docs/`. Godot had been importing it as a translation file and generating five `.translation` files.
- Removed `publish_to_github.sh` (obsolete), Python caches and generated `.translation` files.
- Project display name set to "The Ninth Exhale" (was "Build 08.1 Architectural Fidelity").
- README rewritten to match the verified state.
