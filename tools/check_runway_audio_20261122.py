#!/usr/bin/env python3
"""Verify recovered Runway MP3 sources against their Build 09.3 manifest.

Usage: python3 tools/check_runway_audio_20261122.py
This script audits delivered source files only; it does NOT imply runtime wiring.
"""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "art/RUNWAY_AUDIO_20261122_MANIFEST.json"


def media_details(path):
    if not shutil.which("ffprobe"):
        return None
    check = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries",
         "format=duration:stream=codec_name,sample_rate,channels",
         "-of", "json", str(path)],
        text=True, capture_output=True, check=True,
    )
    result = json.loads(check.stdout)
    streams = [s for s in result.get("streams", []) if s.get("codec_name") == "mp3"]
    if not streams:
        raise ValueError(f"{path}: missing MP3 audio stream")
    audio = streams[0]
    if int(audio.get("channels", 0)) < 1:
        raise ValueError(f"{path}: invalid channel count")
    return float(result["format"]["duration"]), int(audio["sample_rate"]), int(audio["channels"])


def main():
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    failures = 0
    total = 0
    for asset in manifest["assets"]:
        total += 1
        relative = asset["target_path"]
        file = ROOT / relative
        try:
            if not file.is_file():
                raise ValueError("missing file")
            payload = file.read_bytes()
            digest = hashlib.sha256(payload).hexdigest()
            if asset.get("sha256") != digest:
                raise ValueError(f"SHA-256 mismatch: got {digest}")
            if asset.get("size_bytes") != len(payload):
                raise ValueError(f"byte-count mismatch: got {len(payload)}")
            if not asset.get("binary_committed"):
                raise ValueError("manifest does not mark binary as committed")
            details = media_details(file)
            if details is not None:
                seconds, rate, channels = details
                if abs(seconds - float(asset["duration_seconds"])) > 0.05:
                    raise ValueError(f"duration mismatch: got {seconds:.3f}s")
                if rate != asset["sample_rate_hz"] or channels != asset["channels"]:
                    raise ValueError(f"format mismatch: got {rate} Hz, {channels} channels")
            if shutil.which("ffmpeg"):
                check = subprocess.run(
                    ["ffmpeg", "-nostdin", "-v", "error", "-i", str(file),
                     "-f", "null", "-"], capture_output=True, text=True
                )
                if check.returncode:
                    raise ValueError(f"MP3 decode failed: {check.stderr.strip()}")
            print(f"PASS {relative} ({len(payload)} bytes; sha256 {digest[:12]}…)")
        except (OSError, KeyError, ValueError, subprocess.CalledProcessError) as exc:
            failures += 1
            print(f"FAIL {relative}: {exc}", file=sys.stderr)
    print(f"Runway audio audit: {total - failures}/{total} verified, {failures} failed")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())