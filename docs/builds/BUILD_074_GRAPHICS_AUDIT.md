# THE NINTH EXHALE — BUILD 07.4 / GRAPHICS AUDIT AND CORRECTIONS

## Audit scope and source

Inspected the complete Build 07.3 Godot project source and its active `assets/sprites/directional8/`, `assets/sprites/enemies_073/`, NPC idle strips, 3D prop kit, environment setup, and galleries. This report is **about what the active project actually renders** rather than a claim that remotely generated Runway artwork is already installed.

## Findings and completed corrections

| Finding | Corrective work in Build 07.4 | Verification |
| --- | --- | --- |
| Sela's active `sela_1..8.png` were crude low-poly maquette images despite better original concept art | Imported a genuine eight-angle painted Sela turnaround with all eight views, 192×280 fixed cells, consistent baseline and magenta decontamination | Image diff across 28 view pairs; 8 PNGs load |
| Brin's painted views were already present but needed a consistent import/provenance pipeline | Re-exported genuine painted eight-way Brin views using the same stable anchor and chroma matte processing | 8 PNGs; 28 view pairs |
| Chroma removal in an early processing trial visibly turned skin/cloth green | Corrected matte detection to only key actual magenta-like pixels; protected solid dark cloth/skin; recoloured red cross-like accents into the game's amber service-tab palette | Actual export preview and image source test |
| 07.3 enemy turntables were physically eight-way but flatly shaded, with low texture/readability | Processed all 17 hostile/hearing figures, eight views each, into `enemies_074/` with slight material texture, improved highlight contrast and 1px silhouette edge. Crucially, no front-view duplication or angle warping | 136 valid 768×768 RGBA atlases; existing angles preserved |
| Sprite alpha edges and transparent sorting varied | Configured `SpriteBase3D.alpha_cut` and explicit threshold for NPC, enemy and Echoform sprites | Source regression; Godot 4.4 docs API checked |
| Character/enemy art did not look connected to the ground | Added a non-colliding floor-parallel contact-shadow material and Sprite3D attachment | Source regressed; 128×128 RGBA asset |
| Environments looked uniformly illuminated | Authored four zone-specific low-cost practical lights with subtle flicker per district, color-dependent base ambient, physical lamp meshes and four small worn floor stains per zone | Source checks; additive only |
| Duplicate furniture profiles across placements looked identical | Made each of the 66 real 3D prop instances receive a deterministic subtle color/roughness variation without changing its mesh, collision or dimensions | Source QA |
| Existing 07.3 gallery compared 07.2 to 07.3 only | Gallery now shows actual polished 07.4 assets by default; **T** compares 07.3 | Source QA |
| One PNG was truncated when a batch-render process was interrupted | Detected by full image decode, regenerated the damaged atlas and scanned every new atlas | PNG decode scan and tests |

## Why this is not a finished high-end art pass

The 17 enemy/hearing figures still inherit 07.3 low-poly turntable geometry. The extra texture and edge detail improves them, but it **cannot** match separately painted high-detail source art. Ossa, Oren and the requisition clerk retain correct eight-way 07.3 source views (lower fidelity) until their Runway files are actually transferred and visually validated. `art/RUNWAY_073_REGENERATION.json` lists 22 complete Runway generations, but the remote file bytes are not in this ZIP; do not confuse an index with imported assets.

The existing 12 enemy pose cells are procedural stand-ins, not true rigged walking/attack/death animation. Floor decals and lamp positions have no collision. Player navigation, quest conditions, weapons, save schema, NPC voice state and hearing ethics were not intentionally changed.

## Engineering integration

- **Runtime NPC source:** `assets/sprites/directional8/sela_1..8.png`, `brin_1..8.png`
- **NPC idle source:** `assets/sprites/npc_idle_072/sela_1..8.png`, `brin_1..8.png`
- **Enemy/hearing runtime:** `assets/sprites/enemies_074/<id>_<1..8>.png` (old `enemies_073` preserved as fallback)
- **Character grounding:** `scripts/sprite_grounding_074.gd` and `assets/ui/contact_shadow_074.png`
- **Room presentation:** `scripts/district_mood_074.gd`, `assets/textures/decals_074/`
- **3D furniture finish:** `scripts/prop_mesh_070.gd`, `scripts/art_detail.gd`
- **Reproducible source scripts:** `art/tools/import_painted_civilians_074.py`, `art/tools/polish_enemy_atlases_074.py`
- **Actual sprite comparison:** `art/previews/BUILD_074_ACTUAL_BEFORE_AFTER.png`

## Verification run

- Python regression suite: 146 passing in current environment.
- Project/data source validation: 14 passing.
- All 136 polished enemy atlases and 16 painted NPC direction files were decoded and checked with Pillow.
- Asset preview file rendered directly from the active PNGs.
- ZIP integrity checked before delivery.
- **Godot runtime import/F5, shader correctness, performance, gameplay fairness, audio and human visual review: not executed in this environment.** Source checks do not prove scene quality.

## Recommended subsequent fixes in order

1. Import and manually compare the **actual Runway eight-view paintings** (not just task IDs), starting with the five highest-impact creatures and then the three remaining named civilians.
2. Replace generated animation proxy frames with real leg, weapon and attack animation on a fixed pivot. Motion must align with the same eight poses.
3. Add three-dimensional, collision-aware cover/props only after level route testing. This pass intentionally did not add colliders.
4. Run live Godot Godot 4.4+ F5 and compare screenshots at the exact 640×400 internal resolution (nearest-neighbour presentation), then tune brightness and lamp placement per district.
5. Undertake a full pixel and IP review of all character insignia, including clinic service symbols, before public distribution.
