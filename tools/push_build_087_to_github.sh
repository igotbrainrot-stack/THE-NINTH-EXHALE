#!/usr/bin/env bash
# Upload complete Build 08.7 from a local computer with authenticated git access.
set -Eeuo pipefail
ARCHIVE="${1:-The_Ninth_Exhale_Build_087_ASSET_RECONCILED_GODOT_TESTED.zip}"
REPO="https://github.com/igotbrainrot-stack/THE-NINTH-EXHALE.git"
BASE="feature/build-087-claude-handover-20261119"
TARGET="feature/build-087-complete-source"
for bin in git unzip rsync python3; do command -v "$bin" >/dev/null || { echo "Missing $bin" >&2; exit 1; }; done
[[ -f "$ARCHIVE" ]] || { echo "Missing archive: $ARCHIVE" >&2; exit 1; }
ARCHIVE="$(realpath "$ARCHIVE")"
if [[ ! -d THE-NINTH-EXHALE/.git ]]; then git clone "$REPO" THE-NINTH-EXHALE; fi
cd THE-NINTH-EXHALE
[[ -z "$(git status --porcelain)" ]] || { echo "Working tree not clean" >&2; exit 1; }
git fetch origin "$BASE"
git ls-remote --exit-code --heads origin "$TARGET" >/dev/null 2>&1 && { echo "Import branch exists; refuse overwrite" >&2; exit 1; }
git switch -c "$TARGET" "origin/$BASE"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
unzip -q "$ARCHIVE" -d "$TMP"
ROOT="$(find "$TMP" -name project.godot -type f -print -quit)"
[[ -n "$ROOT" ]] || { echo "No project.godot in ZIP" >&2; exit 1; }
ROOT="$(dirname "$ROOT")"
for d in assets scripts scenes tests art docs data; do [[ -d "$ROOT/$d" ]] || { echo "Missing $d" >&2; exit 1; }; done
rsync -a --exclude='.godot/' --exclude='__pycache__/' --exclude='*.zip' "$ROOT/" ./
cat > .gitignore <<'IGNORE'
.godot/
.import/
__pycache__/
.pytest_cache/
*.py[cod]
.venv/
*.tmp
*.log
*.zip
/dist/
/exports/
Godot_v*.x86_64*
IGNORE
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
if command -v godot >/dev/null; then
  godot --headless --editor --path . --quit
  for test in godot_hud_086 godot_asset_runtime_087 godot_scene_smoke_084; do
    godot --headless --path . "res://tests/$test.tscn"
  done
else echo "Warning: run Godot 4.4.1 tests before merge"; fi
git add -A
[[ "$(git diff --cached --name-only | wc -l)" -gt 500 ]] || { echo 'Only a partial import staged' >&2; exit 1; }
git diff --cached --stat | tail -15
git commit -m 'Import complete Godot Build 08.7 source and asset inventory'
git push -u origin "$TARGET"
echo 'Complete-source feature branch uploaded. Verify remote and open draft PR.'
