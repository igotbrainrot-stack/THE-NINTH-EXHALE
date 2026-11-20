# Changelog

Full per-build notes, QA and open issues for every build since Build 02 are in `docs/builds/`.

## 08.7 integration (2026-11-20)

Build 08.7 "Asset Integration" imported from the verified ZIP (SHA-256 `375bbd75…a15c`, 2,150 files) as its exact delta over 08.5, then the 08.5 code-fix pass (PR #3) ported on top. 08.7's own changes are listed in `docs/BUILD_087_CHANGELOG.md`.

**Porting PR #3.** 24 of 25 files merged without conflict. `scripts/game_ui.gd` conflicted in 11 places, because 08.7 shifted every panel title right to make room for its icons. It was resolved by taking 08.7's file and re-applying each fix:
- The sizing-order fix (sizes set after `add_child`).
- Route panel widened, with an ellipsis, so the distance always fits.
- Two-line objective.
- LEVEL/XP width.
- Staged-roster and Sootworks-objective text.
- The stamp now reads 08.7.

08.7's own four-line controls legend was kept instead of PR #3's two-line version.

**New fixes found in 08.7's HUD**
- Icons rendered at their 24 px source size over the panel titles (VITALS, EQUIPMENT, BREATH, objective, route). The size is now set after the expand mode and after the icon enters the tree.
- The second objective line sat on the brass frame border. The objective panel is 6 px taller and the zone label narrower.
- `art/BUILD_087_ASSET_USAGE.csv` imports as "keep" instead of generating four translation files.
- `Music.request_quit()` silences audio twice, a frame apart, so quitting right after music starts doesn't leak. 08.7's HUD and asset test scenes now quit through it.

**Tests.** The regression scene now also checks that HUD icons don't overlap text, and that text stays inside each panel frame (36 checks).

## 08.5 code-fix pass (2026-11-19)

Code-only bug fixes from the research audit (`research/Fixing Ninth Exhale RPG mechanics.md` in the project docs). No art, design or balance changes. Verified with Godot 4.4.1.

**HUD at 640x400**
- Root cause of all overlaps: Label/ProgressBar sizes were set before font/style overrides applied, so every label was 23 px and every bar 27 px tall. Sizes are now assigned after `add_child()`.
- Health and Breath bars no longer overlap; AMPOULES, LEVEL/XP and "2–5 SWITCH" are readable.
- Controls legend moved into the gap between the lower panels (two lines) instead of across both panels.
- Route label: panel widened into free space, smaller font, ellipsis instead of running off-screen; the longest label plus distance fits.
- Objective shows up to two full lines.
- Build stamps on the title and HUD read 08.5 (were 07.8).
- Docket "STAGED ROSTERS" no longer lists released cohorts.
- Sootworks objective after the Labour Writ is the run-wide objective (was the stale "Return to Flood Basilica").
- Travel denial text no longer claims only four districts exist.

**Exit leak ("16 resources still in use at exit")**
- Cause: audio players still playing at quit. New `Music.request_quit()` stops and releases every AudioStreamPlayer, clears combat VFX caches, waits briefly, then quits. Menu quit, title quit and window close all use it.
- Music layers now play only while audible (previously all nine Ogg layers decoded constantly at -72 dB).

**Rendering**
- World-material metallic capped at 0.2: with no sky or reflection probe, higher values rendered near-black on the Compatibility renderer.
- Lighter tint for the "dark" console material; the reprint relay console has a lit face on its approach side too.

**Combat**
- Tracers and impact shards share meshes/materials (a Coil Shotgun blast went from 308 to 113 allocated objects).
- Weapon and action sounds use a fixed 8-voice pool instead of a new AudioStreamPlayer per shot (also removes a latent orphan when a sound failed to load).
- No more "Target and up vectors are colinear" warning for vertical tracers or aim lanes.

**State and saves**
- Returning to a district faces back into it (turned from the gate Ninth left by) instead of a hard-coded world -Z, which could face a wall. First arrivals keep the authored facing.
- Deaths in Glass Orchard, Quiet Barracks, the Central Archives, the Public Assembly and the Freight Lift are recorded with their real site (were "Vesper").
- After a witnessed death and an app restart, the main menu offers RECONSTRUCT, keeping Nix's witnessed record (previously only NEW was offered and Nix forgot). Choosing NEW still starts a fresh chain.
- F9 can no longer refill HP, ammo or ampoules: it commits the live state before loading, and is refused while hostiles are engaged (bible: the checkpoint cannot be manually rewound).
- Raising Force or Resolve raises current HP/Breath along with the cap.

**Tests**
- New `tests/godot_codefix_regressions.tscn`: 32 runtime checks covering all of the above, exits with code 1 on failure. All of them fail against the previous code.
- The two existing Godot test scenes now quit through `Music.request_quit()`.

**Considered and left out:** requiring the district guard to see or hear a threatened witness (bible rule) would switch off most of the 08.5 intimidation response in practice, so it is a design decision for later, not a bug fix.

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
