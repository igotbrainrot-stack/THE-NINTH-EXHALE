# Build 08.7 — Complete GitHub Upload Guide (for Claude / owner)
**Status:** Handover documentation has been published to GitHub, but the complete Build 08.7 source and binary assets must still be uploaded from a machine with GitHub network access. Do not mark this repository playable until then.

### Source archive and integrity
`The_Ninth_Exhale_Build_087_ASSET_RECONCILED_GODOT_TESTED.zip`
SHA-256 `375bbd75c9471cdece0aecebdb6e1ff4a747d12cacfbc587bf52e2c47401a15c`
2,150 files, 187,755,694 uncompressed bytes, containing `project.godot`, `scenes/`, `scripts/`, `assets/`, `data/`, `tests/`, `art/`, and `docs/`.

The source archive is provided separately to the owner. **A ChatGPT sandbox download link is not a permanent public GitHub source URL.** Claude needs the ZIP file itself, or a verified complete GitHub branch.

### One-command import, Linux
Download the helper `push_build_087_to_github.sh` alongside the archive, then run:
```bash
bash push_build_087_to_github.sh The_Ninth_Exhale_Build_087_ASSET_RECONCILED_GODOT_TESTED.zip
```
The helper clones the repository, branches from `feature/build-087-claude-handover-20261119` into `feature/build-087-complete-source`, extracts the internal project root, imports source/assets, excludes caches and ZIPs, checks large blob size, runs source validations and optional Godot tests, then pushes the branch. **Do not rerun on an existing remote import branch without inspecting differences.**

### Remote verification BEFORE claiming upload complete
- Inspect the actual tree on `feature/build-087-complete-source` for `project.godot`, `scenes/main.tscn`, 84 script files, approximately 1,556 runtime assets, 60 test files and the full game bible.
- Verify several source images and actor sounds are Git blobs (not empty Git LFS pointer placeholders); check the count and total size.
- Clone in a clean folder and run Godot 4.4.1 tests and at least the opening scene.
- Open a DRAFT PR to `main` and do not merge automatically.
- Do not commit the 174 MB ZIP as one Git blob. GitHub blocks files over 100 MiB; the individual source files are much smaller.

### Important facts for Claude
- The existing sparse `main` repository is not a playable game.
- HUD art uses locally generated source images, not Runway individual production exports.
- Existing actor grunts and music are fallback local audio; Runway tasks are an outstanding import queue.
- Many duplicate sprite paths are intentional fallback/gallery references; do not purge without runtime evidence.
