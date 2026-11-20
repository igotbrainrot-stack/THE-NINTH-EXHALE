# Build 08.7 — source upload and reconciliation (20 November 2026)

## Live GitHub findings
- `main`: Build 08.5, `625152e07b8163b5ac4bc4e603ea5ed79e89ff3d`, project.godot is present, 2,055 Git tree entries.
- PR #3 (`fix/085-code-errors`) is an unmerged draft against main, 25 changed files, 534 additions and 74 deletions.
- PRs #1 and #2 are historical documentation handovers whose descriptions about a skeleton repo are outdated.
- Full Build 08.7 is NOT on the GitHub tree; it is a separate ZIP with SHA256 `375bbd75c9471cdece0aecebdb6e1ff4a747d12cacfbc587bf52e2c47401a15c`, 2,150 non-directory entries and 187,755,694 uncompressed bytes. ZIP integrity passed.

## Suggested integration workflow
Use `tools/push_build_087_to_github.sh` from a machine with authenticated GitHub access (also supplied in the downloadable handover kit). It verifies SHA256, extracts the nested game root, branches from current main, imports source and binaries, runs 272 Python tests and project validator, optionally runs Godot scenes, and pushes a fresh **feature** branch. It intentionally does NOT merge PR #3, modify main, or falsely certify a full playthrough.

After the full import exists remotely, compare each PR #3 modified file against the 08.7 version. Apply fixes selectively and run `godot_codefix_regressions.tscn`. In particular the PR #3 HUD text changes may conflict with Pressure Docket 08.6 UI placements; merge both, not one at the expense of the other.

## Asset status
Current 08.7 ships nine HUD icons, 14 fallback actor audio WAVs and a registry of 778 media files. It does **not** ship cloud Runway MP3s or finished eight-direction Runway repaints. Runway task IDs are tracked in `art/BUILD_087_EXTERNAL_RUNWAY_QUEUE.json` and should never be marked as imported without local source bytes, licence review, alignment/import and Godot verification.

## Test limitation
The supplied 08.7 QA reports real headless Godot 4.4.1 engine tests and 640×400 framebuffer captures, but no full manual combat/endings/audio playthrough. Source checks and screenshots are not proof that all dynamic media appears in typical gameplay. Maintain historical sprite fallback families until every relevant actor/gallery path has been retested.

## Transfer blocker
The GitHub connector is able to write Git trees and docs but cannot stream the sandbox-local 174 MB source archive; direct Git from this environment returns `Could not resolve host: github.com`. The existence of this document on GitHub is **not** a successful upload of Build 08.7. Complete upload from a machine with network access and verify the remote tree and commit SHA.
