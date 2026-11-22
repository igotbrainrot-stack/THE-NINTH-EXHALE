# THE NINTH EXHALE — story, gameplay and art consolidation review (Build 09.6)

Repo copy of the Claude doc of the same name (2026-11-22). The doc is the living version. Canon: `docs/MASTER_GAME_BIBLE_FINAL.md`.

## Summary

The game's core still matches the bible. The drift was in the newest layers, and Build 09.6 fixes the code side of it. The bible's binding rules hold in code: deterministic checks, finite resources, witness-based records, three of five Writs, the four endings and their gates, the Voss/Commandant split, five hearing commands and no kill XP.

What had drifted:

- **Story:** 09.3 barks and 09.5 callouts gave every enemy human speech, including crawlers, turrets and actuators. The Unsaid, the bible's own monster, never appear in the game.
- **Gameplay:** 09.5's flinch ignored the bible's per-weapon stagger column and invented a damage rule instead. The assembly vote was counted in "rolls".
- **Art:** the 09.1 HUD frames cut through their own titles. Hearth Nine, Sootworks and Quiet Barracks were lit off the bible's space table. Eight sprites are flat placeholders or off-model, and two more need small proportion fixes.

Build 09.6 (branch `feature/build-096-consolidation-20261122`, stacked on PR #16) fixes the code-side items, with tests. The sprites need new GPT art: `docs/handover/GPT_ART_CONSOLIDATION_096.md`. Seven points need the owner's ruling (below).

## Story

| Finding | Bible | In the game | Status |
|---|---|---|---|
| Every enemy spoke human lines ("SOMEONE THERE?", "MAN DOWN!"), including the Intake Crawler, Vent Whistler turret, Slag Sifter and the actuators | Automata are sensors, valves and sweeps (§9 matrix); the Unsaid only repeat without understanding (§2.2) | 09.3 barks and 09.5 callouts used one table for all 19 combat actors | **Fixed in 09.6.** People speak; machines show captioned sounds ("[SENSOR TICKS]", "[PRESSURE BUILDS]") and don't read Ninth's reload |
| The Unsaid never appear | The basic enemy (§2.2, §9: "Unsaid residue", grunt tier) and a P0 art target (§11.9) | No enemy, line or record names them | **Owner ruling**, then GPT art |
| Vote count read "Affirmative rolls: 2 / 3" | No hidden roll decides the ending (§13) | Reads like dice | **Fixed in 09.6:** "Affirmative constituencies" |
| Ninth given a pronoun ("HE'S RELOADING") | Ninth has no pronoun in the bible | Draft 09.5 lines | Fixed in 09.5; 09.6 adds a test |
| Two planning docs describe Build 05 and "no runnable Godot FPS" | — | `docs/NEXT_STEPS_ROADMAP.md`, `docs/DEVELOPMENT_HANDOVER.md` | **Fixed in 09.6:** marked historical |

## Gameplay

| Finding | Bible | In the game | Status |
|---|---|---|---|
| Flinch built from raw damage | §8 stagger column: Covenant 8, Coil 35 a shot, Nail Storm 3, Choirbreaker 17 | 09.5 pain meter counted damage | **Fixed in 09.6.** A held Nail Storm flinches a Slag Sifter 2 times in 3 s (was 4); one Coil shot still flinches it at once |
| Machines punished Ninth's reload | Office enforcers have the "exposed reload window" (§9) | Any hostile in view attacked within 0.3 s | **Fixed in 09.6:** only people call and press a reload |
| Enemy health below the bible's pacing | Grunt 70, enforcer 125, elite 240, mini-boss 420, Custodian 650 HP (§8) | Crawler 32, Pressure Mite 20, Enforcer 70, keepers 90–210 | **Owner ruling** (provisional numbers) |
| Coil and Nail pellets scatter randomly | "Fixed physics ticks, not narrative RNG" (§8) | Unseeded random spread | **Owner ruling** |
| Difficulty modes missing | Steady, Severe, Witness (§13) | None; "Witness" is also a preset (§7) | **Owner ruling** |

## Art style

| Finding | Bible | In the game | Status |
|---|---|---|---|
| HUD frame rims cut through "HEARTH NINE", "COVENANT PISTOL" and the top line of health and Breath | Small text readable at gameplay scale (§11.6, §13) | 09.1 frames have a 5 px file-card tab above the rim | **Fixed in 09.6:** tab drawn above the panel; test for drawn-frame overlap |
| Hearth Nine lit khaki-grey | Warm clinical lamps, pale blue enamel (§11.2) | Ambient `#aeb4a6` | **Fixed:** `#c4bca8` |
| Sootworks flat beige | Pulsing furnace light, burnt orange (§11.2) | `#b09d84`, static | **Fixed:** `#c39a74`, 2.6 s glow of ±0.04 (cosmetic) |
| Quiet Barracks warm | White security light, dark blue (§11.2) | `#b7b4a2` | **Fixed:** `#b8c0c4` |
| Brin and Ossa body shapes (minor) | Brin short and broad; Ossa long-necked (§11.3) | Props right (goggles, prosthesis, voice-box); bodies average | **GPT art** (proportions only) |
| Venn-of-Glass half placeholder | Pale padded coat, glass-worker gloves (§11.3) | Painted body with a flat apron and cage pasted over it | **GPT art** |
| Kest-07, Collector, Core Actuator, Gardener, Commandant are flat block placeholders | One painted sprite language (§11.6) | 07.x placeholders beside the 08.8 cast | **GPT art** |
| Rootkin reads as a stag | Rounded shoot-body on root braces (§11.4) | Antlered stick figure | **GPT art** |
| Bell Wretch has a cartoon face | Bell shell on two uneven legs (§11.4) | Round face with eyes and mouth | **GPT art** |

The 09.1 HUD art itself is close to the brief (cold iron, brass fittings, about 28 colours a frame). The health heart is the one generic trope left; the bible asks for a pressure bellows.

Before/after captures: `docs/research/consolidation_096/`.

## Fixed in Build 09.6

| Fix | Where | Test |
|---|---|---|
| Voice kinds: 15 roster enemies tagged `speech` or `machine`; machine barks and callouts are captioned sounds; machines ignore reloads | `data/enemy_roster_068.json`, `perception_092.gd`, `sense_092.gd`, `callouts_095.gd`, `enemy.gd` | `godot_callouts_095` 15 checks (was 11) |
| Flinch fed by the bible's stagger column | `weapon_catalog.gd`, `player.gd`, `enemy.gd` | `godot_doom_095`; all four weapons checked against the bible table |
| "Affirmative constituencies" | `main.gd` | `test_build096_consolidation.py` |
| HUD frame tabs above panels; stealth cue at (8, 309) | `game_ui.gd`, `awareness_cue_093.gd` | `godot_codefix_regressions` 40 checks |
| District light per the bible | `main.gd` | `test_build096_consolidation.py` (glow ≤ 0.05, ≥ 2 s period) |
| Old planning docs marked historical | two docs | `test_build096_consolidation.py` |

## Owner rulings needed

1. **Which enemies are machines?** Five are a judgement call: Millwright Power Frame (set to speak, as a frame worked by an office-holder), Chain Hauler, Choir Reed, Triage Warden (all set to machine) and Saltbound Porter (set to speak). One word each in `data/enemy_roster_068.json`.
2. **Bring in the Unsaid?** The bible's basic enemy and the city's own monster; the game has none.
3. **Bible erratum, hearing moves:** §11.6 (line 1258) lists four moves; §2 and the game use five commands.
4. **Bible erratum, status lines:** the header says "SPECIFIED, NOT ENGINE-IMPLEMENTED" and §11.9 says no sprites exist. Both are out of date since the early builds.
5. **"Witness" names two things:** a build preset (§7) and a difficulty mode (§13). Difficulty modes are not built yet.
6. **Enemy health:** raise to the bible's provisional pacing, or record the lower numbers as targets.
7. **Random pellet spread:** keep, or use a fixed pellet pattern.

## Checked and consistent

- Endings and their gates (§14.9); Writs any three of five, in any order, with the two-Writ lift kept as a labelled slice (§2).
- The Barracks Commandant and Marshal Voss are separate people (§3).
- The Cipher: one object, ID `cipher`, "Governor's Maintenance Cipher" (§10).
- Five hearing commands (§2, §9); build presets match the six-attribute table (§7); XP once per authored challenge (§2).
- Covenant, Coil, Nail Storm and Choirbreaker match the §8 table, stagger included.
- No jump, crouch or wall-run (§7 L805); Nix speaks only of recorded failures (§2.5–2.6); perception has no dice.
