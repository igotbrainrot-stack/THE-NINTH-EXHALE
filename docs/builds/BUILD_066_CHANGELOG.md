# Build 06.6 — Fun-first implementation changelog

Baseline: owner-confirmed functional but boring Build 06.5; no rebuild, no canon or stable-quest-ID migration. All changes are additive or targeted replacements of engagement-critical code.

| File | Real change | Why it helps |
|---|---|---|
| `scripts/enemy.gd` | Telegraph mesh, original warning sound, flinch/hit effect, crawler short rush, Millwright slow pressure cycle, Cantor signal response, sightline ray, one-shot environmental stagger | Attacks have readable intent and different counters; not shared constant-fire chasing |
| `scripts/player.gd` | Low-output renewable close-range F/right-click intervention, cooldown; original weapon, hit and reload sound triggering | Mandatory fights remain finishable without ammunition; actions have auditory feedback |
| `scripts/run_state.gd` | Additive `fun_slice` save defaults, deterministic three-variant cover/shortcut plan, QA seed option source, 3-phase Rootkin/Bell Wretch hearing, one-use resonator reading, preserved transcript and unique XP | More run differences and tactical counterplay without invented dialogue results or saved-state rewrite |
| `scripts/main.gd` | Immediate physical intake relay/valve operations, visible moving shutter, new environmental E interactions with finite events, in-world response lights, hearing opponent tint/scale, telegraph warning banners | Less interruptive menu choreography, meaningful physical agency |
| `scripts/world_builder.gd` | Intake one-charge quench vent and saved installation status lamp | Optional decision before Sela; real physical cue of restoration |
| `scripts/sootworks_builder.gd` | Worker shortcut aperture with a saved colliding shutter; finite steam intervention; seeded cover; Brin relief lighting/sign | A distinct flank/cover route and visible workshop consequence |
| `scripts/basilica_builder.gd` | Side-nave aperture with saved colliding shutter; acoustic resonator; seeded cover; Ossa voice independence lamp/sign | Exploration reveals a tactical advantage in the hearing and shifts the physical hall |
| `scripts/lift_builder.gd` | Persistent triage verdict sign | Edda choice leaves a world-visible trial mark, not only a title card |
| `scripts/brin_actor.gd`, `scripts/ossa_actor.gd` | Caption changes after recorded decisions and alive-state guards unchanged | No misleading default occupation caption after their circumstances change |
| `scripts/game_ui.gd` | Short emergency intervention hint | Out-of-ammo fallback discoverable |
| `assets/audio/*.wav` | Eight original deterministic effects: weapon families, metal impact, warning, reload and valve | Feedback with no sampled proprietary audio |
| `art/tools/generate_sfx_066.py` | Source generator for all new sounds | Reproducible art provenance |
| `tests/test_build066_fun.py`, `tests/test_066_navigation_approx.py` | Scenario, hearing model, source and approximate traversal tests; updated 3 outdated literal assertions in older tests | Transparent regression coverage; no pretending static source assertions are playtests |
| `README.md`, `docs/*`, `publish_to_github.sh` | Honest install/QA instructions and safe new feature branch script | Runnable source handoff, clear remaining work |

## Canon and originality invariants

- Cinder Lung remains a known, **contested allocation**, not magical or hidden; competing ward losses unchanged.
- Energy and Correction remain separate; resource ledger and established Writ IDs unchanged.
- Rootkin is voluntary public loaner; no capture, elemental type ring or four-move creature menu.
- Full campaign still needs three Writs; Edda test uses two only for development.
- Once-only events and unique hearing XP retain original IDs; new environmental events use `_066` IDs.
- All generated audio is original to this project. Earlier Runway and local-generation images are retained, not misrepresented as new exports.
