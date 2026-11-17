# Graphics integration 06.3 — source publishing instructions

The full Godot project, in-conversation-generated source PNGs, texture exports and NPC sprite sets are included in the **Build 06.3 ZIP provided in the ChatGPT conversation**. They are *not yet uploaded as binaries in this GitHub repository*. The local build package contains 14 original source PNGs, 5 environment texture derivatives, 5 NPC four-view sets, 3 separate hostile sprites, 27 furniture standees and a Covenant Pistol FPS sprite.

The connected GitHub tool used for this bootstrap supports text commits but did **not** provide local-binary-file ingestion. The repository README and the Runway task-id index have been committed directly; the remainder is **staged, not uploaded**.

## Upload full original source plus runtime assets

1. Download and extract `The_Ninth_Exhale_Godot_Build_06_3_GRAPHICS_INTEGRATED.zip` from the project conversation.
2. Open a terminal in the extracted project directory on Linux.
3. Ensure `git` works and you are authenticated to GitHub for `igotbrainrot-stack` (`gh auth login` if using GitHub CLI).
4. Run `./publish_to_github.sh` from that extracted project.
5. The script clones the existing repository and pushes a **new non-destructive feature branch**. Follow the printed URL to review/create the pull request. Do not merge until Godot F5 testing passes.

The script copies *all* source art under `art/production_sources/new_pass/`, *all* runtime PNGs under `assets/`, and the Godot source/tests/docs, without changing `main` directly. No Git-LFS is required for the current original PNG file sizes. External Runway originals still require separate export/import from the connected Runway asset workspace. Runway task IDs and status are recorded in `art/RUNWAY_BATCH_MANIFEST.json`.

**Never claim a GitHub upload complete until the repository tree visibly contains the files.**
