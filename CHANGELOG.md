# Changelog

Full per-build notes, QA and open issues for every build since Build 02 are in `docs/builds/`.

## 09.3 Weapon art fixes, immersive-sim phase 1b: search, witnesses who run, stealth cue (2026-11-22)

Builds on GPT's `feature/weapon-art-092-20261122` (PR #11, 05ac4d0) and includes it.

**Merged to `main`** on the owner's instruction (PRs #5 → #13 in order), so `main` is now the playable 09.3 game.
- CI now also runs on pushes to `main` and on PRs into it.
- GPT's brief for working against `main`: `docs/handover/GPT_HANDOVER_093_MAIN.md`.
- Brin and Ossa play a `flee` animation, when one is painted, while running to report.

**Fixes to the 09.2 weapon delivery** (details for GPT in `docs/handover/GPT_WEAPON_ART_CORRECTIONS_093.md`):
- **Muzzle anchors** are measured on each weapon's idle frame. Covenant still carried the brief's placeholder (404, 214); Nail and Choir were about 75 px off the barrel, so the flash floated in the air. They are now (422, 197), (284, 250) and (288, 208), and Coil is (238, 206).
- **Coil `fire` held back.** All six frames lose the glove. The strip is moved byte-identical to `art/production_sources/weapons_092/held_back_093/` and recorded in the manifest; Coil fires on its idle frames with full code recoil until it's repainted.
- **`tests/godot_weapon_art_092.gd`** counts failures and exits 1 (bare `assert` could pass), and checks that every muzzle anchor touches the weapon.
- **The capture harness** no longer fails to compile in `--script` mode.
- **README** says "not yet playtested" again. The rewording tripped `test_build063` and failed the last three package runs.

**Immersive sim, phase 1b** (plan: Project doc "Immersive sim integration plan", phase 1):
- **SEARCH, then HIGH ALERT.** A hostile patrol that hasn't seen you for 6 s drops out of combat, walks to where it last saw you and searches for 12 s. Afterwards it stays on high alert: sight range ×1.3, noticing ×1.4, a wider sweep. It never drops straight back to calm (Splinter Cell: Blacklist's rule). High alert is saved. Keepers still hold their post.
- **Barks.** Each change of state speaks a fixed line chosen by its cause, with no randomness: "SOMEONE THERE?", "HEARD THAT.", "THAT WAS A WEAPON.", "WHO'S HURT?", "SHOW ME WHERE.", "THERE!", "I SAW THAT.", "LOST THEM. SEARCHING.", "STAYING SHARP.". They are drawn at a constant screen size so they read at 15 m.
- **Witnesses run to report** (bible L1398: knowledge travels only through surviving runners or radios):
  - When no office-holder sees or hears Brin or Ossa being threatened, they run along a real route to the Millwright or the Cantor.
  - **On arrival** they tell the keeper, which writes `witness.093.<who>.reported_to_<keeper>` (channel TOLD, written by a living witness). The keeper then watches for the attacker and turns on them on sight.
  - **Killed on the way**, they deliver nothing and the pending report is dropped (dead NPCs are silent).
  - **With no working keeper**, they hide.
  - The run, the place they reached and the outcome all survive a reload.
- **Threatened witnesses pause their arc.** A threatened Brin or Ossa will not continue their story, or testify at their council, with the person who hurt them. A deterministic apology (Speech 5 or Insight 5) calms them and stops a run in progress; a report already delivered stays delivered. Other Writ routes are unaffected.
- **Walking grid.** `walk_grid_093.gd` is a 0.5 m A* grid sampled from collision once per district (lifted from the playbot), with `path_follower_093.gd` on top, so searching guards and running witnesses go round walls. It stands in for a navmesh until phase 2.
- **HUD stealth cue**, above the vitals: five lamp pips for how visible you are (the same light and movement factors the guards use), and one word for the most alarmed guard within 30 m: UNNOTICED, HIGH ALERT, NOTICED ?, SEARCHING ?!, CLOSING IN ?! or SPOTTED !.

**Tests and CI**
- New `tests/godot_immersive_093.tscn` (36 checks): search and high alert, barks, the grid, delivery, killed on the way, calming, reload, and the HUD cue.
- New `tests/test_build093_immersive.py`: tripwires for no randomness, records only on delivery, and dialogue gates.
- `godot_perception_092` now resets the witness run between its two scenarios.
- The playbot's witness check covers 09.3 reports and requires that the witness was alive when the record was written.
- GPT's regression and full-campaign workflows now also run on `feature/build-093-*` branches, and the regression workflow includes the immersive and witness suites.

**Not in this phase:**
- a room/portal sound graph (an occlusion ray stands in)
- a navmesh
- patrol radios or runners for optional enemies (only Brin and Ossa run)
- Nix's memory of what she witnessed
- the F9 quicksave ruling
- the sprint-speed ruling (bible 6.2 m/s cap versus code 8.5 m/s)
- whether Hearth Nine should be enemy-free; GPT's gap register calls it P0, but the bible gives Hearth Nine "1 safe station" and puts a simple enemy there in milestone G1

## 09.2 GPT HUD art in game, immersive-sim phase 1, animation drop-ins (2026-11-22)

This build sits on top of GPT's branch `feature/hud-091-art-assets-weapon-wip-20261121` (commit 8fc5e6f, the new HUD art in `assets/ui/hud_091/`) and includes its commits. Plan: `docs/research/` and the Project doc "Immersive sim integration plan".

**GPT's HUD art, checked in game.**
- The art loads through the 09.1 override slot with no code change; captures at 640×400 look right.
- Two code fixes it exposed:
  - The docket footer sat on the new bottom border; it now sits at y = 300 and the choice list stops above it.
  - Re-laying-out notice slips crashed on `get_meta("move_tween", null)` (Godot 4.4 treats a null default as no default).
- `tests/godot_hud_override_091` used to write and delete files in the real `assets/ui/hud_091/`, which would have destroyed delivered art (GPT flagged this). It now uses a scratch `user://` folder through the new `GameUI.art_override_dir`, and hashes the real art before and after.

**Immersive sim, phase 1: deterministic perception (no dice; bible L699, POR-20).**
- `scripts/perception_092.gd`:
  - two vision cones (near 3.2 m/80°, main 13 m/50°)
  - a line-of-sight ray
  - analytic light from the room's lamps
  - a motion factor (still, walking, sprinting)
  - awareness rises and decays at fixed rates through suspicious (?), investigating (?!) and hostile (!)
- **Noise is an event with a radius, not a timer.** Walking 2.4 m, sprinting 7.5 m, a dash 8.5 m, a scuffle 6 m, a cry for help 20 m, a pressure burst 20 m, and gunfire 12–26 m depending on the weapon. Walls almost halve how far a noise carries.
- `scripts/sense_092.gd` gives every enemy a sense:
  - **Patrols** look about on a fixed scan, turn to noises, walk to investigate, and give up on blocked leads.
  - **Keepers** (Millwright and the other office-holders) ignore a stranger's presence. Gunfire alone never turns them; seeing or hearing an assault on a witness does.
  - Distance-only waking is gone.
- **The witness-threat response is now witnessed.** Before, hurting Brin or Ossa angered the district guard by fiat. Now the witness cries for help and only an office-holder who saw or heard it responds, recording `witness.092.*.assault_on_*` with the channel. Without one in earshot, the docket says so.
- `F3` shows the perception debug labels.
- Not in this phase: a room/portal sound graph, a navmesh, search behaviour after losing the player, runners or radios, Nix memory of sightings, a HUD "how visible am I" cue, and a ghost policy.

**Animation drop-in slots (art is GPT's job; the game is ready for it).**
- `scripts/sprite_anim_092.gd` loads `assets/sprites/anim_092/<stem>/<stem>.anim.json` plus strips `<stem>_<state>_<facing>.png` for enemies and NPCs.
- Missing facings borrow the nearest painted facing. Missing states keep the old atlas.
- Enemies play idle, walk, rush, alert, windup, attack, hurt and death. NPCs play idle, talk, listen, threatened and hurt.
- Killed Brin or Ossa now leave silent remains playing their death strip (dead NPCs stay silent).
- Weapons: `assets/weapons/anim_092/<weapon>/` with idle, fire, reload (time-fitted to the catalog), dry, draw and intervene. Muzzle-flash and shell anchors come from the manifest, and procedural recoil and the reload dip scale down when frames exist.
- Briefs for GPT:
  - `docs/handover/GPT_WEAPON_ANIMATION_HANDOVER_092.md`
  - `docs/handover/GPT_SPRITE_ANIMATION_HANDOVER_092.md`
- `tools/anim_092.py` slices sheets, checks deliveries (baseline, scale, frame counts, transparency) and writes GIF previews.

**Fix: three objective-marker dead ends**, all found by the playbot looping. The new pacifist policy found the last two; no-kill routes had never been driven end to end.
- **Assembly.** Under Archivist Latch or Marshal Voss the Core never routes to the patient petition, but the Assembly marker pointed at it anyway, where it can only answer NOT RECORDED. It now does so only if the petition was copied.
- **Flood Basilica.** After the hearing, the marker always sent a peaceful player to the public wicket, which only opens once the Cantor has fallen. It now routes to Ossa (meet her, then compare the reel) and then to her lay council, as Sootworks routes through Brin to the workers' council.
- **Ashmarket.** After the buyer coalition, the marker went straight to the Trade registry, which lists only lock isolation, succession or a witnessed threat. It now goes to the Collector's board, where the coalition challenge, force or a fight settle the Writ, until one of those exists.

**Tests**
- New Godot suites:
  - `tests/godot_perception_092.tscn` (25 checks: cones, light, cover, noise, keepers, witnessed assault, no dice)
  - `tests/godot_anim_092.tscn` (14 checks)
- New Python tests:
  - `tests/test_build092_anim_tool.py`
  - `tests/test_build092_assembly_route.py`
- `test_build085_witness_intimidation.py` now asserts the guard is not angered by fiat; `godot_witness_threat_085` exits 1 on failure.
- The playbot takes `BOT_POLICY=combat|pacifist`, logs sense transitions and checks every witness record has a living witness.

## 09.1 cleanup and HUD art hand-off (2026-11-21)

**Smaller project.** The tracked files went from 372 MB to 304 MB. A fresh Godot import cache went from 183 MB to 91 MB.
- Removed 834 files (67.9 MB) that the game never loads. Each one is logged with its SHA-256 and the commit it can be restored from in `art/BUILD_091_REMOVED_SUPERSEDED.json`.
  - **The 06.8, 07.1 and 07.3 enemy sprite generations.** Every actor and facing resolves to 08.8 or 07.4–07.7 art first. The 07.3 turntable sources stay in `art/production_sources/turntable_073`.
  - **The legacy 4-view NPC folder `assets/sprites/directional/`.** `directional8` covers every NPC.
  - **Old review previews:** `art/previews/` and superseded capture sheets.
  - **93 `.import` sidecars under `art/`.**
- `art/.gdignore` keeps the ~200 MB of source sheets out of Godot's import and any export. Nothing in the game loads `art/`.
- The runtime registry now lists 418 media files (was 778).
- **Not touched:** source sheets and runtime art whose SHA-256 is recorded in a provenance manifest. Re-encoding would break those hashes; lossless recompression saved about 0% on runtime sprites anyway.
- The 07.4 fallback set (33 MB) is **kept** until the 08.8 art's Runway task IDs and licence are confirmed.
- **Dead code removed:** the fallback branches to the removed folders in `enemy.gd`, `animated_echoform_068.gd` and `directional_npc_sprite.gd`. The enemy gallery's compare mode now shows the in-game art against the 07.4 fallback.

**HUD art override slot.** Any PNG in `assets/ui/hud_091/` named after a HUD slot replaces that slot, with no code change. It works even before Godot has imported the file. 9-slice margins come from `hud_091_slices.json`.
- Missing or unreadable art falls back to the 08.6 set.
- New optional slots for the 09.0 pieces: `hud_slip`, `hud_stamp_frame`, `hud_keycap`, `hud_tab_active`, `hud_tab_idle`.
- `hud_frame_route` is also new, because the shared steel frame's 14 + 14 px corners fill the whole 28 px compass.
- Handover for the GPT/Runway art session: `docs/handover/GPT_HUD_UI_ART_HANDOVER_091.md`, with annotated slot maps `HUD_091_SLOTS_PLAY.png` and `HUD_091_SLOTS_DOCKET.png`.

**Tests**
- New `tests/test_build091_cleanup.py` replays the runtime sprite lookup for all 19 enemies and guards, both echoforms and all 7 NPCs, across 8 facings. It also checks that no code references a removed folder, that the removal log is complete, and that the 08.8 source hashes are unchanged.
- New `tests/godot_hud_override_091.tscn` drops real PNGs into `hud_091`, checks they're used with their margins and that the rest falls back, then cleans up.
- Six historical tests that only checked the removed folders now check the same guarantees on the 07.4 and `directional8` sets. One retired test compared two removed generations with each other.

## 09.0b HUD compaction and play-tested fixes (2026-11-21)

I drove the real game with a scripted player (`tools/playbot_090/`), then fixed what it ran into. The bot steers with mouse-style turning and WASD, follows the advisory route with A* pathfinding, presses E, picks docket choices with the number keys, fights only what it can see, reloads, and reads the hearing phase. With the fixes below it plays from the title screen to the Liberation ending in about 6 minutes of bot time.

**HUD footprint: 35% → 15% of the 640×400 view**
- Objective: 356×76 → 300×60, with the district name on its own line (the "/ ACTIVE OBJECTIVE" suffix overflowed in the Assembly).
- Route: a one-row compass, 248×28, top right.
- Vitals and weapon: 238×82 → 204×54 each.
  - The bars carry the numbers.
  - Ammo is the largest type on the HUD and turns red at a quarter magazine.
  - "R RELOAD" appears only when it's useful.
- The always-on four-line controls legend is now a two-line reminder that fades after 45 s of play.
- The interaction prompt sits under the crosshair, where the eye already is.
- Unspent level-up points show as "LV 4 · 3 TO SPEND · TAB" until they're spent.

**Notices**
- Slips wrap to show the whole instruction; "FIND THE MANUAL VALVE AT THE NORTH DOOR" used to be cut off.
- Repeats merge into one slip with a count, where "PISTOL EMPTY" used to stack three times.
- Slips hide and pause while a docket is open.
- A slide-in race that could stack two slips on one spot is fixed.

**Route and progression bugs found in play**
- After the third Writ, the Three-Writ route pointed at an empty spot 20 m from the desk. It now points at the desk, (22, −5).
- Sootworks: after Brin's investigation, the route kept pointing at Brin, whose docket only offers "Close". It now leads to the workers' council, both before and after the strike vote.
- The rail menu marks offices already held ("· WRIT HELD") and lists open ones first.
- The quorum result docket was titled "TRADE OFFICE / RECORDED"; it now reads "THREE-WRIT QUORUM / VERIFIED".
- The quorum desk sign said "LABOUR + FAITH + TRADE"; it now says "ANY THREE WRITS".

**Prompts:** all 122 interactables in nine districts now have written verb-and-noun prompts that fit the prompt tab. Before:
- 16 showed raw ids, for example "[E] ASSEMBLY VOTE CHOIR 078" and "[E] HEARTH SWITCH 079".
- About 70 more were id-derived, for example "[E] FUTURE GATE" for the founding service rails.
- One dialogue line mentioned "Build 04".
- Empty presses now say "NOTHING TO OPERATE HERE" or "NOTHING IN REACH / MOVE CLOSER".

**Rootkin hearing:** the docket leads with the live field state and highlights the opponent's phase. With five commands listed, the phase line used to fall below the visible text. Long docket titles now shrink to fit instead of trimming.

**Title screen:** the description wraps inside the frame; it used to run off the panel and under ENTER HEARTH NINE. There is one primary action, and the four art galleries sit in a quiet row.

**Tests**
- New `tests/godot_prompts_090.tscn` builds every district and checks four things: no raw-id prompts, every prompt fits the tab, every route target in `_nav_target()` is within 2.5 m of something usable, and each is read straight from `main.gd`.
- `godot_hud_090` now has 54 checks.
- The codefix objective check no longer races the HUD refresh.

Captures: `docs/builds/BUILD_090_HUD_COMPACT_BEFORE_AFTER.png`.

**Still needs hands:** the bot reads instantly and never explores. Its 6-minute critical path says nothing about how long a person takes; that needs real playtests. The FPS figures from these runs come from software rendering (llvmpipe) and are not meaningful.

## 09.0 HUD and UI polish (2026-11-21)

Procedural HUD and docket improvements in Godot; no new image or audio assets. The bible palette is used throughout, with stamp vermilion (#A94D3B) reserved for the one signature moment.

**Civic stamp.** Recorded milestones are stamped on screen with a short slam and a low metal thud, one at a time and never twice: Writ recorded (with the quorum count), hearing passed, Lung installed, level up, perk recorded and Custodian defeated. The milestones are detected from saved state, so every route that grants them is covered.

**Notices.** `notify()` now files stacked paper slips under the route panel, newest on top and at most three, instead of one banner that each new message overwrote. The API is unchanged. Evidence pickups add a "docket (TAB)" slip.

**Combat feedback**
- Hits draw a small cream tick around the reticle, and kills a heavier vermilion cross; the "TARGET / CONFIRMED IMPACT" banner spam is gone. `player.gd` emits `hit_confirmed_090(killed)`.
- Damage pushes a red pressure edge in from the screen border.
- Below 30% health the edge stays and pulses.
- The vignette is hidden while a docket is open.
- Health and Breath bars show a pale trail for the amount just lost, which drains to the new value.

**Interaction prompt.** "[E] SPEAK TO BRIN HARKER" now renders as an E keycap followed by the action text.

**Dockets**
- Every choice has a number keycap; keys 1–9 pick it, and disabled choices ignore their key. Button text is unchanged, so check sums still read `[Tech 1 / 5] …`.
- The Civic Pressure Docket is split into four tabs: Goals (prerequisites and Office Trust), The Ninth (attributes, resources, plan), Records (relationships, Writs, hearing, discoveries) and Endgame (lift, core, assembly, rail). Switch with a click, ←/→ or Q/E. `dossier_text()` still returns the whole record.
- Dockets fade in, the footer lists the shortcuts, and long titles trim instead of overflowing.

**Code:** new `scripts/hud_fx_090.gd`, plus changes to `game_ui.gd`, `main.gd` and `player.gd`. Tested by the new `tests/godot_hud_090.tscn` (46 checks). All earlier suites still pass: Python 277, codefix 36, RPG 33, art 39, plus smoke, witness, HUD 086 and asset 087.

**Not yet playtested by hand.** The timing of the stamp (about 2 s on screen) and the slip lifetimes are first guesses.

## 08.9 readable choices and RPG fixes (2026-11-20)

Bible-conformance fixes for checks, progression, trust, the True Dawn lockout and the hearing. No art changes.

**Checks (bible 7.1)**
- A single `check_attribute()` shows the exact sum on every gated option, for example `[Speech 5 + buyers' contracts 2 = 7 / 7]`, `[Tech 1 / 5]` or `[Speech 6; public allocation record required]`.
- Options you can't take yet stay visible but greyed out; previously they were clickable, or hidden in the Force 6 case.
- The Ashmarket coalition now counts its documented evidence (+2), so Speech 5 qualifies, matching the bible's worked example.

**Progression (bible 7.2)**
- 165 XP is paid for only three unique Writs (495 max).
- Advancement XP stops at 1,050, and any excess becomes run score.
- Level-ups show a notice.
- Perks are chosen at levels 2, 4 and 6, and level 7 offers +1 attribute or a fourth perk.
- Six of the bible's 18 perks have working effects and are offered: F3 Anchor Hands, R2 Edge Runner, R3 Narrow Escape, S1 Common Ground, T2 Careful Isolation and V1 Count Breath. The rest need systems that don't exist yet (recoil, breaching, mods, dissonance).

**Office Trust:** actions now adjust trust within −3 to +3. Previously the last action overwrote earlier history; for example, Venn's decision replaced the Growth trust earned from the Writ route.

**True Dawn lockout**
- The docket has a "Known final prerequisites" section: Writs, hearing, the three dawn items, all six constituencies (verified, open or closed with a reason), rail cohort and Energy/Labour reserve, plus Office Trust and perks.
- Before any action that would leave fewer than the 3 constituencies the mandate needs, Ninth gets a confirmation explaining that True Dawn becomes impossible. Previously the lockout was silent.

**Hearing balance**
- Press displaces 13 integrity in the exposed phase but only 1 otherwise.
- Attune displaces 6 in the rising phase and 5 otherwise, and repeating it tires the participant (+2 strain).
- These values come from an exhaustive simulation. Repeating any single command fails on every seed, a phase-aware player passes every time with strain to spare, and the best lines use all four commands. Previously, repeating Attune always won.
- The command hints say which phase each command suits.

**UI:** long modal options wrap instead of widening the column, greyed-out options are readable, and the modal subtitle fits its frame.

**Tests:** `tests/godot_rpg_089.tscn` adds 33 runtime checks. Four source-text pins were updated to the new code form of the same rules.

## 08.8 art wiring (2026-11-20)

New Runway turnaround art from the owner's ART_ASSETS_1/2 ZIPs is now what the game renders, built with `tools/import_art_088.py`.
- **5 NPCs:** Sela, Ossa, the clerk, Oren and Brin get 8-angle stills plus breathing idle strips made from the same art.
- **17 enemies and hearing Echoforms:** slag sifter, rootkin, choir reed, registry bailiff, chain hauler, saltbound porter, vent whistler, sluice beadle, rivet courier, bell wretch, triage warden, sentry (intake crawler), cantor, enforcer, millwright, edda machine and pressure mite.
- **Animation:** each enemy angle gets 12 frames (walk, alert, attack, hurt, death), built as rigid transforms of the new still. This is the same approach as the 07.x procedural atlases.
- **Scale and sources:** sizes match the replaced sprites, so in-game scale is unchanged. The "STRICT 8-WAY" set is used where it exists.
- **Loaders:** the new art loads first, and the old sprites remain as fallbacks. Kest, Venn, commandant, gardener, collector and core actuator have no new art and are unchanged.
- **Provenance:** recorded in `art/BUILD_088_ART_IMPORT_MANIFEST.json`, with source sheets in `art/production_sources/art_088/` (byte-identical). `runway_task_id` stays null until a verified task-ID list arrives, and licence review is pending. Brin's redesign and the sentry slot are flagged for confirmation.
- **Tests:**
  - `tests/godot_art_088.tscn` loads all 8 districts plus the intake alarm and checks every actor renders the expected art (39 checks).
  - `tests/test_build088_art_import.py` checks hashes, formats, fallbacks and that no task IDs are invented.

## 08.7 integration (2026-11-20)

Build 08.7 "Asset Integration" imported from the verified ZIP (SHA-256 `375bbd75…a15c`, 2,150 files) as its exact delta over 08.5, then the 08.5 code-fix pass (PR #3) ported on top. 08.7's own changes are listed in `docs/BUILD_087_CHANGELOG.md`.

**Porting PR #3.** 24 of 25 files merged without conflict. `scripts/game_ui.gd` conflicted in 11 places, because 08.7 shifted every panel title right to make room for its icons. It was resolved by taking 08.7's file and re-applying each fix:
- The sizing-order fix (sizes set after `add_child`).
- Route panel widened, with an ellipsis, so the distance always fits.
- Two-line objective.
- LEVEL/XP width.
- Staged-roster and Sootworks-objective text.
- The stamp now reads 08.7.

08.7's own four-line controls legend was kept instead of PR #3's two-line version.

**New fixes found in 08.7's HUD**
- Icons rendered at their 24 px source size over the panel titles (VITALS, EQUIPMENT, BREATH, objective, route). The size is now set after the expand mode and after the icon enters the tree.
- The second objective line sat on the brass frame border. The objective panel is 6 px taller and the zone label narrower.
- `art/BUILD_087_ASSET_USAGE.csv` imports as "keep" instead of generating four translation files.
- `Music.request_quit()` silences audio twice, a frame apart, so quitting right after music starts doesn't leak. 08.7's HUD and asset test scenes now quit through it.

**Tests.** The regression scene now also checks that HUD icons don't overlap text, and that text stays inside each panel frame (36 checks).

## 08.5 code-fix pass (2026-11-19)

Code-only bug fixes from the research audit (`research/Fixing Ninth Exhale RPG mechanics.md` in the project docs). No art, design or balance changes. Verified with Godot 4.4.1.

**HUD at 640x400**
- Root cause of all overlaps: Label/ProgressBar sizes were set before font/style overrides applied, so every label was 23 px and every bar 27 px tall. Sizes are now assigned after `add_child()`.
- Health and Breath bars no longer overlap; AMPOULES, LEVEL/XP and "2–5 SWITCH" are readable.
- Controls legend moved into the gap between the lower panels (two lines) instead of across both panels.
- Route label: panel widened into free space, smaller font, ellipsis instead of running off-screen; the longest label plus distance fits.
- Objective shows up to two full lines.
- Build stamps on the title and HUD read 08.5 (were 07.8).
- Docket "STAGED ROSTERS" no longer lists released cohorts.
- Sootworks objective after the Labour Writ is the run-wide objective (was the stale "Return to Flood Basilica").
- Travel denial text no longer claims only four districts exist.

**Exit leak ("16 resources still in use at exit")**
- Cause: audio players still playing at quit. New `Music.request_quit()` stops and releases every AudioStreamPlayer, clears combat VFX caches, waits briefly, then quits. Menu quit, title quit and window close all use it.
- Music layers now play only while audible (previously all nine Ogg layers decoded constantly at -72 dB).

**Rendering**
- World-material metallic capped at 0.2: with no sky or reflection probe, higher values rendered near-black on the Compatibility renderer.
- Lighter tint for the "dark" console material; the reprint relay console has a lit face on its approach side too.

**Combat**
- Tracers and impact shards share meshes/materials (a Coil Shotgun blast went from 308 to 113 allocated objects).
- Weapon and action sounds use a fixed 8-voice pool instead of a new AudioStreamPlayer per shot (also removes a latent orphan when a sound failed to load).
- No more "Target and up vectors are colinear" warning for vertical tracers or aim lanes.

**State and saves**
- Returning to a district faces back into it (turned from the gate Ninth left by) instead of a hard-coded world -Z, which could face a wall. First arrivals keep the authored facing.
- Deaths in Glass Orchard, Quiet Barracks, the Central Archives, the Public Assembly and the Freight Lift are recorded with their real site (were "Vesper").
- After a witnessed death and an app restart, the main menu offers RECONSTRUCT, keeping Nix's witnessed record (previously only NEW was offered and Nix forgot). Choosing NEW still starts a fresh chain.
- F9 can no longer refill HP, ammo or ampoules: it commits the live state before loading, and is refused while hostiles are engaged (bible: the checkpoint cannot be manually rewound).
- Raising Force or Resolve raises current HP/Breath along with the cap.

**Tests**
- New `tests/godot_codefix_regressions.tscn`: 32 runtime checks covering all of the above, exits with code 1 on failure. All of them fail against the previous code.
- The two existing Godot test scenes now quit through `Music.request_quit()`.

**Considered and left out:** requiring the district guard to see or hear a threatened witness (bible rule) would switch off most of the 08.5 intimidation response in practice, so it is a design decision for later, not a bug fix.

## 08.5 — Witness Response (2026-11-19)

Base: Build 08.4 Godot Runtime Fix.

- Brin and Ossa become persistently "threatened" when directly attacked below 60% HP (27 of 45). The intimidation is recorded once as evidence and alerts the district's living guard.
- Threatened NPCs show a fearful movement cadence, colour and wounded-witness signage, and keep their foot anchoring.
- New Godot headless regression test (`tests/godot_witness_threat_085.tscn`) plus Python regression tests.
- Writs, hearings, endings, energy accounting and existing saves unchanged.

Details: `docs/builds/BUILD_085_CHANGELOG.md`, `BUILD_085_QA.md`, `BUILD_085_OPEN_ISSUES.md`.

### Repository reorganisation (same date)

- The full Godot project is now on `main`, replacing the earlier notes-only repository.
- Build notes from the project root and `docs/` moved to `docs/builds/`. `docs/` is ignored by the Godot importer.
- `ART_ANIMATION_COVERAGE.csv` moved to `docs/`. Godot had been importing it as a translation file and generating five `.translation` files.
- Removed `publish_to_github.sh` (obsolete), Python caches and generated `.translation` files.
- Project display name set to "The Ninth Exhale" (was "Build 08.1 Architectural Fidelity").
- README rewritten to match the verified state.
