# The Ninth Exhale — Build 07.2: Character Finish Pass + Adaptive Music

## Changes to the actual Godot project

### Music and audio
- Added `scripts/adaptive_music_072.gd`, a persistent global adaptive soundtrack controller, loaded after `Game` in `project.godot`.
- **Four actually playable Ogg tracks are included**, composed locally as original sample-free procedural retro-phonk-inspired instrumental loops:
  - `assets/music/hearth_night_intake.ogg` — 90 BPM
  - `assets/music/sootworks_service_debt.ogg` — 102 BPM
  - `assets/music/basilica_submerged_choir.ogg` — 78 BPM
  - `assets/music/pressure_breach_combat.ogg` — 132 BPM
- Music director crossfades in approximately 2.2 seconds using volume interpolation; music switches between district themes and the combat theme.
- Combat can start when a living hostile is within 23m; optional autonomous enemies may trigger as near as 13m. **Non-hostile plot custodians are not treated as active battle threats.**
- When threats clear, battle score holds for 7s before fading back, reducing rapid musical thrashing.
- Music is independent of saved attempt state; no XP/quest/reconstruction effects. Press **F10** to mute/unmute in the title or in-game.
- A separately commissioned batch of **four richer original Runway music tracks is complete in the connected Runway workspace**. These are **NOT** the Ogg files embedded in the ZIP, because the originals' bytes could not be transferred into the build container. `art/RUNWAY_072_MUSIC_TASKS.json` preserves each exact Runway task ID. `art/tools/import_runway_music_072.py` converts downloaded MP3 exports to Godot's Ogg filenames while preserving the original tracks.

### NPCs and enemies
- **22 fresh 8-view Runway character sheets generated and completed in the connected Runway workspace:** five playable NPCs (`sela`, `brin`, `ossa`, `oren`, `clerk`), fifteen named FPS enemies, plus the Rootkin loaner and Bell Wretch hearing opponents. All retain the user's 1–8 view order; 0 remains universal-billboard mode only.
- Original Runway sheets are **NOT** yet embedded in the ZIP. The working Godot project retains its previous 8-angle sprite art, including the previously commissioned Brin sheet, and existing 12-frame enemy atlas animations.
- Added `art/tools/import_runway_eight_views_072.py` to convert locally exported original 2×4 Runway sheets into the game's matching 192×280 NPC views and 768×768 enemy atlases. It maintains a shared scale across all eight angles, removes the magenta matte, preserves the original source and produces 12 deterministic *motion-proxy* frames per direction for enemy atlas compatibility. These proxy motion frames are **not** independently drawn animation cycles.
- Added **40 new four-frame NPC idle strips** to `assets/sprites/npc_idle_072/`; upgraded `directional_npc_sprite.gd` to play a restrained subtle upper-body idle animation while keeping foot anchors stationary. This is procedural idle animation, not eight independently painted walking cycles.
- The ten additional enemy mechanics, boss and quest flags, two-Writ slice and saved run IDs are unchanged.

## Verification
- 132 Python regression checks pass, plus 14 independent source/data checks.
- The music files have valid Ogg Vorbis headers and were inspected with `ffprobe` locally.
- Build needs manual import and engine/F5 testing; Godot was unavailable in this environment.
- All 26 recent new Runway tasks (22 art plus 4 audio) were verified present in the connected workspace.

## Missing production gates
1. Export 22 eight-view sheets from Runway and run the importer.
2. Export four original Runway music tracks and run the audio importer.
3. Manual QA each 2×4 sheet for true directional accuracy and handed details, then regenerate individual bad cells.
4. Build authentic articulated walks, attacks, death poses beyond procedural motion proxies.
5. Human in-Godot test: full intro, 3 districts, 15 enemies, both hearing sprites, music fades, menu/mute controls and frame stability.
