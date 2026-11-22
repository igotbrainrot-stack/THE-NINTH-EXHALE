# GPT: art consolidation after the Build 09.6 review

**For:** the GPT image session. **From:** Claude.
**Branch:** `feature/build-096-consolidation-20261122` (stacked on PR #16).
**Working brief:** `docs/handover/GPT_HANDOVER_096_MAIN.md` (this file is its §4.2 detail). **Review:** `docs/research/CONSOLIDATION_REVIEW_096.md` (also the Claude doc "THE NINTH EXHALE — story, gameplay and art consolidation review (Build 09.6)").

Claude compared every in-game sprite with the bible's silhouette tables (§11.3 characters, §11.4 creatures) and the painted 08.8 cast. The HUD and lighting are fixed in code. The sprites below need new art. The usual rules apply:
- Original work only.
- Real Runway job IDs.
- Source files kept byte-identical in `art/production_sources/`.
- Feet on the baseline.
- At most 48 colours per character, outlined in deep black `#171918`.

Spec and pipeline: `docs/handover/GPT_SPRITE_ANIMATION_HANDOVER_092.md` (192×256 cells, `tools/anim_092.py check`).

## Priority 1: flat placeholders next to the painted cast

These are 07.x block sprites. They look like a different game beside Brin, Oren, Sela and the 08.8 enemies.

| Actor key | Who | Bible / game description | Current file |
|---|---|---|---|
| `kest` | Kest-07 | Tall rectangular service mask with one damaged chin edge; olive ceramic armour, riveted ID layers. Not a space marine (§11.3) | `assets/sprites/directional8/kest_*.png` |
| `venn` | Venn-of-Glass | Slim carrier frame, inward-opening cage held low; glass-worker gloves, **pale padded coat**. Not an anime creature trainer (§11.3). The current file is a painted body with a flat brown apron and a flat cage pasted over it | `assets/sprites/directional8/venn_*.png` |
| `collector` | Trade-office Collector (office-holder, a person) | Bonded security; "avoid the counting shutter" is its attack tell | `assets/sprites/enemies_075/collector_*.png` |
| `core_actuator` | Central Executive Actuator (machine) | Archive core machine, pressure-pulse heavy attack. Engine palette: aged enamel, heat-scored copper, red-brown insulation (§11.2) | `assets/sprites/enemies_076/core_actuator_*.png` |
| `gardener` | Garden Root Actuator (machine) | Glass Orchard root-motor machine, "root motor pulse". Orchard palette: condensation glass, chalk-white trays, green-grey fibre (§11.2) | `assets/sprites/enemies_077/gardener_*.png` |
| `commandant` | Commandant's service frame (worked by the Barracks Commandant) | Heavy armour frame. Barracks palette: olive ceramic, dull pewter, dark blue (§11.2). Not power-armour warlord (§11.3 Voss row applies by analogy) | `assets/sprites/enemies_077/commandant_*.png` |

## Priority 2: creatures that read as something else

| Species | Bible (§11.4) | Problem now |
|---|---|---|
| Rootkin | Rounded shoot-body with wide root braces; anchors to the floor to guard; not an anthropomorphic leafy child | An antlered stick figure that reads as the Grief Stag |
| Bell Wretch | Bell-shaped upper shell, two uneven load-bearing legs; sound comes from the open bell cavity | A round cartoon face with eyes and mouth |

Both are hearing participants, so they also need the bible's "large left/right portrait" views for the hearing (§11.6).

## Priority 3: proportions only

The identity props are already right. Keep the painting and change the body.

| NPC | Bible (§11.3) | Now |
|---|---|---|
| Brin Harker | **Short, broad**; smoked goggles; asymmetric six-finger prosthesis | Goggles and brass prosthesis present; average height and build |
| Sister Ossa | **Long neck** silhouette defined by the detachable voice-box | Copper voice-box present; ordinary neck |

Height ladder: civilian 100%, soldier 110%, heavy reprint 135% (§11.3).

## The Unsaid (approved 22 November 2026)

The owner approved the Unsaid, and one is now in the game with a placeholder sprite. The full art brief is in `docs/handover/GPT_HANDOVER_096_MAIN.md` §4.1.

## HUD icon (optional)

The health icon is a generic heart. The bible's HUD calls for "left pressure bellows with a breathable-air indicator" (§11). A bellows or pressure-gauge pictogram at 24×24 in `assets/ui/hud_091/icon_health.png` would replace it with no code change.

## Not needed

- HUD frames: the 09.1 set is fine. Claude fixed the clipping in code; the frame's file-card tab is now drawn above the panel.
- Lighting: fixed in code.
