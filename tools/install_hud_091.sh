#!/usr/bin/env bash
# Install or update the Pressure Docket HUD 09.1 art into the existing Build 09.1+ Godot project.
# No code modifications, merges, deletes, or Git pushes.
set -Eeuo pipefail
GAME="${1:-}"
if [[ -z "$GAME" || ! -f "$GAME/project.godot" || ! -f "$GAME/scripts/game_ui.gd" ]]; then
  echo 'Usage: bash tools/install_hud_091.sh /path/to/THE-NINTH-EXHALE' >&2
  echo 'The target must be the complete Build 09.1+ Godot repository.' >&2
  exit 1
fi
if ! grep -q 'HUD_091_PATH' "$GAME/scripts/game_ui.gd"; then
  echo 'This game build lacks the HUD 09.1 art override loader. Nothing copied.' >&2
  exit 1
fi
HERE="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$GAME/assets/ui/hud_091" "$GAME/art/production_sources/hud_091" "$GAME/docs/handover"
if [[ -e "$GAME/assets/ui/hud_091/hud_091_slices.json" ]]; then
  cp -a "$GAME/assets/ui/hud_091/hud_091_slices.json" "$GAME/assets/ui/hud_091/hud_091_slices.preinstall.bak"
fi
cp -a "$HERE/assets/ui/hud_091/." "$GAME/assets/ui/hud_091/"
cp -an "$HERE/art/production_sources/hud_091/." "$GAME/art/production_sources/hud_091/"
cp -a "$HERE/art/RUNWAY_HUD_091_MANIFEST.json" "$GAME/art/RUNWAY_HUD_091_MANIFEST.json"
cp -a "$HERE/docs/handover/HUD_091_CONTACT_SHEET.png" "$GAME/docs/handover/"
cp -a "$HERE/docs/handover/HUD_091_12PX_ICONS.png" "$GAME/docs/handover/"
cp -a "$HERE/docs/handover/HUD_091_640x400_LAYOUT_MOCK_PLAY.png" "$GAME/docs/handover/"
cp -a "$HERE/docs/handover/HUD_091_640x400_LAYOUT_MOCK_DOCKET.png" "$GAME/docs/handover/"
cp -a "$HERE/docs/handover/HUD_091_INTEGRATION_QA.md" "$GAME/docs/handover/"
python3 "$HERE/tools/verify_hud_091.py" "$GAME"
echo 'HUD 09.1 overrides installed. Open the Godot project to reimport textures and verify gameplay.'
