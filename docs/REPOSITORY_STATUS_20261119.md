# Repository audit — 2026-11-19

## Findings

- The remote `main` branch was only a sparse skeleton: `.gitignore`, `README.md`, two art manifests and a graphics publication note; it was **not a Godot project**.
- The previously existing branch `feature/079x-kinetic-combat-20261118` had a partial graphics/software commit; it was **not** Build 08.5.
- The authoritative Build 08.5 ZIP contains **2,060 non-directory files**, approximately **181.84 MB uncompressed**, including 1,510 runtime assets, 207 art files, 129 documentation files, 84 scripts, 79 tests, 6 scenes and 4 data files.
- Git network access from the sandbox failed DNS resolution, and the available GitHub connector supports individual Git blobs/files and tree objects but not streaming the 169 MB ZIP from the sandbox.
- Therefore this branch cleans up GitHub-facing documentation and establishes a safe import procedure, but **DOES NOT upload the full playable build**.

## Non-destructive cleanup

- Keep original Git history, manifests and art references.
- Provide an explicit project directory structure and a reliable README.
- Exclude Godot cache/build archives and local test output with `.gitignore`.
- Provide import guidance that uses a new feature branch and a draft PR, rather than force pushing `main`.
- Once imported, verify `project.godot`, `scenes/main.tscn`, `scripts/run_state.gd`, assets and test files in the remote tree.

## Remaining actions

1. Obtain the full Build 08.5 ZIP.
2. Run the import from a computer with GitHub network access and write privileges.
3. Verify the resulting branch commit contains the complete source and asset directories.
4. Open and review a pull request. Merge only with owner approval.
5. Archive older historical QA files into a dedicated `docs/history/` **in a separate tested change**; do not move files that existing tests reference without updating those tests.

**No playable build has been pushed as part of this initial recovery commit.**
