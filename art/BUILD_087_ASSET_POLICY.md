# Asset policy — runtime vs archival

The active game loads resources from `res://assets`. Archival art can remain in `art/` and historical renderer fallbacks may still be runtime-critical. **Do not equate an unreferenced static search result with dead content.**

- **Canonical HUD:** one unsuffixed 24px icon per name; dynamically scaled at runtime. The 18 unused `_16`/`_24` derived files were removed; original high-res PNGs retained under `art/production_sources/hud_086`.
- **Enemy atlases:** current primary folders `enemies_074`, `enemies_075`, `enemies_076`, `enemies_077`. Older `enemies_073`, `enemies_071`, `enemies_068` are fallback/gallery resources; do not delete without running optional actor galleries and testing missing-primary recovery.
- **NPC sprites:** `directional8` and `npc_idle_072` are dynamic primary families; `directional` is a safety fallback.
- **Historical props:** 27 PNGs are archival visual references, but their location/number is asserted by legacy regression tests. Keep until tests and gallery flows are explicitly migrated.
- **External Runway:** `RUNWAY_HUD_086_MANIFEST.json` never calls locally generated files Runway exports. `BUILD_087_EXTERNAL_RUNWAY_QUEUE.json` contains unembedded task IDs. A future import must include real bytes, source hash, checked licence, import paths, and Godot in-engine result.
- **Audio:** existing 14 actor_083 fallback WAVs remain functionally loaded until tested replacements arrive.
- **Duplicate byte groups:** see `BUILD_087_BYTE_IDENTICAL_GROUPS.json`. Hash-equal files can still have distinct paths needed by legacy fallbacks; deduplication must preserve semantics or redirect references first.
