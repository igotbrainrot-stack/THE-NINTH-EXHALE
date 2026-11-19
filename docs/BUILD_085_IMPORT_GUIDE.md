# Build 08.5 — full import guide

Use the complete `The_Ninth_Exhale_Build_085_WITNESS_RESPONSE_GODOT_TESTED.zip` archive. Do not import a handover-only ZIP or an older 07.9 version.

### Safe procedure (local workstation with Git network access)

```bash
git clone https://github.com/igotbrainrot-stack/THE-NINTH-EXHALE.git
cd THE-NINTH-EXHALE
git fetch origin
git switch -c feature/build-085-complete-source origin/feature/build-085-repository-recovery-20261119

mkdir -p /tmp/ninth-exhale-085-import
unzip -q /path/to/The_Ninth_Exhale_Build_085_WITNESS_RESPONSE_GODOT_TESTED.zip -d /tmp/ninth-exhale-085-import

# Copy CONTENTS of the top-level archive folder into repo root.
rsync -a --exclude='.godot/' --exclude='*.zip' \
  /tmp/ninth-exhale-085-import/The_Ninth_Exhale_Build_085/ ./

# Retain this branch's clean README + .gitignore.
git status --short
git add -A
git diff --cached --stat
git commit -m "Import complete Godot Build 08.5 source and assets"
git push -u origin feature/build-085-complete-source
```

Open a draft PR targeting `main`. Do not merge automatically.

### Verify on GitHub

The new branch must contain the actual `project.godot`, `scenes/`, `scripts/`, `assets/`, `data/`, `tests/`, `art/`, and `docs/` directories, with sizes and counts consistent with the ZIP. Verify several PNG/WAV files in the remote tree, not just manifest entries.

### Verify in Godot

```bash
godot --headless --editor --path . --quit
godot --path .
```

Follow the Build 08.5 QA report for test entry points. Verify opening sequence and transitions, audio, saves, Rootkin hearing, Brin/Ossa intimidation and all four endings before release.

### GitHub upload limitations

GitHub normally rejects individual files above 100 MiB; do not commit the 169 MB ZIP as a single Git blob. The individual project files in Build 08.5 are much smaller and should be imported individually. If a future asset exceeds normal Git limits, evaluate Git LFS only after checking quota and collaborators' workflows.
