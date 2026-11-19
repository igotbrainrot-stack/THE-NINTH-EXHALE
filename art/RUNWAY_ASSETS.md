# Runway original art — Build 05

Four original draft assets were generated directly in the user's connected Runway workspace on 17 November 2026. **They are not included as source-image files in this ZIP**, because Runway stores the output in the user's authenticated workspace, not in the local Godot project. The project includes standalone hand-built art and runs without the Runway outputs.

| Asset | Runway task ID | Intended use |
|---|---|---|
| Hearth Nine wall material | `7498fe04-af5c-4446-bf84-e3b53db80e22` | Clinic service-panel texture source |
| Sootworks wall material | `6d153692-d530-445b-9f54-2cddf58e9479` | Foundry furnace steel texture source |
| Covenant Pistol | `6110cb57-3364-4727-9925-b7eca422b0df` | Original first-person equipment sprite draft |
| Brin Harker | `d739c913-42c1-4192-86e4-6d8a913f5fc8` | Front-view concept for 8-direction sprite production |

## How to bring the Runway originals into this build

Open Runway's media viewer or Recent Assets, download the four PNGs to your Linux PC, and copy/import them into the extracted Godot project by running:

```bash
python3 art/tools/import_runway_exports.py \
  --hearth /path/to/your/downloaded/hearth.png \
  --sootworks /path/to/your/downloaded/sootworks.png \
  --pistol /path/to/your/downloaded/pistol.png \
  --brin /path/to/your/downloaded/brin.png
```

The importer preserves each original under `art/reference/`, performs a conservative pixel-scale export, and swaps the named runtime textures. It does not change game logic. If any result has poor tiling or matte removal, restore the corresponding texture by re-running `python3 art/tools/generate_fallback_textures.py` (for wall materials) or `python3 art/tools/paint_covenant_sprite.py` (for the pistol).

**Quality gate:** generated character art is a design reference, not a stable walk-cycle sprite sheet. A production sprite requires one consistent baked model/painted master, 8 facing angles, fixed feet and scale, and purposeful multi-frame locomotion. Do not independently generate each frame with drifting anatomy. Confirm visual originality and rights before release.
