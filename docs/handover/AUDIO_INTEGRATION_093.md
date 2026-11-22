# Runway audio integration (Build 09.3, on top of PR #14)

GPT recovered the four original Runway MP3s from the owner's archive (PR #14). Claude has wired them into the game. **The source files are unchanged.** Every adjustment (level, start point, loop points, voice limits) happens at playback, and is set in `data/audio_mix_093.json`.

## What the measurements showed, and what the game does about it

Measurements come from FFmpeg (EBU R128) plus envelope and onset analysis in numpy. No person has listened yet; preview renders are in `docs/handover/audio_previews_093/`.

| Sound | What the file is | In-game handling |
|---|---|---|
| **Coil Shotgun** (1.045 s) | Swells for **330 ms** before its peak, so the shot would feel late. −12.2 LUFS. | One-shot from **0.12 s**, at −11 dB, with the original short crack layered at −16 dB for an instant attack. |
| **Nail Storm** (1.045 s) | A **0.6 s burst of rivets** starting at once, −9.0 LUFS (the loudest). The gun fires every 0.09 s, so playing it per shot would stack about 7 copies into mud. | **Burst bed** at −17 dB, restarted at most every 0.5 s while the trigger is held, faded out 0.12 s after release. The original short tick plays on each shot at −14 dB, so the cadence stays readable. |
| **Choirbreaker** (1.045 s) | A **sustained 1 s tone**, quiet (−25.7 LUFS, peak −10.5 dBFS). The gun refires every 0.44 s. | **Mono** at −9 dB: each shot cuts the previous tone, so tones never stack. |
| **Covenant Pistol** | no Runway sound | unchanged original WAV |
| **Pneumatic Verdict** (30.77 s) | **145 BPM** (beat 0.41385 s, measured 144.98), first downbeat at 0.030 s. Bar 1 is a quieter intro. The file **ends mid-phrase at full level** (it starts from silence), so a plain loop would jump from loud to silent every 30 s. −12.8 LUFS against −15.3 for the existing combat score. | Plays from the top once, then **loops bars 2–18** (1.6854 → 29.8272 s, exactly 17 bars) by handing over between two players with a **60 ms equal-power crossfade**. Trimmed −2.5 dB to sit with the other district scores. The original `pressure_breach_combat.ogg` remains the fallback. |

**Loop seam check** (offline render of exactly what the game plays): the largest sample jump at the handover is 0.127, below the track's own 99.9th-percentile jump of 0.189. The level is −17.0 dB before, −18.9 during and −19.6 after (100 ms windows). There is no measurable click; confirm by ear in `combat_loop_seam_preview.mp3`, where the seam is at **10.0 s** and again 28 s later.

**Before and after:** `weapons_before_fallback.mp3` and `weapons_after_runway.mp3` play the same pattern: Coil ×3, Nail held for 1.5 s, Choir ×4. Peaks are −14.7 dBFS before and −12.9 dBFS after, so the new set sits about 2 dB hotter at peak.

## Combat music now follows real combat (stealth fix)

The music director used to start battle music whenever the player was within about 13 m of any **optional enemy, even an unaware one**. Under 09.2/09.3 perception that gave stealth away: the score announced a guard who hadn't noticed you. Combat music now starts only for enemies that are actually **hostile** within 23 m, and calms 7 s after the fight ends.

Hearth Nine has no combat score unless something there is fighting you.

## Swapping or tuning without code

In `data/audio_mix_093.json`:
- Set any weapon's `"source"` to `"fallback"` to return to its WAV.
- Change `volume_db`, `start_offset`, `retrigger` or `release`.
- Remove the `music.combat` entry to return to the Ogg score.

Replacement files from GPT go next to the originals, with a manifest entry, and the path is changed here.

## Tests

- `tests/godot_audio_093.tscn` (17 checks):
  - routing and fallbacks
  - the coil attack layer
  - the nail bed restarting every ~0.5 s rather than every shot, and fading on release
  - choir tones cutting each other
  - the loop handover at the bar line
  - the director using the looped track at −2.5 dB
- `tests/test_build093_audio_mix.py`:
  - source hashes match the manifest (no edits)
  - every replacement keeps its fallback
  - the loop is a whole number of bars inside the file
  - combat music requires real hostility

## Still needed

- **Human listening** on speakers and headphones: tone, the coil start offset, nail bed density, choir level, and the loop seam.
- **The three numbers most likely to need tuning by ear:** coil `start_offset` (0.12 s), nail `volume_db` (−17) and choir `volume_db` (−9).
