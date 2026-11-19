# The Ninth Exhale — Build 05 / Visual-first environment pass

**Based on:** confirmed-running user Build 03, preserving Build 04 Sootworks source, quests and attempt state.

## Shipped engine assets

- Repainted runtime Covenant Pistol sprite at 256×144 with independent matte-grey industrial silhouette, directional pixels and fixed witness counter. Retains the Build 04 weapon code/damage.
- Replaced five 64×64 near-flat texture placeholders with detailed original 256×256 work materials: enamel/iron panel relief, canvas repair cloth, service-paper dockets and riveted floor plating.
- Added three new 256×256 textures for dedicated clinic wall panels, furnace facing and hazard striping.
- Added `art_detail.gd`, a decorative non-colliding geometry layer around the existing authored spaces.
- Hearth Nine: service ceiling/ribs, recessed lamps, structural wall mullions, oxygen manifolds, glass inspection ports, padded cots, bed labels, louvres, pressure return pipes and public-service filing details.
- Sootworks: furnace surrounds, glow panels, return pipes, office divider surfaces, metal locker facings, conduit runs, guarded floor lines and readable municipal signs.
- Existing collision bodies, player capsule radius, quest consoles, NPC actor positions and main item/evidence IDs are unchanged.
- Added optional offline importer for four Runway original drafts created in the user's connected account. Source downloads remain in Runway until the user exports them; they are not falsely represented as game-ready 8-angle sprites in this ZIP.

## What is NOT yet finished

This is a visual engineering pass, not full AAA or polished sprite art. Complex wall decals, proper baked lighting, object-specific 3D models, distinct 8-angle actors with full walk cycles, animation for each weapon, original sound library, sprite baseline QA and collision-accurate navmesh validation are future work.

## Verification

Use `python3 -m unittest discover -s tests -p 'test_*.py' -v`, and `python3 tests/validate_project.py`. These are documentation/source consistency checks only.

A Godot binary was not available here. **This art pass has not been imported or played in a live Godot runtime.** User must open `project.godot`, F5, inspect Hearth Nine and Sootworks, and report any import warnings. Preserve Build 04 until Build 05 is confirmed on device.
