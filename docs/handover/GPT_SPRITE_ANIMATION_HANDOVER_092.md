# GPT handover: NPC and enemy sprite animation (Build 09.2)

**For:** the GPT image session that makes art for THE NINTH EXHALE.
**From:** Claude (code, systems, integration).
**Branch to build on:** `feature/build-092-immersive-sim-p1-20261122` (or newer).
**Covers:** idle, walk, alert, attack and weapon, hurt and death for enemies; idle, talk, listen, threatened, hurt and death for NPCs.

## 1. The job, and where things stand

Paint real frame-by-frame animation for the people and creatures of Vesper. Today their animation is faked:

| Who | Current art | What is fake |
|---|---|---|
| **Enemies** | 8 facings × one 768×768 atlas each, a 4×3 grid of 192×256 cells. Cells 0–3 walk, 4–5 alert/windup, 6–7 attack, 8 hurt, 9–11 death. Sets: `enemies_088` (Runway turnarounds), with `enemies_074`–`077` as fallback. | Every cell is the **same still**, tilted and shifted by `tools/import_art_088.py`. There is no real idle (cell 0 doubles as one), no limbs moving, no weapon discharge, and the death is a tilt. |
| **NPCs** (Brin, Ossa, Sela, Oren, the requisition clerk, Venn, Kest) | 8 stills at 192×280 (`npc_088`, or `directional8`) plus a 4-cell "breathing" strip | The breathing is a 1 px vertical stretch. Talking and listening alternate those same cells. There's no threatened pose, and **no death**: the actor vanishes. |

Claude has built a drop-in loader: `scripts/sprite_anim_092.gd`, wired into `enemy.gd` and `directional_npc_sprite.gd`, and covered by `tests/godot_anim_092.tscn`. It works like this:

- **Folder per character.** Put strips in `assets/sprites/anim_092/<stem>/` and that character uses them. There are no code changes, and PNGs work before import.
- **Partial deliveries are safe.** **Any state you don't deliver keeps the old art**, so you can ship idle and walk first.
- **Missing facings borrow the nearest painted facing.** Ties go to the front. So **four or five facings are a valid delivery** for most states (see §4).
- **NPC deaths leave remains.** A dead NPC plays your death strip, then stays as **silent remains** with no voice and no interaction. That's canon: dead NPCs are silent.

## 2. Provenance rules (same as the HUD and weapon handovers)

1. **Record real job IDs only.** Each strip gets its real generator job ID, or `null` with a reason. Never invent one.
2. **Keep raw downloads byte-identical** in `art/production_sources/anim_092/<stem>/`, with their SHA-256.
3. **Write `art/SPRITE_ANIM_092_MANIFEST.json`** with per-strip `asset_file`, `runtime_sha256`, `source_file`, `source_sha256`, `generator_job_id`, `prompt` or `prompt_status`, `processing`, and `license_review`.
4. **Use the 08.8 turnarounds as the identity reference.** They're in `art/production_sources/art_088/` and their provenance is in `art/BUILD_088_ART_IMPORT_MANIFEST.json`. Characters must stay recognisably the same.
5. **No borrowed IP**, and original silhouettes only (bible §11 and `docs/PROTECTED_ORIGINALITY_REGISTER.md`).

## 3. Cells, baseline and facings: the hard rules

| | Enemies | NPCs |
|---|---|---|
| Cell (one frame) | **192 × 256** | **192 × 280** |
| Foot baseline (lowest opaque row) | **y = 253** (current art: 253) | **y = 275** (current art: 274–277) |
| Body height while standing | about 240 px (160 for the short crawler, mites and similar) | 253–264 px |
| Horizontal centre | feet centred on **x = 96** | feet centred on **x = 96** |

- **The baseline never moves** between frames or facings, except within the death fall. The game pins the sprite's feet to the floor; a wandering baseline makes characters float or sink. `tools/anim_092.py check` allows ±2 px.
- **Never rescale the body between frames** (bible §11). Crouches and lunges change the pose, not the scale. The check flags height changes of more than 6% outside attack, windup, hurt, threatened and death.
- **Backgrounds:**
  - Transparent RGBA.
  - No baked ground shadow (the game adds a contact shadow).
  - No baked "!" or "?" (the game draws those).
  - No text.
- **Palette and light:**
  - At most 48 colours per character, outlined in deep black `#171918`.
  - Light from the upper left.
  - It must read at 1:1: a standing enemy is about 150–200 px tall on a 640×400 screen.

**Facings** are 1–8 around the character, in 45° steps. **The character always faces the same way inside the world; the number is where the viewer stands.**

| Facing | Viewer sees | Note |
|---|---|---|
| 1 | Front, looking at the viewer | most important |
| 2 | Front three-quarter, the character's **left** shoulder nearer | |
| 3 | The character's **left** side (profile) | |
| 4 | Back three-quarter, left shoulder nearer | |
| 5 | Back | |
| 6 | Back three-quarter, right shoulder nearer | |
| 7 | The character's **right** side (profile) | |
| 8 | Front three-quarter, right shoulder nearer | |

**Do not mirror** left views to make right views when the design is asymmetric. That covers every Vesper character with a tool, satchel, key, ledger or one-sided armour. The bible forbids flipped asymmetry.

## 4. Which facings each state needs, and why it's cheaper than it looks

09.2 changed how actors behave. A **hostile enemy turns to face the player**, and NPCs mostly face the player when spoken to. So most combat and conversation states are seen from the front. Only patrol and idle states are seen from every side, and those matter for stealth: the player reads where a guard is looking from its sprite.

| State | Must have | Nice to have |
|---|---|---|
| Enemy `idle`, `walk` | **all 8** | — |
| Enemy `alert`, `windup`, `attack`, `hurt` | **1** | 2, 8 |
| Enemy `death` | **1** | 5 |
| Enemy `rush` (rushers only) | **1** | 2, 8 |
| NPC `idle` | **1, 3, 5, 7** | all 8 |
| NPC `threatened` | **1** | 3, 5, 7 |
| NPC `talk`, `listen`, `hurt`, `death` | **1** | 2, 8 |

A full Tier-1 enemy is about 8 × (4 + 6) + 4 + 3 + 3 + 2 + 7 = **99 frames**. A Tier-1 NPC is about 4 × 6 + 6 + 6 + 3 + 2 + 8 = **49 frames**.

## 5. States, frames and timing

### Enemies (`enemy.gd`)

| State | Frames @ fps | Loop | When the game plays it | What to paint |
|---|---|---|---|---|
| `idle` | 4–6 @ 4 | yes | Not hostile and standing (guarding, watching, looking about) | Breathing, a weight shift, a head turn. Machines idle with a moving part (valve, fan, piston) |
| `walk` | 6 @ 8 | yes | Patrolling, investigating a noise, chasing | A full stride cycle with planted feet. Speed in the world is about 1.2–3.5 m/s |
| `rush` | 6 @ 12 | yes | Rushers (crawler, mites, porter) charging | A low, committed lunge cycle |
| `alert` | 3 @ 10 | no | The moment it becomes hostile (also shown as the "!") | A startle and turn to face: the "found you" beat |
| `windup` | 3–4 @ 10, hold last | no | The telegraph before an attack. **The player must read it** | An exaggerated anticipation pose matching the attack type below; the last frame is held until the strike |
| `attack` | 3–4 @ 12 | no | The strike or discharge, then recovery | **The weapon action itself.** Ranged roles show the discharge (no projectile or tracer; the game draws those); melee roles show the hit and follow-through |
| `hurt` | 2 @ 12 | no | Stagger (pressure vents, staggering hits) | A recoil off-balance, feet planted |
| `death` | 6–8 @ 10 | no | Hp 0. The **last frame stays as the corpse** | A collapse to the ground. The final frame lies within the cell, feet end on or near the baseline. Machines: seize, vent, slump; never a gory spray (bible content rules) |

**What the windup and attack show, by role** (from `data/enemy_roster_068.json`):

| Attack type | Who | Windup (telegraph) | Attack |
|---|---|---|---|
| `line` | Requisition Enforcer, Registry Bailiff, Rivet Courier, Collector | Brace and raise the service weapon level with the eye | A straight-line discharge from the weapon mouth, recoil |
| `rush` | Intake Crawler, Pressure Mite, Saltbound Porter | Crouch back, legs coiling | Spring and slam forward |
| `heavy` | Millwright Power Frame, Slag Sifter, Sluice Beadle, Edda Triage Regulator | Lift the heavy tool or arm high, venting | A ground slam or sweeping blow, big follow-through |
| `signal` | Cantor Signal Keeper, Vent Whistler, Choir Reed, Triage Warden | Inhale or resonator opening, chest or horn swelling | An emitted pulse: the body jolts; the game draws the effect |
| `pull` | Chain Hauler | Swing the chain or hook back | Cast forward and haul |

Enemies have **no separate weapon sprite**: the weapon is part of the body painting. Keep it consistent in every frame, held in the same hand in every facing (no mirroring).

### NPCs (`directional_npc_sprite.gd`)

| State | Frames @ fps | Loop | When | What to paint |
|---|---|---|---|---|
| `idle` | 6 @ 4 | yes | Default | A living pose matching their job: Oren checks a seal, Sela reads a chart, the clerk stamps, Brin rubs his tired hands. Subtle, readable motion, not a stretch |
| `talk` | 4 @ 8 | yes | While their line is shown | Mouth or jaw movement plus one hand gesture |
| `listen` | 3 @ 4 | yes | While the player chooses | A nod, a head tilt, a wary glance |
| `threatened` | 4 @ 6 | yes | After being hurt below 60% (Brin, Ossa) | Defensive: arms up, shrinking back. A **civilian, not a fighter**: never draw a weapon (canon: "no magic gun") |
| `hurt` | 2 @ 12 | no | The moment they are hit | A flinch |
| `death` | 6–8 @ 10 | no | Killed. The last frame stays as silent remains | A collapse. Respectful, no gore. The final frame is the body at rest |
| `flee` *(09.3, Brin and Ossa)* | 6 @ 10 | yes | Running to tell their keeper after an unseen threat | A frightened civilian run, all 8 facings (they cross the district). Carry nothing new |

**The NPC roster** (identity from the 08.8 turnarounds and bible §4):

| Stem | Who | Notes for the painter |
|---|---|---|
| `brin` | Brin Harker, labour debtor, Sootworks | Tired union worker; label states: labour debtor, consented crew, resting shift |
| `ossa` | Sister Ossa, Flood Basilica | An autonomous civic witness, not a token |
| `sela` | Dr Sela Vale, Hearth Nine clinic | Practical and medically specific; defensive when confronted |
| `oren` | Oren, Hearth Nine, ex-soldier | Practical; repairs door seals; small physical precautions |
| `clerk` | Requisition clerk | Stamps, registers, counts three times |
| `venn` | Venn-of-Glass, Glass Orchard | Wants an independent Echoform nursery. No 08.8 turnaround: use `directional8` |
| `kest` | Kest-07, Quiet Barracks | Formality collapsing into resentment. No 08.8 turnaround: use `directional8` |

## 6. Files and manifest

```
assets/sprites/anim_092/slag_sifter/
    slag_sifter.anim.json
    slag_sifter_idle_1.png ... slag_sifter_idle_8.png    # 4-6 frames each
    slag_sifter_walk_1.png ... slag_sifter_walk_8.png
    slag_sifter_alert_1.png
    slag_sifter_windup_1.png
    slag_sifter_attack_1.png
    slag_sifter_hurt_1.png
    slag_sifter_death_1.png
assets/sprites/anim_092/brin/
    brin.anim.json
    brin_idle_1.png  brin_idle_3.png  brin_idle_5.png  brin_idle_7.png
    brin_talk_1.png  brin_listen_1.png  brin_threatened_1.png  brin_hurt_1.png  brin_death_1.png
```

- The folder and stem are the actor id: enemies use the roster `id`, NPCs the stems above.
- Each strip is `<stem>_<state>_<facing>.png`: frames left to right, each exactly one cell.
- A strip named with facing `0` is universal (every view). Use it only for perfectly symmetric things.

`slag_sifter.anim.json`:

```json
{
  "cell": [192, 256],
  "states": {
    "idle":   {"frames": 4, "fps": 4,  "loop": true},
    "walk":   {"frames": 6, "fps": 8,  "loop": true},
    "alert":  {"frames": 3, "fps": 10, "loop": false},
    "windup": {"frames": 4, "fps": 10, "loop": false},
    "attack": {"frames": 4, "fps": 12, "loop": false},
    "hurt":   {"frames": 2, "fps": 12, "loop": false},
    "death":  {"frames": 7, "fps": 10, "loop": false}
  }
}
```

NPCs use `"cell": [192, 280]`. An optional `"pixel_size"` overrides the in-world scale; leave it out unless asked.

## 7. Workflow, checks and delivery

1. **Start from the identity.** Take the character's 08.8 view, or `directional8` for Venn and Kest, at the wanted facing as the reference. Paint one **key pose per state** at 2–3× size on flat magenta (#FF00FF), then the in-betweens as **edits of the key** (inpaint limbs, keep the head, costume and tool identical).
2. **Lay out one sheet per facing:** rows are states, columns are frames, each cell exactly 192×256 (or 192×280) after reduction.
3. **Reduce** with a nearest-neighbour or area downscale, snap the palette to ≤48 colours, then **align the feet to the baseline** (y 253 or 275, centred on x 96).
4. **Slice:**
   ```bash
   python3 tools/anim_092.py slice slag_sifter_facing1.png --cell 192x256 \
       --out assets/sprites/anim_092/slag_sifter --stem slag_sifter --facing 1 \
       --rows idle:4,walk:6,alert:3,windup:4,attack:4,hurt:2,death:7 --key-magenta
   ```
5. **Check and preview:**
   ```bash
   python3 tools/anim_092.py check assets/sprites/anim_092/slag_sifter
   python3 tools/anim_092.py preview assets/sprites/anim_092/slag_sifter --out /tmp/prev
   ```
   The check fails on floating feet, rescaled bodies, wrong frame counts, opaque backgrounds and undeclared states. **Watch every GIF.** Foot sliding during walk is the most common fault. The planted foot must stay planted for its frames.
6. **Deliver:**
   - Commit to `feature/sprite-anim-092-<date>`, based on the 09.2 branch.
   - Include the strips, the `.anim.json` files, raw sources, `art/SPRITE_ANIM_092_MANIFEST.json`, previews and a contact sheet per character in `docs/handover/`.
   - No code edits, no changes to the existing `enemies_0xx`, `npc_0xx` or `directional8` art, no merging.
   - If you can't push, send a zip with the same layout.

**Order of work.** Do one complete vertical slice before scaling up:
1. **Slag Sifter**, a Sootworks optional enemy and the first district for immersive-sim work.
2. **Brin** (Sootworks witness).
3. The other Sootworks roster: Rivet Courier, Chain Hauler, Millwright.
4. Then Hearth, Basilica and the rest.

Claude checks each delivery in the engine:
- `tests/godot_anim_092.tscn` for mechanics.
- Captures of every state at 640×400 from facings 1, 3, 5 and 7.
- A full playbot playthrough.

## 8. Acceptance checklist

- [ ] Cells are exactly 192×256 (enemy) or 192×280 (NPC), RGBA, transparent, no shadow, text or markers.
- [ ] Feet sit on y 253 / 275 (±2 px) in every frame and facing except within the death fall; feet are centred on x 96.
- [ ] No body rescaling between frames; walk cycles don't slide.
- [ ] Left and right views are painted, not mirrored, for asymmetric characters.
- [ ] `windup` reads as the telegraph for that role's attack, and the last frame is a clear hold.
- [ ] `death` ends on a resting body that works as a corpse; no gore; NPC deaths are dignified.
- [ ] Threatened civilians never hold a weapon.
- [ ] The identity matches the 08.8 turnaround or `directional8` art.
- [ ] `tools/anim_092.py check` passes, and the manifest is complete with real IDs or `null` with a reason.
