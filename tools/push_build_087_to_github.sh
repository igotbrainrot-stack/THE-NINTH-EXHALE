#!/usr/bin/env bash
# Safe Build 08.7 full-source import, to run beside ZIP from authenticated networked Linux.
set -Eeuo pipefail
ARCHIVE="${1:-The_Ninth_Exhale_Build_087_ASSET_RECONCILED_GODOT_TESTED.zip}"
EXPECTED="375bbd75c9471cdece0aecebdb6e1ff4a747d12cacfbc587bf52e2c47401a15c"
REPO="https://github.com/igotbrainrot-stack/THE-NINTH-EXHALE.git"
TARGET="feature/build-087-full-import-20261120"
for p in git unzip rsync python3 sha256sum; do command -v "$p" >/dev/null || exit 1; done
[[ -f "$ARCHIVE" ]] || exit 1
[[ "$(sha256sum "$ARCHIVE" | awk '{print $1}')" == "$EXPECTED" ]] || { echo "Bad ZIP checksum"; exit 1; }
ARCHIVE="$(realpath "$ARCHIVE")"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
unzip -q "$ARCHIVE" -d "$WORK/x"
ROOT="$WORK/x/The_Ninth_Exhale_Build_087_ASSET_INTEGRATION"
for f in project.godot scenes/main.tscn scripts/game_ui.gd docs/MASTER_GAME_BIBLE_FINAL.md art/BUILD_087_RUNTIME_ASSET_REGISTRY.json; do
  [[ -f "$ROOT/$f" ]] || { echo "Missing $f"; exit 1; }
done
git clone "$REPO" "$WORK/repo"
cd "$WORK/repo"
git fetch origin main
if git ls-remote --exit-code --heads origin "$TARGET" >/dev/null; then echo "Refusing to overwrite existing $TARGET"; exit 1; fi
git switch -c "$TARGET" origin/main
rsync -a --exclude='.git/' --exclude='.godot/' --exclude='__pycache__/' --exclude='*.zip' "$ROOT/" ./
printf '\n.godot/\n.import/\n__pycache__/\n*.zip\n' >> .gitignore
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
if command -v godot >/dev/null; then
  godot --headless --editor --path . --quit
  for t in godot_scene_smoke_084 godot_witness_threat_085 godot_hud_086 godot_asset_runtime_087; do
    HOME="$(mktemp -d)" godot --headless --path . "res://tests/$t.tscn"
  done
else echo 'Godot 4.4.1 engine validation required prior to merge.'; fi
git add -A
(( $(git diff --cached --name-only | wc -l) > 40 )) || { echo "Partial upload suspected"; exit 1; }
git commit -m "feat: import complete verified Build 08.7 Godot sources and assets"
git push -u origin "$TARGET"
echo 'Verify remote tree and open draft PR. Selectively port PR #3 after conflict review.'
