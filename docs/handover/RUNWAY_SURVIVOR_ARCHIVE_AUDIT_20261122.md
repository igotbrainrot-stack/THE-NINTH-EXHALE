# Surviving Runway assets — archive inventory (2026-11-22)

The owner supplied two archives after deleting the Runway account. They represent **one collection of Runway outputs**. The original archive ZIPs are **not** committed to this repository; the exact source filenames, sizes, SHA-256 digests and basic media metadata are preserved in `art/SURVIVING_RUNWAY_ARCHIVES_20261122_INDEX.json`.

| Archive | ZIP SHA-256 | Files | Images | Audio | 3D models |
|---|---|---:|---:|---:|---:|
| `ninth exhale assets 01.zip` | `e780e31ccec6fbdd9a0741067c750edaba788b76530090b387434acc2cf955ad` | 71 | 54 PNG | 13 MP3 | 4 GLB |
| `ninth exhale assets 02.zip` | `5fe386b19c986a8ccb41c5bacf0bb22d3da60e0e3d2f509d436d4175d7346546` | 54 | 54 PNG | 0 | 0 |
| **Total** | | **125** | **108** | **13** | **4** |

All 125 archive entries were opened and decompressed successfully (ZIP CRC verified during extraction), and all have individual SHA-256 records. **There are no byte-identical files across the two archives or within either archive.** The two ZIPs are parts of the same production collection but *not* identical file sets. This does not establish whether images depict duplicate or near-duplicate art; that requires visual inspection.

## Media format findings

- **PNG images:** 108 total. Dimensions: 82 at 2560×2560, 10 at 1920×2560, 5 at 2560×1920, 8 at 2560×1440 and 3 at 3264×2448. All are 8-bit: 100 RGB and 8 RGBA. Do **not** assume arbitrary PNGs are usable transparent Godot sprite strips; most are opaque full-frame source images.
- **MP3 audio:** 13 originals in archive 01, including music, ambience, voices and the four recovered 2026-11-22 sounds. Only the final four originals are imported in this PR. Preserve the remainder until comparing against existing soundtrack and audio sources; some older Runway assets may already have been translated to separate procedural WAV/OGG fallbacks. Do not mistake fallbacks for Runway originals.
- **GLB 3D meshes:** four weapon meshes, each with one mesh, one material and three texture references. They are high-poly source assets, **not runtime-ready Godot props**:

| GLB | Triangles | Size (MB decimal) |
|---|---:|---:|
| Choirbreaker | 1,487,285 | 53.1 |
| Coil Shotgun | 1,455,526 | 53.9 |
| Covenant Pistol | 1,446,546 | 51.5 |
| Nail Storm | 1,464,250 | 51.7 |

Keep these original meshes in the owner archives until retopology/LOD, material optimization and an explicit runtime asset plan. Do not push ~210 MB of raw GLBs into game paths merely because they are available. They can guide weapon sprite repainting and proportions in the Build 09.3 art corrections brief.

## Next art QA pass

1. Match each existing GitHub production source and runtime texture/sprite to this inventory by SHA-256 (not just descriptive source filename). Import only genuinely absent, approved files; **do not overwrite** existing working assets.
2. Examine the 8 transparent RGBA PNGs for their usefulness as sprites versus flattened RGBA masters; the 100 opaque PNGs need segmentation before sprite use.
3. Prioritize `docs/handover/GPT_WEAPON_ART_CORRECTIONS_093.md`: Coil firing glove, Nail/Choir first-person orientation and correct anchors. Do not generate synthetic pseudo-walk cycles from a single still; the animation handover requires genuine directional poses and foot planting.
4. Prioritize Slag Sifter and Brin for true animated character vertical slices (including Brin's new `flee` state).
5. Preserve the deleted-account context and record generator IDs only where already known. The archived filename alone is **not** a generator task ID.

This audit covers source preservation and file metadata. It is not a visual-signoff or claim of new runtime integration for the other 121 files.
