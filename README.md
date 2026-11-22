# THE NINTH EXHALE

Original retro first-person civic-horror RPG / roguelite set in Vesper. Built in **Godot 4.4.1** with the GL Compatibility renderer and a 640×400 internal viewport.

**Current development build on `main`: 09.3, immersive-sim phase 1b on top of the 09.2 weapon art.** Work happens on branches off `main` with draft PRs; CI runs on every PR. GPT's working brief: `docs/handover/GPT_HANDOVER_093_MAIN.md`.
- 09.2 added deterministic sight and hearing, witnessed responses, first-person weapon animation strips and a runnable Linux package.
- 09.3 adds guards that search and stay on high alert, threatened witnesses who run to report, cause-specific barks and a HUD stealth cue. It is playable, but **not the finished game or final content release**. The master game bible remains the production target; the current Godot build is still a development slice and has not had human full-campaign playtesting.

## Run

- In the repository with Godot 4.4.x standard (not .NET): `./launch_linux.sh`
- From a packaged build folder: `./RUN_GAME.sh`
- Or open `project.godot` in Godot Project Manager and press F5.

Controls: WASD move · mouse look · LMB fire · R reload · 2–5 switch weapon · E interact · F / right-click intervene · TAB or ESC opens the dossier. Docket number keys 1–9 select choices; ←/→ or Q/E switch dossier tabs.

## Art drop-in slots

- HUD/UI: `assets/ui/hud_091/` — see `docs/handover/GPT_HUD_UI_ART_HANDOVER_091.md`
- NPC/enemy animation: `assets/sprites/anim_092/` — see `docs/handover/GPT_SPRITE_ANIMATION_HANDOVER_092.md`
- First-person weapon animation: `assets/weapons/anim_092/<weapon>/` — see `docs/handover/GPT_WEAPON_ANIMATION_HANDOVER_092.md`
- Validate strips: `python3 tools/anim_092.py check <folder>`
- Weapon art corrections after 09.2: `docs/handover/GPT_WEAPON_ART_CORRECTIONS_093.md`

**Stealth and witnesses (09.2–09.3):** sight and hearing are deterministic, with no dice.
- Light, cover, movement and noise decide what guards notice. A guard that loses you searches, then stays on high alert.
- Office-holders act only on assaults they saw, heard or were told about by a living witness. Brin and Ossa run to their keeper when nobody else noticed; stop or calm them and nothing is reported.
- The pips above the vitals show how visible you are; the word beside them shows the most alarmed guard nearby.
- F3 shows the perception debug labels.

## Verified checks (Build 09.3)

- **297** Python tests passed
- **14** project validations passed
- Godot animation tests **18/18**
- Perception tests **25/25**
- Immersive-sim tests **36/36**
- Weapon art tests **31/31**, including muzzle anchors on the weapon
- HUD art override tests **8/8**
- Project import, district scene smoke and weapon-art loader checks passed
- Combat and pacifist full-campaign playbots both reached **VESPER / LIBERATION**, completing Labour, Faith and Trade Writs and passing the living-witness invariant (0 violations)

Automated playbot results are not human QA: the game is **not yet playtested by humans** and needs full human campaign sign-off.

## Known unfinished work

- **Hearth Nine safe hub (needs the owner's ruling):** Hearth Nine still spawns an enforcer, a crawler, optional hostiles and a hazard. The 09.2 gap register calls this P0 and proposes moving them to a separate Intake Annex. The bible gives Hearth Nine "1 safe station" and puts a simple enemy there in milestone G1, so the change needs a decision first.
- Only Liberation has been fully verified by automated playbots; Dominion, Crown and True Dawn require direct testing.
- Human full-campaign, endings, audio and performance testing have not been signed off.
- Weapon idle strips are small breathing variations from a master frame. Reload, dry, draw and intervene states are still procedural fallbacks; Nail Storm piston/vent animation and Choirbreaker shutter ripple are incomplete.
- Nail Storm and Choirbreaker art is drawn side-on (barrel pointing left), and the Coil `fire` strip is held back because the hand disappears. Repaints are requested in `docs/handover/GPT_WEAPON_ART_CORRECTIONS_093.md`. Muzzle anchors were checked in game in 09.3.
- NPC/enemy animation, voice and ambience assets still need completion/integration; procedural fallbacks remain.
- The Tripo H3.1 weapon models are source references only; retopology/LOD is required before runtime use.
- The master game bible describes a broader full game than this playable development slice. Do not call the project complete until the production-gap list, playthrough, human review and release QA are closed.

See `docs/handover/BUILD_092_COMPLETION_GAP_REGISTER.md` for the completion checklist.

## Project layout

`project.godot`, `scenes/`, `scripts/` — Godot project/runtime
`assets/` — runtime textures, sprites, UI, effects, audio and music
`art/` — production sources, generated art, provenance manifests and import tooling
`data/` — enemy roster, IDs and reference catalogue
`tests/` — Python regression tests and Godot runtime test scenes
`tools/` — importers, validators and scripted playbot
`docs/` — game bible, handovers, build notes and QA

Originality rules remain binding: no franchise assets, weapon silhouettes, monsters, characters or story elements are imported. Generated assets require human review; source provenance and hashes are preserved.
