#!/usr/bin/env bash
# Scripted playthrough with rendered frames. Needs a display (or xvfb-run).
# usage: tools/playbot_090/run_playbot.sh <out_dir> [seconds=420]
# Frames, grid dumps and log.txt land in <out_dir>. Uses a throwaway HOME so
# the bot's attempt never touches your own saves.
set -eu
here="$(cd "$(dirname "$0")/../.." && pwd)"
out="$(mkdir -p "$1" && cd "$1" && pwd)"
godot="${GODOT:-godot}"
export CAP_DIR="$out" BOT_SECONDS="${2:-420}" HOME="$(mktemp -d)"
"$godot" --headless --path "$here" --import >/dev/null 2>&1 || true
if command -v xvfb-run >/dev/null && [ -z "${DISPLAY:-}" ]; then
  xvfb-run -a -s "-screen 0 1280x800x24" "$godot" --rendering-driver opengl3 --path "$here" res://tools/playbot_090/playbot.tscn | tee "$out/log.txt"
else
  "$godot" --path "$here" res://tools/playbot_090/playbot.tscn | tee "$out/log.txt"
fi
