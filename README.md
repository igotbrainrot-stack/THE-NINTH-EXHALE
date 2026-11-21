# THE NINTH EXHALE

Original retro first-person civic-horror RPG / roguelite set in Vesper. Built in **Godot 4.4.1** with the GL Compatibility renderer and a 640×400 internal viewport.

**Current development build: 09.2 — immersive-sim/perception and weapon-art integration.** The 09.2 branch adds deterministic sight/hearing, witnessed-response logic, drop-in first-person weapon animation strips, and a runnable Linux package. It is playable, but **not the finished game or final content release**. The master game bible remains the production target; the current Godot build is still a development slice and has not had human full-campaign playtesting.

## Run

- In the repository with Godot 4.4.x standard (not .NET): `./launch_linux.sh`
- From the packaged Build 09.2 folder: `./RUN_GAME.sh`
- Or open `project.godot` in Godot Project Manager and press F5.

Controls: WASD move · mouse look · LMB fire · R reload · 2–5 switch weapon · E interact · F / right-click intervene · TAB or ESC opens the dossier. Docket number keys 1–9 select choices; ←/→ or Q/E switch dossier tabs.

## 09.2 art drop-in slots

- HUD/UI: `assets/ui/hud_091/` — see `docs/handover/GPT_HUD_UI_ART_HANDOVER_091.md`
- NPC/enemy animation: `assets/sprites/anim_092/` — see `docs/handover/GPT_SPRITE_ANIMATION_HANDOVER_092.md`
- First-person weapon animation: `assets/weapons/anim_092/<weapon>/` — see `docs/handover/GPT_WEAPON_ANIMATION_HANDOVER_092.md`
- Validate strips: `python3 tools/anim_092.py check <folder>`

**Perception:** sight and hearing are deterministic. Light, cover, movement and noise influence detection; office-holders respond only to witnessed assaults. F3 exposes perception debug labels.

## Verified CI checks (Build 09.2)

- **290** Python tests passed
- **14** project validations passed
- Godot animation tests **18/18**
- Perception tests **25/25**
- HUD art override tests **8/8**
- Project import, district scene smoke and weapon-art loader checks passed
- Combat and pacifist full-campaign playbots both reached **VESPER / LIBERATION**, completing Labour, Faith and Trade Writs and passing the living-witness invariant (0 violations)

Automated playbot results are not human QA: the game has **not yet been playtested by humans** and needs full human campaign sign-off.

## Known unfinished work

- **P0 safe-hub issue:** Hearth Nine still spawns an enforcer, crawler, optional hostiles and an environmental hazard in the 09.2 baseline. The combat/tutorial and contested Lung must be relocated to a separate Intake Annex.
- Only Liberation has been fully verified by automated playbots; Dominion, Crown and True Dawn require direct testing.
- Human full-campaign, endings, audio and performance testing have not been signed off.
- Weapon idle strips are small breathing variations from a master frame. Reload, dry, draw and intervene states are still procedural fallbacks; Nail Storm piston/vent animation and Choirbreaker shutter ripple are incomplete.
- Muzzle/shell anchors still need in-game visual review.
- NPC/enemy animation, voice and ambience assets still need completion/integration; procedural fallbacks remain.
- The Tripo H3.1 weapon models are source references only; retopology/LOD is required before runtime use.
- The master game bible describes a broader full game than this playable development slice. Do not call the project complete until the production-gap list, playthrough, human review and release QA are closed.

See `docs/handover/BUILD_092_COMPLETION_GAP_REGISTER.md` for the completion checklist.

## Known unfinished work

- Human-controlled full campaign, endings, audio and performance testing have not been signed off.
- Weapon idle strips are small breathing variations from a master frame. Reload, dry, draw and intervene states are still procedural fallbacks; Nail Storm piston/vent animation and Choirbreaker shutter ripple are incomplete.
- Muzzle/shell anchors still need in-game visual review.
- NPC/enemy animation, voice and ambience assets still need completion/integration; procedural fallbacks remain.
- The Tripo H3.1 weapon models are source references only; retopology/LOD is required before runtime use.
- The master game bible describes a broader full game than this playable development slice. Do not call the project complete until the production-gap list, playthrough, human review and release QA are closed.

## Project layout

`project.godot`, `scenes/`, `scripts/` — Godot project/runtime
`assets/` — runtime textures, sprites, UI, effects, audio and music
`art/` — production sources, generated art, provenance manifests and import tooling
`data/` — enemy roster, IDs and reference catalogue
`tests/` — Python regression tests and Godot runtime test scenes
`tools/` — importers, validators and scripted playbot
`docs/` — game bible, handovers, build notes and QA

Originality rules remain binding: no franchise assets, weapon silhouettes, monsters, characters or story elements are imported. Generated assets require human review; source provenance and hashes are preserved.
