# The Ninth Exhale — Graphics Production Pass 06.2

**Status:** Godot source build with three locally integrated 4-direction higher-resolution character sprites; 21 independently generated Runway art concepts are in the connected Runway workspace and are not embedded as image binaries in this ZIP. No live Godot engine rendering test has been executed.

## What has changed in the playable source

- **Sela, Brin, and Ossa** use clean-alpha 192×280 four-angle sprites, replacing tiny low-detail procedural portraits. Viewer-side orientation automatically changes front/right/back/left as the camera moves around the NPC. Their character collisions and quest state are unaffected.
- **Oren and clerks** now support the same directional sprite runtime after their newly generated Runway image sheets are exported and imported. Until then they continue to show their earlier fallback art.
- The three world areas have **separate material slots** for additional high-fidelity textures: clinic enamel/floor/ceiling, Sootworks steel/furnace/floor, Basilica stone/floor. Existing tile files remain functional fallbacks.
- The previous art and scenes, Cinder Lung/Labour/Faith Writs, hearing logic and saves are retained unchanged as much as possible.
- The user's Runway workspace contains a first production batch of **8 world tiles, 5 NPC sprite sheets, 4 weapon sprites, the Cinder Lung, 2 armour designs, and Ninth's four-angle player sheet**. Their task IDs and export labels are in `art/RUNWAY_BATCH_MANIFEST.json`.

### IMPORTANT: Runway originals vs embedded images

**The embedded Sela/Brin/Ossa sprites are the earlier in-chat four-angle paintings, cropped into runtime views. The new Runway-generated art is held in Runway's connected workspace, not automatically available as image files in the project container.** This distinction matters: don't mistake the concept-production task for a completed remote PNG import.

## Bringing the new Runway images into the game

1. In Runway, find each image using `art/RUNWAY_BATCH_MANIFEST.json` task ID under Recent Assets.
2. Download the PNG. Rename the file to its manifest label (e.g., `ward_enamel.png`, `sela.png`, `ninth_turnaround.png`). Put all selected images in one folder.
3. In the project folder, run:

```bash
python3 -m pip install Pillow numpy
python3 art/tools/import_runway_batch.py --source /home/YOU/Downloads/ninth_exhale_runway
```

The importer accepts a **partial batch**: it imports only files present, reports which are missing, corrects tile edge seams, exports wall tiles at 128×128, extracts NPC turnarounds to aligned 192×280 PNGs, prepares inventory weapon sprites, and replaces the Covenant Pistol HUD image if present. Sources stay under `art/runway_source/` for provenance.

4. Close/reopen the Godot project (or reimport edited images) and press **F5**.

**Caution:** A 2×2 generative turnaround sheet is NOT a finished animation. Frame-to-frame player walk cycles and eight directional true bake are separate later work. Any Runway image can contain errors; verify hands, dimensions, outfit consistency, leg shape, and correct hemisphere side views before accepting.

## Launcher

Use Godot 4 to import `project.godot` and F5. Existing `launch_linux.sh` remains available on Linux. The user previously verified Build 03; **Build 06.2 has not been runtime tested**.

## What this graphics pass does not fix yet

- The limited Hearth Nine architecture/traversal: this build keeps its level collision and quests, but a large *navigable* hub redesign is still needed.
- In-engine player model, equipment animation rig and character customization: source images created in Runway are not yet integrated as gameplay features.
- No independent AI generation of arbitrary walk frames; that would make limbs/height jitter.
