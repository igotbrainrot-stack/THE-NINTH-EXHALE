# Runway audio recovery and technical QA — Build 09.3

**Date:** 2026-11-22  
**Branch:** `art/recovered-runway-audio-20261122` (based on `main`)  
**Source:** owner-provided `ninth exhale assets 01.zip` from the deleted Runway account  
**Source archive SHA-256:** `e780e31ccec6fbdd9a0741067c750edaba788b76530090b387434acc2cf955ad`

The four original MP3s are copied **byte-for-byte** from the supplied archive, without transcoding, remastering or trimming. The exact four files are now committed as source deliveries. These are *not yet wired to Godot runtime playback*; all existing in-game WAV/OGG sounds remain unchanged. Source task IDs, original prompts, output paths, SHA-256 hashes, sizes, and measured durations are recorded in `art/RUNWAY_AUDIO_20261122_MANIFEST.json`.

| Asset | Duration (s) | Bytes | SHA-256 | Peak dBFS (FFmpeg) | Mean dBFS |
|---|---:|---:|---|---:|---:|
| Pneumatic Verdict (combat music) | 30.772167 | 746250 | `9694fd00f6144c885f0e6c169a7839106fe9e03ac1db5bd92e09982ba37d845f` | 0.0 | -14.3 |
| Coil Shotgun Fire | 1.044898 | 17179 | `c0a9bb3caf38949697de3cab6280ba3dd30a5895ef0acea20a7f23778b9f2bfe` | -2.0 | -20.2 |
| Nail Storm Fire | 1.044898 | 17179 | `065c74be8319ec5a7df753263637e1c9b77b39f7e892bed6b58d98356b74b1a2` | -0.4 | -16.7 |
| Choirbreaker Fire | 1.044898 | 17179 | `0954c8a944243771c5b200862a59d30b800b820f25750ed53bc0f1f921949740` | -10.5 | -22.5 |

**Technical validation:** All four files decode with FFmpeg and identify as stereo MP3, 44.1 kHz. Independent SHA-256 and Git-blob SHA-1 checks match the archive's extracted file bytes. Verify locally with `python3 tools/check_runway_audio_20261122.py` (uses FFprobe/FFmpeg when installed).

**Audio QA still required:** Do a proper human listening review for silence, speech, objectionable artifacts, and whether Pneumatic Verdict can loop without an audible click. Music reaches a reported 0 dBFS sample peak; avoid applying positive gain during mixing. The three SFX have substantially different average/peak levels; adjust loudness in the game mixer **without modifying these source files**. These numerical measurements are not a subjective quality pass and are not human game QA.

## Integration notes for Claude

1. Use these exact source paths:
   - `assets/music/runway_20261122/pneumatic_verdict_combat.mp3`
   - `assets/audio/runway_20261122/coil_shotgun_fire.mp3`
   - `assets/audio/runway_20261122/nail_storm_fire.mp3`
   - `assets/audio/runway_20261122/choirbreaker_fire.mp3`
2. For weapons, retain current fallback `assets/audio/coil_fire.wav`, `nail_fire.wav`, `choir_fire.wav` until new cues are playtested with rapid fire and attenuation.
3. Add combat-only track selection and crossfade/loop handling; never play the combat track in enemy-free hub sections.
4. Do not change gameplay logic or the story in the audio import PR. Claude owns audio wiring and runtime tests.
5. Godot's import metadata may be produced on first project import; do not confuse that with a verification that playback triggers correctly.
6. The owner has deleted the Runway account. **Do not request reauthentication or attempt regeneration.** Future work must use retained archives and imported files.