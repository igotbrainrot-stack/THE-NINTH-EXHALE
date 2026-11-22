# GPT handover: Build 09.6 (bible fixed, the Unsaid in game)

**For:** the GPT session (art, audio, asset QA). **From:** Claude (code, systems, integration).
**Date:** 2026-11-22. **Replaces** `GPT_HANDOVER_093_MAIN.md` as your working brief. That file stays for history.

## 1. Where the code is

`main` is still **Build 09.3**. Three draft PRs are stacked on it, waiting for the owner to merge:

| PR | Build | Branch | What it adds |
|---|---|---|---|
| #15 | 09.4 | `feature/build-094-runway-audio-20261122` | your Runway audio in game, stealth-safe combat music |
| #16 | 09.5 | `feature/build-095-doom-techniques-20261122` | DOOM-era techniques, combat callouts |
| #17 | 09.6 | `feature/build-096-consolidation-20261122` | story/gameplay/art consolidation, **bible errata**, **the Unsaid**, difficulty modes |

**Branching:**
- Art that only drops files into existing slots can branch from `main`.
- **Anything for the Unsaid, the machine captions or the difficulty screen depends on 09.6.** Branch it from `feature/build-096-consolidation-20261122` and open the draft PR into that branch, not `main`.

The usual rules still hold: draft PRs only, CI must be green, and don't push to `main`.

## 2. What changed in the canon (bible Appendix F)

On 22 November the owner asked Claude to fix the bible. Every change is logged with the text it replaced in `docs/MASTER_GAME_BIBLE_FINAL.md`, **Appendix F**. The ones that affect your work:

- **Only people speak.**
  - Guards, office staff, and frames worked by a named office-holder (the Millwright, the Commandant) speak barks and callouts.
  - **Automata have no words.** Their state changes and attacks show as bracketed sound captions, such as `[SENSOR TICKS]` and `[PRESSURE BUILDS]`. These are the crawlers, mites, turrets, sifters, haulers, Choir Reed, Triage Warden and regulators.
  - **The Unsaid repeat fragments** of their district's remembered speech, never tactical words.
  - Each enemy's kind is the `voice` field in `data/enemy_roster_068.json`.
- **The Unsaid are in the game.** There is one resident "Unsaid Residue" in Sootworks (bible §2.2, §9). It has 70 HP, a 12-damage contact lunge and a 0.65 s cue, and the Choirbreaker (Sonic) breaks its loop. **Its art is a placeholder:** the Saltbound Porter turnaround tinted mauve. Your art replaces it (§4.1).
- **The hearing has five commands:** Press, Attune, Brace, Observe, Withdraw. The bible's old four-move art line ("strike, resonate, guard, listen") is gone. Any hearing-portrait art needs five distinct cues.
- **Difficulty modes are built:** Steady, Severe and **Testimony**, the story-access mode. It was called "Witness", which clashed with the Witness build preset.
- **Pellets fly a fixed pattern**, not a random scatter. If a Coil or Nail fire strip shows a spread, it can now match a known pattern: a centre plus a ring of seven.
- The bible's header no longer says "not engine-implemented", and §11.9 no longer says no sprites exist.

## 3. Rules that have not changed

- **Provenance:**
  - Record real generator job IDs, or `null` with a reason.
  - Keep raw downloads byte-identical, with SHA-256.
  - Add a manifest entry for every runtime file.
  - Never commit signed URLs or tokens.
- **Canon:** the bible binds, including its forbidden visual shortcuts, the no-mirroring rule for asymmetric characters, and `docs/PROTECTED_ORIGINALITY_REGISTER.md`.
- **Division of work:** you make images and audio and check them in the running game. Claude changes code. If art needs a code change, say so in the PR.
- **Honest status:** "generated" isn't "integrated", and "integrated" isn't "playtested". The README keeps "not yet playtested".

## 4. Work queue, in priority order

### 4.1 The Unsaid Residue (new, highest story value)

The bible's own monster has no art. Read bible §2.2 ("Where monsters come from"), the §9 matrix row "Unsaid residue" and §11.4 before you start.

- **What it is:** an unstable loop of discarded memory bound to contaminated material. It is an incomplete figure that repeats a worker's habits and voice without understanding them. It is **not** a tooth-covered lump, a generic demon or gore.
- **Where it is:** Sootworks. Its fragments are Sootworks speech: "...MITTENS FOR STOVE COAL... FAIR TRADE...", "...SHIFT NINETY-ONE... SIGN HERE...", "...WHERE DID I PUT THE TOY..." (full list: `data/enemy_roster_068.json`, `residents_096`). So it reads as a furnace worker half-remembered: work clothes that don't resolve, a repeated gesture (signing, clocking in), parts missing or doubled.
- **Palette:** the bible's memory-residue colour is bruised mauve `#716076` (§11.1). Use it as an accent on top of Sootworks ash-black, burnt orange and olive work-cloth, not as a full-body wash.
- **Height:** civilian 100% (§11.3). Use a 192×256 cell with feet on the baseline.
- **States** (`GPT_SPRITE_ANIMATION_HANDOVER_092.md` spec), all **8 facings**:

| State | Frames @ fps | Notes |
|---|---|---|
| `idle` | 4–6 @ 4 | the repeated habit (signing a sheet that isn't there) |
| `walk` | 6–8 @ 8 | it walks remembered routes |
| `windup` | 4 @ 6, ≈0.65 s | the **0.65 s sensory cue** before the lunge; must read without colour alone (bible §9: "avoid relying only on tint") |
| `rush` | 6 @ 12 | the committed lunge |
| `hurt` | 2–3 @ 10 | also used when the Choirbreaker breaks its loop; a "skip" or glitch reads well |
| `death` | 6–8 @ 10 | the loop unravels; last frame stays as the remains; no gore |

- **Delivery:** `assets/sprites/anim_092/unsaid_residue/` with `unsaid_residue.anim.json`. **The game switches from the placeholder automatically and drops the mauve tint** as soon as that file exists. Run `python3 tools/anim_092.py check assets/sprites/anim_092/unsaid_residue` and `tests/godot_consolidation_096.tscn`.

### 4.2 Replace the flat placeholders

Full brief: `docs/handover/GPT_ART_CONSOLIDATION_096.md`. In short:
1. **Priority 1:** Kest-07, Venn-of-Glass, the Collector, Core Actuator, Garden Root Actuator and the Commandant's frame are still 07.x block sprites beside the painted cast. Venn's file is a painted body with a flat apron and cage pasted over it.
2. **Priority 2:** Rootkin reads as a stag, and Bell Wretch has a cartoon face. Both are hearing participants, so they also need large hearing portraits with **five** command cues.
3. **Priority 3:** proportions only. Make Brin short and broad, and give Ossa a long neck. Their props (goggles, brass prosthesis, copper voice-box) are already right.

### 4.3 Weapon corrections (carried from 09.3)

Unchanged from `GPT_WEAPON_ART_CORRECTIONS_093.md`:
1. Coil `fire` without losing the glove.
2. Nail Storm and Choirbreaker aimed into the screen.
3. Muzzle anchors on your own idle frame 0.
4. Then `reload`, `dry`, `draw` and `intervene`, Covenant first.

### 4.4 Audio: sounds for the machine captions (new)

The bible wants subtitles for every narratively important sound (§12). Machines now show captions for sounds that don't exist yet. One short original sound per caption (0.2–1.0 s, mono, no music):

| Caption | When | Caption | When |
|---|---|---|---|
| `[SENSOR TICKS]` | suspicious | `[BARREL CYCLES]` | line-attack wind-up |
| `[SERVOS TURN]` | investigating | `[PRESSURE BUILDS]` | heavy wind-up |
| `[TARGET TONE]` | hostile | `[MOTOR REVS]` | rush wind-up |
| `[SWEEP CYCLE]` | searching | `[EMITTER OPENS]` | signal wind-up |
| `[ALARM HUM]` | high alert | `[WINCH LOCKS]` | pull wind-up |
| `[IDLE HUM]` | calm again | `[PLATING BUCKLES]`, `[VALVE SHRIEKS]` | flinch |
| `[ALARM TONE]` | saw an ally destroyed | | |

- **Deliver:** byte-identical files in `assets/audio/runway_096_captions/`, named after the caption in snake case (`sensor_ticks.mp3`).
- **Manifest:** `art/RUNWAY_096_CAPTION_AUDIO_MANIFEST.json`, with task IDs, SHA-256, duration and `runtime_integrated: false`.
- Claude will route them through `data/audio_mix_093.json`.
- If a Runway effect bank from the archive (§4.5) already holds suitable sounds, list their timestamps instead of generating new ones.

**Optional:** whispered, looped voice fragments for the Unsaid, one per line in `residents_096`. The voice should be an indistinct worker repeating; no words beyond those lines.

### 4.5 Runway archive audio (carried from 09.3)

These are still not committed: the nine archive MP3s, including the four full Build 07.2 district scores. Commit them byte-identical with a manifest. List the effect-bank timestamps. The table is in `GPT_HANDOVER_093_MAIN.md` §4.2.

### 4.6 Brin and Ossa `flee`, and the Slag Sifter slice (carried)

These are unchanged from `GPT_HANDOVER_093_MAIN.md` §4.3. Patrol `walk` in all eight facings matters even more now, because guards search and the Unsaid walk their routes.

### 4.7 Optional: health icon

The bible's HUD calls for a pressure bellows, not a heart. A 24×24 bellows or pressure-gauge pictogram in `assets/ui/hud_091/icon_health.png` replaces it with no code change.

## 5. Questions for the owner (don't build until ruled)

The seven 09.6 rulings are made; see the bible's Appendix F. These are still open:
- **Hearth Nine enemy-free / Intake Annex:** a design change, not a fix. No Intake Annex art until ruled.
- **Sprint speed:** bible cap 6.2 m/s, code 8.5 m/s.
- **F9 quickload** inside districts.
- **Merging PRs #15, #16 and #17.**

## 6. Checks before any PR

```bash
python3 -m pytest -q tests                      # 322+ pass
python3 tests/validate_project.py                # all OK
python3 tools/anim_092.py check assets/weapons/anim_092/* assets/sprites/anim_092/*
godot --headless --path . res://tests/godot_consolidation_096.tscn         # Unsaid, pellets, difficulty
godot --headless --path . res://tests/godot_anim_092.tscn
godot --headless --path . --script res://tests/godot_weapon_art_092.gd
```

Then attach 640×400 captures from the running game, not only contact sheets. The Unsaid should be captured in Sootworks, mid-wind-up, next to the HUD.
