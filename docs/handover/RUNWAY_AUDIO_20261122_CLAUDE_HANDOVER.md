# THE NINTH EXHALE — Runway audio handoff for Claude
Date (UTC): 2026-11-22
Repository: https://github.com/igotbrainrot-stack/THE-NINTH-EXHALE
Active branch: `feature/weapon-art-092-20261122`
Draft PR: https://github.com/igotbrainrot-stack/THE-NINTH-EXHALE/pull/11

## Accurate delivery status
The user authorized spending the last seven Runway credits on one original techno-industrial combat music clip (4 credits) and three one-second weapon SFX (1 credit each). All four generation requests were **accepted** and returned Runway task IDs. The balance reached **zero**.

**IMPORTANT: This commit contains the full source prompts, task IDs and import plan, NOT the MP3 audio bytes.** The Runway API subsequently returned `401: The token has been revoked` during retrieval; generation completion, listening QA, downloads and runtime integration could not be verified. Do not represent these four sounds as bundled or playable in the repository until the actual MP3s have been imported and checked. Do not substitute procedural sounds and call them Runway originals.

Machine-readable source: `art/RUNWAY_AUDIO_20261122_MANIFEST.json`.

## Runway tasks and intended files

| Asset | Runway task ID | Credits | Target path |
|---|---|---:|---|
| Combat cue: **Pneumatic Verdict** | `5fdebefa-9b27-461f-83eb-35a514b728bc` | 4 | `assets/music/runway_20261122/pneumatic_verdict_combat.mp3` |
| **Coil Shotgun** fire | `54da5bc5-407b-4b9b-aad6-425ec4584f98` | 1 | `assets/audio/runway_20261122/coil_shotgun_fire.mp3` |
| **Nail Storm** fire | `ad91da3d-de21-4033-ae4d-e0a1966cd638` | 1 | `assets/audio/runway_20261122/nail_storm_fire.mp3` |
| **Choirbreaker** fire | `8cb8c083-db88-4add-a846-be9ce690e749` | 1 | `assets/audio/runway_20261122/choirbreaker_fire.mp3` |

Music brief: 1980s analog techno-industrial battle music, heavy-metal intensity, roughly 145 BPM, distorted synth bass, gated drums, mechanical percussion, no vocals. Exact prompts are preserved in the JSON manifest.

## Steps for Claude after the Runway connection is restored
1. Retrieve each **existing** task ID; do **not** regenerate or spend credits. Verify each task actually succeeded and fetch its output MP3 using the returned asset URL. If the Runway API remains disconnected, request a Runway reconnection or have the user export the four MP3s manually. Signed asset URLs can expire; do not commit them to the repository.
2. Save each original MP3 to the corresponding target path. Preserve unmodified originals and add a SHA-256 and actual audio duration to the manifest. Update `completion_status`, `binary_committed` and `runtime_integrated` individually only after verification.
3. Preview/listen to each sound. Ensure no unwanted speech or silence, check clipping, and measure true peak/loudness. The SFX were **requested** at 1 second each; inspect actual output lengths before trimming or sequencing.
4. Import in Godot 4.4.1 and confirm playback in a rendered/audio-capable environment. Existing runtime fallbacks are `assets/audio/coil_fire.wav`, `assets/audio/nail_fire.wav` and `assets/audio/choir_fire.wav`. Keep those until new weapon SFX pass in-game QA. The existing procedural combat bed is `assets/music/pressure_breach_combat.ogg`; do not overwrite it. Introduce new MP3s as selectable/replaceable assets, with safe fallbacks.
5. For music, test transitions into and out of combat, avoid abrupt loop clicks (edit/crossfade if needed), and ensure battle intensity does not spill into the safe hub. Keep hub ambience/music distinct from combat.
6. For weapon SFX, test one-shot trigger timing, no unintended stacking distortion, reload/firing cadence, positional/nonpositional routing and volume against music; validate Coil, Nail and Choir each fire the correct asset.
7. Commit binary MP3s and verified manifest updates to the same development branch or a deliberate continuation branch. Run existing project validation and Godot audio smoke tests before claiming integrated.
8. Keep PR #11 draft until its separate gameplay, safe-hub and release gates are satisfied. Do not merge it merely because audio files are available.

## Preservation and handoff notes
- Do not change story, civic Writ invariants, campaign outcomes or other systems for this audio-only import.
- Avoid checking in transient signed Runway download links or access tokens.
- Existing fallback WAV/OGG assets are not Runway originals.
- This handoff is a factual inventory, not a claim that all generated files are in Git.
- Await further user/Claude direction after documenting the audio task IDs.
