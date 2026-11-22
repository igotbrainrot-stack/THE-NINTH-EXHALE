# Pressure Docket HUD 09.1 — complete drop-in art set

For **THE NINTH EXHALE** Godot 4.4.1 `feature/build-091-cleanup-hud-handover-20261121` or newer. This is an **asset override package**, not a stand-alone game build.

The build already supports the `assets/ui/hud_091/` art folder; no script changes are necessary. The 28 art PNGs include the 09.1 optional pieces, and the 08.6 files remain the fallback. All filename/dimension/margin requirements are fulfilled. No content from commercial games is used.

## Install

1. Extract this ZIP into a separate directory.
2. From that directory run `bash tools/install_hud_091.sh /path/to/your/THE-NINTH-EXHALE/`.
3. Open the Godot project, or import headlessly with `godot --headless --editor --path /path/to/your/THE-NINTH-EXHALE --quit`.
4. Review the gameplay and docket UI at the native 640×400 size.

Read `docs/handover/HUD_091_INTEGRATION_QA.md` for provenance, checks and limitations. The two rendered layout mocks are artwork preflights, **not actual game captures**.

This source and art bundle was published on a dedicated feature branch for review. No automatic merge or 09.1 full gameplay certification is implied.
