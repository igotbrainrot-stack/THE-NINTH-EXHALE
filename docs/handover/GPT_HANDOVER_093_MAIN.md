# GPT handover: Build 09.3 is on `main` (updated for 09.4 audio)

> **Superseded on 2026-11-22 by `GPT_HANDOVER_096_MAIN.md`.** Kept for history; §4.2 (archive audio table) and §4.3 are still referenced from there.

**For:** the GPT session (art, audio, asset QA). **From:** Claude (code, systems, integration).
**Date:** 2026-11-22.

## 1. What changed in how we work

**`main` now holds the playable game, Build 09.3.** On the owner's instruction, the draft stack was merged in order:

| PR | Build | What it added |
|---|---|---|
| #5 | 08.7 | full Build 08.5 source import, with the #3 fixes ported |
| #6 | 08.8 | Runway turnaround art wired into NPCs, enemies and Echoforms |
| #7 | 08.9 | readable checks, perks, XP caps, trust, True Dawn warning |
| #8 | 09.0 | HUD and UI polish |
| #9 | 09.1 | cleanup, HUD art drop-in slot |
| #10 | 09.2 | your HUD art in game; perception phase 1; animation drop-in slots |
| #11 | 09.2 | your weapon art, Linux package and CI (with #12 inside) |
| #13 | 09.3 | weapon art fixes; immersive-sim phase 1b |

Before #13 was merged, its tip passed:
- 297 Python tests;
- 14 project validations;
- all 14 headless Godot suites;
- rendered combat **and** pacifist playthroughs, both reaching **VESPER / LIBERATION** with three Writs;
- the same suites and playthroughs on GitHub Actions.

**From now on:**
1. **Branch from `main`.** Name branches `feature/<topic>-<yyyymmdd>` or `art/<topic>-<yyyymmdd>`.
2. **Open a draft PR into `main`. Don't merge it.** The owner decides merges.
3. **CI runs automatically** on every PR into `main` and every push to `main`:
   - `Godot runtime regression 09.2` (animation, perception, immersive, witness, HUD override and smoke suites)
   - `Full campaign playtest 09.2` (combat and pacifist playbots)

   A red check means fix it before asking for review.
4. **Don't push to `main` directly.**

PRs **#1, #2 and #4** are older recovery and handover drafts against the 08.5 `main`. Their content is superseded and they were left open for the owner to close. Don't build on them.

## 2. Rules that have not changed

- **Provenance:**
  - Record real generator job IDs only, or `null` with a reason.
  - Keep raw downloads byte-identical, with their SHA-256.
  - Add a manifest entry for every runtime file.
  - Never commit signed download URLs or tokens.
- **Canon:** the bible (`docs/MASTER_GAME_BIBLE_FINAL.md`) is the target. Its forbidden visual shortcuts, the no-mirroring rule for asymmetric characters and the originality register (`docs/PROTECTED_ORIGINALITY_REGISTER.md`) all bind.
- **Division of work:** you make images and audio and check how they look in the game. Claude changes code. If art needs a code change, say so in your PR and Claude will do it.
- **Be honest about status.** "Generated" isn't "integrated", and "integrated" isn't "playtested". The README must keep the phrase "not yet playtested" until people have played the game; a test enforces it.

## 3. Where art and audio go (no code changes needed)

| What | Folder | Brief | Check |
|---|---|---|---|
| HUD and UI skins | `assets/ui/hud_091/` | `GPT_HUD_UI_ART_HANDOVER_091.md` | `tests/godot_hud_override_091.tscn` |
| First-person weapons | `assets/weapons/anim_092/<weapon>/` | `GPT_WEAPON_ANIMATION_HANDOVER_092.md` and **`GPT_WEAPON_ART_CORRECTIONS_093.md`** | `python3 tools/anim_092.py check …` and `--script res://tests/godot_weapon_art_092.gd` |
| Enemy and NPC animation | `assets/sprites/anim_092/<stem>/` | `GPT_SPRITE_ANIMATION_HANDOVER_092.md` (plus the `flee` state below) | `python3 tools/anim_092.py check …` and `tests/godot_anim_092.tscn` |
| Runway audio | `assets/music/runway_*/`, `assets/audio/runway_*/`; routing in `data/audio_mix_093.json` | `AUDIO_INTEGRATION_093.md` | `tests/test_build093_audio_mix.py`, `tests/godot_audio_093.tscn` |

All briefs live in `docs/handover/` and in the claude.ai Project under `handover/`.

## 4. Work queue, in priority order

### 4.1 Weapon corrections (highest value; blocks the weapon look)

From `GPT_WEAPON_ART_CORRECTIONS_093.md`:
1. **Coil Shotgun `fire`.** Repaint 6 frames at 18 fps as edits of `coil_idle` frame 0, keeping the glove. The old strip is held back in `art/production_sources/weapons_092/held_back_093/`. When you deliver, add `"fire": {"frames": 6, "fps": 18, "loop": false}` back to `coil.anim.json` and remove `disabled_states_093`.
2. **Nail Storm and Choirbreaker.** Repaint idle (4 frames) and fire (2 and 5 frames) **aimed into the screen** toward the crosshair at (320, 200), not side-on. Keep each weapon's bible identity.
3. **Set `anchors.muzzle`** on your own idle frame 0. The test now fails if it is more than 6 px off the weapon.

Then the missing states (`reload`, `dry`, `draw`, `intervene`), Covenant first.

### 4.2 Commit the other nine surviving Runway audio files (highest audio value)

**Done in 09.4:** the four 2026-11-22 files (Pneumatic Verdict, Coil, Nail, Choir) are wired into the game (`docs/handover/AUDIO_INTEGRATION_093.md`). Listen to `docs/handover/audio_previews_093/` and report anything wrong; tuning lives in `data/audio_mix_093.json`.

Your archive index (`art/SURVIVING_RUNWAY_ARCHIVES_20261122_INDEX.json`) lists nine more MP3s from `ninth exhale assets 01.zip`. Four are the **full Build 07.2 district scores**. Their task IDs are in `art/RUNWAY_072_MUSIC_TASKS.json`; they were never downloaded, so the game has been playing 14–25 s procedural stand-ins.

| Archive file | Length | Commit unchanged to | Runway task ID (07.2) |
|---|---:|---|---|
| Ninth Exhale _ Hearth Nine _ Night Intake.mp3 | 173.4 s | `assets/music/runway_072/hearth_night_intake.mp3` | `7ea21163-a98a-4b39-b55b-c8c41ac3755f` |
| Ninth Exhale _ Sootworks _ Service Debt.mp3 | 174.2 s | `assets/music/runway_072/sootworks_service_debt.mp3` | `e3b7b7b4-6dcb-4586-b6fb-476553a8e08c` |
| Ninth Exhale _ Flood Basilica _ Submerged Choir.mp3 | 176.7 s | `assets/music/runway_072/basilica_submerged_choir.mp3` | `5b529627-26dc-435d-8ec8-f9777c8ef56d` |
| Ninth Exhale _ Pressure Breach _ Combat.mp3 | 117.9 s | `assets/music/runway_072/pressure_breach_combat.mp3` | `38efe738-adab-4fd9-b8e5-29832fecf933` |
| Ninth Exhale _ Basilica acoustic pulse.mp3 | 4.0 s | `assets/audio/runway_archive/basilica_acoustic_pulse.mp3` | find it, or `null` with a reason |
| Ninth Exhale _ Foundry pressure cycle.mp3 | 4.0 s | `assets/audio/runway_archive/foundry_pressure_cycle.mp3` | find it, or `null` |
| Ninth Exhale creature combat vocal effects.mp3 | 6.0 s | `assets/audio/runway_archive/creature_combat_vocals.mp3` | find it, or `null` |
| Ninth Exhale enemy mechanical attack effects.mp3 | 6.0 s | `assets/audio/runway_archive/enemy_mechanical_attacks.mp3` | find it, or `null` |
| Ninth Exhale NPC sequential vocal grunts.mp3 | 5.0 s | `assets/audio/runway_archive/npc_vocal_grunts.mp3` | find it, or `null` |

Do it as you did for PR #14:
- byte-identical files;
- SHA-256 and duration recorded;
- a manifest such as `art/RUNWAY_ARCHIVE_AUDIO_MANIFEST.json`, with `runtime_integrated: false`;
- notes from listening.

For the three effect banks (5–6 s each), also **list the timestamps of each separate sound** in the file (for example "0.00–0.42 growl, 0.55–1.10 shriek"). Claude will cut them into cues at playback without editing the source.

Claude will then:
- loop the district scores on bar lines;
- keep the current Oggs as fallbacks;
- give Hearth Nine its own score, distinct from combat;
- map the effect banks to enemy attacks, creature barks and NPC hurt sounds.

### 4.3 Animation vertical slice: Slag Sifter and Brin

Follow `GPT_SPRITE_ANIMATION_HANDOVER_092.md` §7, "Order of work". 09.3 makes these sprites more visible than before:
- **Patrol `walk` in all 8 facings matters more now.** Guards walk to investigate, search where they lost you and return home, so the player sees them from every side.
- **New NPC state: `flee`** (Brin and Ossa):
  - 6 frames at 10 fps, looping;
  - **all 8 facings**, because they run across the district;
  - a frightened run, a civilian rather than a fighter, carrying nothing new.

  It plays while the witness is running to report. Without it the game shows `threatened`, then `idle`. The file pattern is `brin_flee_<facing>.png`, plus a `"flee"` entry in `brin.anim.json`.

### 4.4 Optional HUD art for the stealth cue

The new cue (`scripts/awareness_cue_093.gd`) sits at **(8, 309), 204×24**, just above the vitals panel. It uses the existing `hud_frame_steel` skin, five lamp pips (7×6 px) and one word in amber, orange or red.

If you want to skin it, deliver a 204×24 `hud_stealth_cue.png` frame in `assets/ui/hud_091/` and say so. Claude will wire it (one line). Don't change its position: it must not cover the vitals, ammo or hazard tells (bible L1350–1368).

## 5. What 09.3 added (so art matches behaviour)

**Guards**
- Guards see and hear deterministically: light at your feet, movement speed, cover and noise radii.
- A hostile patrol that loses you for 6 s **searches** the last place it saw you for 12 s, then stays on **high alert** (sees further and quicker).
- **Barks** are fixed text lines naming the cause ("HEARD THAT.", "LOST THEM. SEARCHING."). There's no voice yet; voiced barks would be an audio task later, with each line in `scripts/perception_092.gd` `BARKS`.

**Witnesses**
- If you threaten Brin or Ossa and no office-holder notices, **they run to tell the Millwright or the Cantor** (this is where `flee` plays). If they arrive, the keeper watches for you; if they die on the way, nobody learns of it.
- Threatened witnesses won't continue their story until you apologise (Speech or Insight 5).

**On screen**
- The HUD cue shows how visible you are and the most alarmed guard nearby.

## 6. Questions only the owner can answer (don't build these until ruled)

- **Hearth Nine enemy-free / Intake Annex.** The 09.2 gap register calls it P0. The bible gives Hearth Nine "1 safe station" and puts a simple enemy there in milestone G1, so this is a design change, not a fix. **Don't make Intake Annex art** until it's ruled.
- **Sprint speed:** bible cap 6.2 m/s, code 8.5 m/s.
- **F9 quickload** inside districts.
- **The 09.3 calm rule** and the council pause while a witness is threatened.

## 7. Checks to run before any PR

```bash
python3 -m pytest -q tests                      # 297+ pass
python3 tests/validate_project.py                # all OK
python3 tools/anim_092.py check assets/weapons/anim_092/* assets/sprites/anim_092/*
godot --headless --path . --script res://tests/godot_weapon_art_092.gd    # 0 failed, exit 0
godot --headless --path . res://tests/godot_anim_092.tscn                  # 0 failed, exit 0
```

Then attach captures at 640×400 from the running game (`tests/godot_weapon_art_capture_092.gd` for weapons), not only contact sheets. Every flaw found this round showed up in the game, not on the sheets.
