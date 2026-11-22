# GPT handover: HUD and UI art for THE NINTH EXHALE (Build 09.1)

**For:** the GPT/Runway session that makes art for this project.
**From:** Claude (code, systems and integration).
**Branch:** `feature/build-091-cleanup-hud-handover-20261121`.

## 1. The job

Make better art for the in-game HUD and the docket menus, then deliver it so it drops in **without any code changes**.

The current HUD art (`assets/ui/hud_086/`, 23 PNGs) is a stand-in:

- It was made with local OpenAI image generation from a surrogate of Runway style board A (task `c9d38ddd-b52b-49d4-bcbb-7d00d5af135f`). It is **not** exported from Runway tasks.
- Its licence review is pending.
- Since Build 09.0 the HUD is about half its old size, so several pieces are now drawn far smaller than they were painted for.

The game is now code-complete for HUD art overrides. Any PNG placed in `assets/ui/hud_091/` with a slot name below replaces that slot. You can deliver all slots or only some; missing ones fall back to the 08.6 art. Do not edit or overwrite anything in `assets/ui/hud_086/`. Its hashes are pinned by tests as the provenance record of the stand-in set.

Two reference screenshots, at 2× with every slot marked, sit next to this file:

- `HUD_091_SLOTS_PLAY.png`
- `HUD_091_SLOTS_DOCKET.png`

The current textures are shown in `docs/HUD_086_CONTACT_SHEET.png`.

## 2. Provenance rules (non-negotiable)

1. **Record real task IDs only.** Every delivered PNG must name the exact Runway task (or other generator job) that produced its source. Never invent, guess or reuse an ID. If an ID is unknown, write `null` and say why.
2. **Keep raw downloads byte-identical.** Put each original download in `art/production_sources/hud_091/` exactly as downloaded. Record its SHA-256 *before* cropping, scaling or keying.
3. **Hash the shipped PNG too.** Record the SHA-256 of each PNG you put in `assets/ui/hud_091/`.
4. **Licence:** state the tool, account or plan and terms basis per file, or `"pending"`.
5. **No borrowed IP.** Do not copy commercial games' HUDs, digits, palettes or icon sets. The bible specifically excludes DOOM status digits and face portraits, BioShock and Art Deco ornament, and mid-century advertising styling.

Write `art/RUNWAY_HUD_091_MANIFEST.json`:

```json
{
  "project": "THE NINTH EXHALE",
  "set": "HUD_091",
  "source_provider": "Runway (task IDs per element)",
  "license_review": "pending | <terms>",
  "elements": {
    "hud_frame_brass": {
      "asset_file": "assets/ui/hud_091/hud_frame_brass.png",
      "runtime_sha256": "<sha256 of the shipped PNG>",
      "source_file": "art/production_sources/hud_091/<raw download name>",
      "source_sha256": "<sha256 of the raw download>",
      "runway_task_id": "<real id or null>",
      "prompt": "<prompt text used>",
      "pixel_size": {"width": 96, "height": 48},
      "nine_slice_margins": {"left": 10, "top": 9, "right": 10, "bottom": 9},
      "processing": "crop, nearest-neighbour downscale ×0.25, palette to 64 colours"
    }
  }
}
```

## 3. Style brief, from bible section 11 ("Pressure Docket")

- **What it should feel like:** a working municipal-industrial dossier, not a sci-fi visor. Use these civic details:
  - file-card recesses
  - corner-punched records
  - pressure and height marks
  - service-window slots
  - stamped consent fields
- **Materials:** carbon steel, enamel, ceramic pressure plates, pressed paper. Use brass only for fittings and copper only for conductors.
- **Render scale:** the game renders 640×400 and scales up with nearest-neighbour, so art must read **at 1:1 at 640×400**.
  - Lines and strokes must be at least 1 px.
  - Avoid soft gradients across small pieces.
  - Avoid detail finer than 2 px on icons.
- **No baked text or numerals in any texture.** Godot draws every label, number and key legend live.
- **Colours:** at most 256 on screen overall; aim for 16–32 per HUD element. Use the bible's master swatches:

| Role | Hex | HUD use |
|---|---|---|
| Deep black | `#171918` | Panel interiors behind light text; dark text on paper |
| Cold iron | `#424A48` | Steel frames |
| Service grey | `#68706C` | Frame bevels, idle tabs |
| Bone chalk | `#C8C7AE` | Enamel plates, small text tint |
| Stale paper | `#E1D1A6` | Notice slips, buttons, keycaps |
| Copper shadow | `#6F4A36` | Rivets and joints |
| Amber maintenance | `#C28A43` | Brass trim, heat bar, alerts (in-game brass is `#B38A4F`) |
| Oxide teal | `#407D7F` | Breath bar, route/evidence accents |
| Warning vermilion | `#A94D3B` | **Stamp only**, plus health warnings; keep it rare |
| Hospital blue | `#718D9A` | Care and filter cues |

- **Text contrast:** live text colours are fixed in code.
  - Light text (`#E6DCC5`, `#EFE2C7`, brass labels `#BDA77E`) sits on frames, the prompt tab, the route compass and the docket body. Those interiors must stay **dark and flat**, near `#171918` to `#2A312E`, with no texture noise behind text.
  - Dark text (`#171918`) sits on buttons, notice slips and keycaps. Those faces must stay **light and flat**, near `#E1D1A6`.

## 4. How 9-slice works here (read before drawing frames)

Frames, tabs, buttons and the docket use Godot `StyleBoxTexture` 9-slicing:

- The four corners are drawn at **source pixel size, unscaled**.
- The edges stretch along one axis and the centre stretches in both.
- So `top + bottom` margin must be **well under the smallest drawn height**, and `left + right` margin under the smallest drawn width.
- Today's frames have 14 px top and bottom corners. On the 28 px route compass that uses the entire height, which is why it now has its own slot.

Put each new slot's margins in `assets/ui/hud_091/hud_091_slices.json`: `{"slot": [left, top, right, bottom]}`. Margins are in source pixels and only apply to PNGs present in that folder.

## 5. Slot table

In the table, "drawn" means the size on the 640×400 screen. Recommended source size means the PNG to deliver.

### Frames and panels

| Slot | Drawn at | Current source → recommended | Margins now → recommended | Holds | Notes |
|---|---|---|---|---|---|
| `hud_frame_brass` | objective 300×60; weapon 204×54 | 128×80 → **96×48** | 16,14,16,14 → **≤10,9,10,9** | zone and objective text (light); weapon name plus large ammo digits (light) | Brass trim, iron body, dark flat interior. A small file-card notch top-left can frame the 12 px icon. |
| `hud_frame_steel` | vitals 204×54 | 128×80 → **96×48** | 16,14,16,14 → **≤10,9,10,9** | two 108×9 bars, numbers, level line | Cold-iron variant of the brass frame. Keep the pair visually related. |
| `hud_frame_route` *(new, optional)* | route compass 248×28 | none → **96×28** | none → **≤10,6,10,6** | one line "↑ TARGET · 12m" | A thin compass strip. Without it, the compass uses steel. |
| `hud_prompt_tab` | 268×26, under the crosshair | 268×26 → **128×26** | 13,8,13,8 → **≤12,7,12,7** | keycap at left plus light text | The current interior is too saturated green; make it a flatter dark. |
| `hud_docket_modal` | 556×328 | 550×330 → **same, or 280×166 at 2× detail** | 26 → **≤24** | title band (top 40 px), story area, buttons | Industrial dossier board. Leave the top 40 px as a header band for the 20 px title. Interior behind the story stays dark. |
| `hud_banner_alert` | *(hidden since 09.0)* | — | — | — | **Skip.** Notices use slips now. |

### Bars

Fills are stretched horizontally to the current value, with no 9-slice. Design them **horizontally uniform**: no end caps and no left-to-right gradient.

| Slot | Drawn at | Source | Notes |
|---|---|---|---|
| `hud_bar_track` | 108×9 (health, breath), 62×8 (heat) | 96×10, margins 6,3,6,3 | Recessed channel. The margins keep the rounded ends. |
| `hud_bar_fill_health` | inside the track | 96×10 | Warm red-ochre. Godot overlays a pale "damage trail" strip on top. |
| `hud_bar_fill_breath` | inside the track | 96×10 | Oxide teal. |
| `hud_bar_fill_heat` | inside the track | 145×10 | Amber to hot. Only visible with the Nail Storm. |

### Reticle (drawn 1:1, nearest-neighbour, centred)

| Slot | Size | Notes |
|---|---|---|
| `hud_reticle` | 32×32 | Thin and readable over dark and light walls; use a 1 px dark outline. Keep the centre 6×6 open. Godot draws hit ticks at 5–12 px from centre. |
| `hud_reticle_hit` | 32×32 | Shown for 0.12 s on a hit. Same shape, brighter or closed. |

### Icons

The canonical size is 24×24 RGBA, but icons are **drawn at 11–13 px**. They need bold silhouettes (2 px strokes at 24 px) and transparent backgrounds. Make silhouettes, not plaques: the current ones read as little framed tiles.

`icon_health`, `icon_breath`, `icon_ampoule`, `icon_ammo`, `icon_heat`, `icon_writ`, `icon_evidence_tab`, `icon_interact`, `icon_route_arrow`

`icon_interact` only shows when a prompt has no key; most prompts show a keycap instead.

### Docket controls

| Slot | Drawn at | Source → recommended | Margins | Notes |
|---|---|---|---|---|
| `hud_button_normal` | 500×32 (grows taller when text wraps) | 480×36 → **160×32** | 18,12,18,12 → **≤14,10,14,10** | Light paper or enamel face with dark text. **The left 34 px holds a numbered keycap**, so keep that area plain. |
| `hud_button_hover` | same | same | same | Also used for keyboard focus. Must differ clearly from normal: brighter, plus a brass edge. |
| `hud_button_pressed` | same | same | same | The current press is too subtle. Show an inset, 1–2 px down. |
| `hud_tab_active` *(new, optional)* | 86×18 | → **48×18** | e.g. 6,5,6,1 | The selected docket tab: brass with dark text. |
| `hud_tab_idle` *(new, optional)* | 86×18 | → **48×18** | same | Dark with light text. |

### New 09.0 pieces (optional; flat styles are used without them)

| Slot | Drawn at | Recommended source | Margins | Notes |
|---|---|---|---|---|
| `hud_slip` | 224 × 22–46 (wraps up to 3 lines) | **64×22** | e.g. 6,4,6,4 | Filing slip: stale paper, a 4 px brass spine on the left, dark text. Stacks of three sit top-right. |
| `hud_stamp_frame` | 300×74, rotated −4° and scaled in with a slam | **150×37, or 300×74** | e.g. 12,10,12,10 | Rubber-stamp border in **vermilion `#A94D3B` ink** with a rough inked edge and double rule. The **centre must be transparent or a very dark wash**, because Godot draws vermilion title text and cream detail inside. |
| `hud_keycap` | 17×16 (prompt and docket choices) | **17×16** | e.g. 3,2,3,4 | A cream key with a ≥3 px darker bottom lip and **no legend** (Godot prints E, 1, 2 and so on). |

**Not texture-driven; leave these alone:** the red pressure vignette (a shader), hit and kill marker lines, the bar damage trail, and the fade animations.

## 6. Deliverable checklist

- [ ] PNG, RGBA 8-bit, sRGB. Transparent outside the shape. Exact slot filenames, lowercase.
- [ ] No text or numerals baked in.
- [ ] Reads at 1:1 at 640×400. Test by viewing at 100% next to `HUD_091_SLOTS_PLAY.png`.
- [ ] For every 9-sliced slot: `left + right` < smallest drawn width ÷ 2, and `top + bottom` < smallest drawn height ÷ 2.
- [ ] `assets/ui/hud_091/hud_091_slices.json` lists the margins.
- [ ] Raw downloads are byte-identical in `art/production_sources/hud_091/`.
- [ ] `art/RUNWAY_HUD_091_MANIFEST.json` has real task IDs or `null`, both hashes, prompt and processing per element.
- [ ] A contact sheet of every delivered slot: `docs/handover/HUD_091_CONTACT_SHEET.png`.

If you can't push to the repo, send the owner a zip with exactly this layout: `assets/ui/hud_091/…`, `art/production_sources/hud_091/…` and the manifest. Claude will integrate and test it.

## 7. How it plugs in (already built; for reference)

- `scripts/game_ui.gd`:
  - `hud_art_path(slot)` returns `assets/ui/hud_091/<slot>.png` if present, otherwise `assets/ui/hud_086/<slot>.png`.
  - `_hud091_margins(slot)` reads `hud_091_slices.json` for overridden slots.
  - `hud_optional_skin(slot, flat_style)` covers the optional slots (`hud_slip`, `hud_stamp_frame`, `hud_keycap`, `hud_tab_active`, `hud_tab_idle`, `hud_frame_route`).
- **PNGs work even before Godot has imported them.** Raw files are read from disk and cached, so a copy-and-run test works. Opening the project in the editor, or running `godot --headless --import`, imports them properly for export.
- A broken or unreadable override falls back to the 08.6 art. It never blanks the HUD.

## 8. Verifying a delivery (Claude runs this; GPT may too)

```bash
python3 -m unittest discover -s tests -p 'test_*.py'      # 282 tests
godot --headless --path . res://tests/godot_hud_override_091.tscn   # drop-in mechanics
godot --headless --path . res://tests/godot_hud_090.tscn            # HUD layout and behaviour
godot --headless --path . res://tests/godot_codefix_regressions.tscn  # no overlaps, 5 px border inset
tools/playbot_090/run_playbot.sh out/ 120                  # rendered frames of real play
```

After integration, Claude adds a manifest test like the 08.7 one (`tests/test_build087_asset_integrity.py`) that checks every `hud_091` hash.

## 9. Prompt starters (adapt per slot; generate large, then reduce)

- **Frames:** "Flat orthographic UI panel frame for a municipal-industrial civic dossier game, cold iron with brass corner fittings and a small corner-punched file-card notch, rivets, pressure-gauge tick marks along one edge, completely flat dark charcoal interior (#171918) with no texture, crisp hard edges, no text, no letters, no numbers, no logos, isolated on a pure magenta background, front view, even lighting."
- **Slip:** "Single aged paper filing slip, flat front view, pale stale-paper colour (#E1D1A6) with a narrow brass binding spine on the left edge and two punched holes, clean flat writing area, no text, isolated on magenta."
- **Stamp frame:** "Rubber-stamp border impression in vermilion ink (#A94D3B), double rectangular rule, uneven inked edges with small gaps, transparent empty centre, no letters, isolated on white."
- **Keycap:** "Single small cream keyboard key seen straight on, chunky darker bottom lip, flat top, no legend, pixel-art readable at 16 px, isolated on magenta."
- **Icons:** "Bold two-tone pictogram silhouette of [lungs / ampoule vial / ammunition clip / heat flame / sealed writ scroll / evidence tab / pointing arrow], 24×24 pixel art, 2 px strokes, single cream (#E6DCC5) colour with deep-black outline, transparent background, no frame or plaque."

Key out the magenta, then crop. Reduce with nearest-neighbour (or a careful area downscale followed by palette snapping) to the source size in the table. Snap colours to the swatches above.

## 10. Known faults in the current 08.6 art to fix

From `art/RUNWAY_HUD_086_MANIFEST.json`, plus 09.0 play notes:

- Icons read as plaques, not silhouettes, at 12 px.
- The prompt-tab interior is too saturated green.
- The button pressed state is too subtle.
- Frame corners (14 px) are too big for the compacted HUD, and the 28 px compass has no interior left.
- The banner art is unused, so don't replace it.
