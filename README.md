# THE NINTH EXHALE

Original retro-style first-person RPG / roguelite set in Vesper, developed in Godot 4.

## Current development status

**Source build:** 06.3 graphics integration (Hearth Nine, Sootworks, Flood Basilica). The source build is being staged for publication; this repository is **not yet a verified playable release**. The last user-confirmed working build was 03. An engine runtime test is still required for later builds.

## Artwork

Original art is authored specifically for this project. The most recent graphics package includes:
- Five 512×512 environment materials from generated originals: ward enamel, ward floor, Sootworks panel, Sootworks floor, Basilica stone.
- Four-direction character sprites: Sela Vale, Brin Harker, Sister Ossa, Oren and the municipal clerk.
- Three visual identities for encounter hostiles: office enforcer, Millwright and Cantor.
- Twenty-seven standee environmental fixtures placed across the three areas.
- A reworked first-person Covenant Pistol.
- Original high-resolution creation sources and manifest for reproducible import.
- Separately generated original Runway artworks with their task IDs in the project's Runway asset manifest (the Runway-hosted assets are **not** automatically present in this repository).

The creation-source PNGs and playable Godot project will be considered **uploaded** only after GitHub's tree lists those actual files. This README makes no claim that external artwork is already checked in.

## Release discipline

- `main`: reproducible, verified baseline only.
- Feature branches for engine systems, artwork, quests and content.
- Do not commit Unity/Unreal/DOOM/Fallout/Pokémon/BioShock assets, or unrelated artwork.
- Preserve the two-channel Lumen Engine, three distinct Writs for full-game progression, and ethical Echoform hearing.
- Generated source and runtime exports belong under `art/production_sources/` and `assets/` respectively.
- The artwork is newly generated for this project and still requires a human visual/IP review.

## Start locally

After the Godot project source is committed, import `project.godot` using Godot 4.x and use F5 to test. Source-level test checks do not substitute for engine runtime testing.
