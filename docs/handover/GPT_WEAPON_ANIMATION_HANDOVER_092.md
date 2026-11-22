# GPT handover: first-person weapon art and animation (Build 09.2)

**For:** the GPT image session that makes art for THE NINTH EXHALE.
**From:** Claude (code, systems, integration).
**Branch to build on:** `feature/build-092-immersive-sim-p1-20261122` (or newer).

## 1. The job, and where things stand

Paint frame-by-frame first-person animations for the four weapons the game uses today. They must drop into the game **without code changes**.

### What the game does today

| Item | Current state |
|---|---|
| Viewmodel | One static 640×400 PNG per weapon in `assets/weapons/` (`covenant_idle.png`, `coil_idle.png`, `nail_idle.png`, `choir_idle.png`), moved by code: walk sway, a recoil kick, a dip off-screen for reloads, and a drop for weapon switches. |
| Muzzle flash | A shared 4-frame strip, `assets/fx/civic_muzzle_burst_079x.png` (4 × 128×128), drawn over the weapon. Until now it sat at one fixed point for every weapon. |
| Spent shell | A small orange rectangle. |
| Melee "intervene" | Plays the same small shake as an empty trigger pull. |

### What 09.2 adds

Claude has built a loader in `scripts/game_ui.gd` and `scripts/sprite_anim_092.gd`, covered by `tests/godot_anim_092.tscn`:

- Painted frames in `assets/weapons/anim_092/<weapon>/` replace the static picture, per state.
- Any state you don't deliver keeps the old procedural motion, so a partial delivery is safe.
- Muzzle flash and shell positions come from your manifest's anchors, so the flash finally lines up with each barrel.
- PNGs work even before Godot has imported them, so a copy-and-run test works.

### Review of the earlier WIP

`art/production_sources/weapons_concepts/covenant_pistol_8frame_WIP.png` is a sound pose study. It can't be used as runtime art, because:

- the background is white and the frame grid is baked in;
- the framing isn't locked from frame to frame;
- it isn't at viewmodel scale.

Use it as a pose reference only.

## 2. Provenance rules (same as the HUD handover)

1. **Record real job IDs only.** For every shipped strip, give the real generator job ID (OpenAI gen ID or Runway task ID). Never invent one; if unknown, write `null` and say why.
2. **Keep raw downloads byte-identical** in `art/production_sources/weapons_092/<weapon>/`, with their SHA-256.
3. **Write `art/WEAPON_ANIM_092_MANIFEST.json`** with an entry per strip: `asset_file`, `runtime_sha256`, source files and their `source_sha256`, `generator_job_id`, `prompt` (or `null` with `prompt_status`), `processing`, and `license_review`.
4. **No borrowed IP.** The bible's "Forbidden visual shortcut" column below is binding: no DOOM shotgun or chainsaw, no generic minigun crown, no BioShock ornate antique guns.

## 3. Canon for the four weapons in game (bible §11, "Sixteen weapons")

| Weapon (id) | What it looks like | How it moves | Never |
|---|---|---|---|
| **Covenant Pistol** (`covenant`) | Flat-sided short service pistol, squared **witness counter** in front of the grip, pearl-grey **maintenance key**, matte charcoal slide; a narrow white tab advances each shot | Low-offset muzzle; the mechanical counter visibly resets on reload | Revolver cylinder; heroic centred hand pose |
| **Coil Shotgun** (`coil`) | Compressed rectangular shutter-breaching tool, twin parallel conductor bars above an inset ceramic block, gunwale-shaped lower grip, no exposed ribs | Two-part recoil; the ceramic cooling plate flashes | DOOM shotgun proportions or reload frames |
| **Nail Storm** (`nail`) | Asymmetric industrial riveter, feed box on the right, three square service apertures in a stepped profile, hinged recoil cage | Piston visibly travels; spent belt drops into a collection pan | Rotary minigun barrel crown |
| **Choirbreaker** (`choir`) | Boxy acoustic cancellation frame, staggered rectangular waveguide ducts, one heavy fabric-wrapped handle | Waveform shutters sweep left to right on each shot | Organ-pipe shotgun; ornate antique firearm |

**Keep the identity from the current idle art.** `assets/weapons/<id>_idle.png` is what players already know: the same gloved hand (brown leather work glove, rolled cuff) and the same proportions. New frames should read as the same object, animated. Repainting a different gun is not what's wanted.

## 4. The canvas: 640×400, and what covers it

Every frame is a **full 640×400 RGBA canvas**, transparent outside the weapon and hand, drawn for **1:1 viewing at 640×400** (the game scales up with nearest-neighbour).

| Screen region (x, y, w, h) | What is there | Rule for weapon art |
|---|---|---|
| Crosshair centre (320, 200) | Reticle and hit ticks | The barrel should point toward it; keep the 40×40 box around it clear |
| Prompt tab (186, 236, 268, 26) | "E: SPEAK TO…" prompts | Nothing important behind it at rest |
| Weapon panel (428, 340, 204, 54) | Ammo count, weapon name | The bottom-right corner is covered: no key detail below y = 335 for x > 428 |
| Vitals panel (8, 340, 204, 54) | Health, breath | Left hand or two-handed grips must not depend on the bottom-left corner |
| Docket/menus | Weapon hidden while open | No constraint |

**Composition.** The current idle art occupies roughly:

| Weapon | Area (x, y, x2, y2) |
|---|---|
| Covenant | 408, 177 → 624, 400 |
| Coil | 214, 184 → 629, 400 |
| Nail | 195, 197 → 638, 400 |
| Choir | 211, 180 → 640, 400 |

Keep each idle within ±12 px of these. The hand or arm may run off the bottom and right edges, as now.

**Registration is the hardest part.** Every frame of every state for one weapon must share the same camera, lens and lighting, so the object doesn't jump. A frame differs from its neighbour only by intended motion.

Recommended method:
1. Paint one **master idle frame** first.
2. Make every other frame as an **edit of that master**: move, rotate or replace parts with inpainting, rather than generating each frame from scratch.
3. Check alignment by flipping between frames at 1:1.

**Palette and finish:**
- Up to 96 colours per weapon. The game is palette-limited and posterised at 640×400; soft photo-real noise turns to mush.
- Light from the upper left (the HUD frames and the 3D world use this).
- No baked muzzle flash, tracer, smoke cloud, text, numerals or brand marks.
- The Covenant's witness counter may show tick marks, not digits.

## 5. States, frame counts and timing

These are tied to `scripts/weapon_catalog.gd`; the game time-scales reloads to the catalog value.

| State | Loop | Trigger | Covenant | Coil | Nail | Choir |
|---|---|---|---|---|---|---|
| `idle` | yes | default | 4 f @ 4 fps (breathing; ≤3 px drift) | 4 @ 4 | 4 @ 4 | 4 @ 4 (shutters ripple) |
| `fire` | no | each shot | **4 f @ 24 fps** (0.17 s; refire every 0.42 s) | **6 @ 18** (0.33 s; two-part recoil; refire 1.05 s) | **2 @ 24** (0.085 s per nail; loops while held) | **5 @ 20** (0.25 s; shutters sweep L→R; refire 0.44 s) |
| `reload` | no | R, or auto when empty | **12 f** (fits 1.8 s; counter resets, key turns) | **12** (fits 1.6 s; two cells) | **16** (fits 2.5 s; belt box swap, pan dropped) | **14** (fits 2.2 s; cartridge rack) |
| `dry` | no | trigger with no ammo or no heat headroom | 3 f @ 18 | 3 @ 18 | 3 @ 18 (cage rattles) | 3 @ 18 |
| `draw` | no | weapon switch (0.24 s) | 5 f @ 20 (rises from below the frame) | 5 @ 20 | 5 @ 20 | 5 @ 20 |
| `intervene` | no | F / right-click melee (0.88 s cooldown) | 6 f @ 20 (butt-stroke forward and back) | 6 @ 20 | 6 @ 20 | 6 @ 20 |
| `vent` *(optional, Nail)* | no | overheated at 90 heat | — | — | 8 @ 12 (cage opens, steam is painted) | — |

Notes:
- **Fire frame 0** is the moment of discharge. The muzzle flash overlay is drawn by the game for about 0.075 s from that moment.
- **The reload "fit":** the game plays your frames at `frames ÷ catalog_seconds` fps. So 12 frames over 1.8 s plays at 6.7 fps. Give the important poses (magazine out, magazine in, slide or key) clear frames.
- **One-shot states** return to `idle` on their own after the last frame.
- **Total for the four weapons:** about 37–48 frames each (4 + fire + 12–16 + 3 + 5 + 6), around 170 frames. Ship the **Covenant Pistol first** as a vertical slice.

## 6. Files and manifest

```
assets/weapons/anim_092/covenant/
    covenant.anim.json
    covenant_idle.png        # 4 frames  -> 2560x400 strip
    covenant_fire.png        # 4 frames  -> 2560x400
    covenant_reload.png      # 12 frames -> 7680x400
    covenant_dry.png
    covenant_draw.png
    covenant_intervene.png
```

- Each strip is frames side by side, left to right, each exactly **640×400**.
- Strips must be **≤ 16,384 px wide** (25 frames).
- Names are lowercase `<weapon>_<state>.png`.

`covenant.anim.json` (the anchor numbers here are placeholders; measure your own on your idle frame):

```json
{
  "cell": [640, 400],
  "anchors": {
    "muzzle": [404, 214],
    "shell_port": [470, 236]
  },
  "procedural": {"recoil": 0.3, "reload_dip": false},
  "states": {
    "idle":      {"frames": 4,  "fps": 4,  "loop": true},
    "fire":      {"frames": 4,  "fps": 24, "loop": false},
    "reload":    {"frames": 12, "fps": 12, "loop": false},
    "dry":       {"frames": 3,  "fps": 18, "loop": false},
    "draw":      {"frames": 5,  "fps": 20, "loop": false},
    "intervene": {"frames": 6,  "fps": 20, "loop": false}
  }
}
```

**Anchors** are pixel positions in the 640×400 frame, measured on the idle frame:
- `muzzle` is the centre of the barrel mouth; the 124×124 flash is centred there.
- `shell_port` is where the casing leaves. Omit it for weapons without one: Coil and Choir have no ejected casing.

**`procedural`** sets how much of the code-driven motion remains:
- `recoil` (0–1, default 0.35 when you ship `fire`) is the share of the old screen kick still applied on top of your frames.
- `reload_dip: false` (default) stops the code from dipping the weapon off-screen during your painted reload.

Sway while walking always stays.

## 7. Workflow, checks and delivery

1. **Paint at 2× or 3×** (1280×800 or 1920×1200) on a flat **magenta (#FF00FF)** background, with the camera and framing locked. Lay out each state as a row of frames on one sheet.
2. **Reduce** to 640×400 per frame: nearest-neighbour or area downscale, then palette-snap to at most 96 colours. Key out the magenta, then clean the 1 px fringe.
3. **Slice** the sheet into game strips (one command per state row, or `--rows` for several):
   ```bash
   python3 tools/anim_092.py slice covenant_sheet.png --cell 640x400 \
       --out assets/weapons/anim_092/covenant --stem covenant --weapon \
       --rows idle:4,fire:4,dry:3,draw:5,intervene:6 --key-magenta
   ```
4. **Check:**
   - `python3 tools/anim_092.py check assets/weapons/anim_092/covenant`: strip sizes, frame counts against the manifest, RGBA.
   - `python3 tools/anim_092.py preview assets/weapons/anim_092/covenant --out /tmp/prev`: GIFs at real speed plus a contact sheet. **Watch the GIFs.** If anything jumps that shouldn't, fix the registration.
5. **Deliver:**
   - Commit to a new branch `feature/weapon-anim-092-<date>`, based on the 09.2 branch.
   - Include the strips, the `.anim.json`, the raw sources, `art/WEAPON_ANIM_092_MANIFEST.json`, the previews and a contact sheet in `docs/handover/`.
   - Don't edit code or `assets/weapons/*_idle.png`, and don't merge.
   - If you can't push, send the owner a zip with the same layout.

Claude then checks it in the engine:
- `tests/godot_anim_092.tscn` covers the mechanics.
- Real 640×400 captures of each state in play.
- Muzzle and shell anchor alignment.
- The whole playthrough via `tools/playbot_090/run_playbot.sh`.

## 8. Acceptance checklist

- [ ] Every frame is 640×400 RGBA, transparent background, nothing baked (no flash, text or numerals).
- [ ] The idle position is within ±12 px of the current idle, with the same glove and the same weapon identity.
- [ ] No frame-to-frame jitter beyond intended motion (checked in the GIF at 1:1).
- [ ] The barrel points at the crosshair; nothing important sits under the bottom-right weapon panel (x > 428, y > 335).
- [ ] Each weapon's bible "How it moves" beat is visible: the counter tab, two-part recoil, piston and belt pan, the waveform shutters.
- [ ] The `muzzle` anchor is on the barrel mouth in the idle frame (check the in-game capture).
- [ ] `tools/anim_092.py check` passes; the manifest has real job IDs or `null` with a reason.

## 9. Later (not in this pass)

The bible lists twelve more weapons (Saw Lance, Volt Rifle, Bone Mortar, Censer Flamer, Harpoon Injector, Hush Carbine, Cinder Launcher, Widow's Toll, Surgeon's Mercy, Penance Fang, Debt Collector's Smile, Ferryman's Hook), plus weapon mods such as Mercy Brake and Grinder Crown. They aren't in the game yet. Use the same contract when they are.
