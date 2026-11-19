#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE=""
for cmd in godot godot4 godot-mono; do
  if command -v "$cmd" >/dev/null 2>&1; then ENGINE="$(command -v "$cmd")"; break; fi
done
if [[ -z "$ENGINE" ]]; then
  shopt -s nullglob
  for candidate in "$ROOT"/Godot_v4*linux*.x86_64 "$ROOT"/Godot_v4*linux*.64 "$ROOT"/Godot*linux*; do
    if [[ -f "$candidate" ]]; then
      chmod +x "$candidate" 2>/dev/null || true
      if [[ -x "$candidate" ]]; then ENGINE="$candidate"; break; fi
    fi
  done
fi
if [[ -z "$ENGINE" ]]; then
  echo "ERROR: Godot executable not found." >&2
  echo "Install Godot 4.x (standard) from https://godotengine.org/download/linux/" >&2
  echo "Import project.godot into Godot Project Manager, open it and press F5." >&2
  echo "Or put the extracted Godot executable beside this script." >&2
  exit 1
fi
echo "THE NINTH EXHALE: Starting Godot with engine: $ENGINE"
cd "$ROOT"
exec "$ENGINE" --path "$ROOT"
