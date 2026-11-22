# Build 08.7 — Outstanding asset work

1. **Runway media transport blocked:** External NPC vocal, enemy organic/mechanical effects and two ambience clips exist as tasks but cannot be downloaded into this sandbox. All procedural WAV replacements remain active. Export files to local source, checksum them, normalize audio, and test in Godot before switching playback paths.
2. **Runway actor turnarounds:** External repaint tasks are not equivalent to the current 8-direction animated atlases. Select a canonical Runway source, extract aligned frames, pass animation tests at all 8 views, and only then swap actor packs.
3. **HUD provenance:** Current HUD has an approved Runway board A but locally generated pixel assets, not assets derived from the exact Runway board. Consider a genuine Runway-authored second pass when binary export is available. Manifest IDs are not faked.
4. **Legacy assets:** 360 media files are in historical fallback/gallery families, including valid conditional paths. Byte duplicates remain; removing these before a per-actor runtime trace could silently break fallbacks and comparison galleries.
5. **Historical props:** 27 painted prop reference PNGs are still retained because older tests check their presence; actual environment is built from meshes.
6. **Native-resolution readability:** The former legend overlap is corrected, but further HUD legibility testing is recommended under each window scaling and long translation strings.
7. **Audio and performance:** User-supplied Godot environment lacks real ALSA output; no audible mix test was possible. Exit resource-leak warnings remain unresolved.
8. **GitHub:** Repository cleanup draft PR is a skeleton; full Build 08.7 has not been pushed.
