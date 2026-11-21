#!/usr/bin/env python3
"""Build 08.8 art import: 8-way turnaround sheets -> game-ready actor sprites.

Each source sheet is a 4x2 grid on flat magenta, read left-to-right, top row
first, in the game's view order (scripts/sprite_rotations_071.gd):
  1 FRONT, 2 FRONT LEFT, 3 LEFT, 4 BACK LEFT, 5 BACK, 6 BACK RIGHT, 7 RIGHT, 8 FRONT RIGHT

Outputs (sizes match the slots they replace, so in-game scale is unchanged):
  npc    -> assets/sprites/npc_088/<stem>_<view>.png        192x280 still per view
            assets/sprites/npc_idle_088/<stem>_<view>.png   4 x 192x280 breathing strip
  enemy  -> assets/sprites/enemies_088/<key>_<view>.png     768x768 atlas, 12 frames of
            192x256: 0-3 walk, 4-5 alert/windup, 6-7 attack, 8 hurt, 9-11 death
            (the layout enemy.gd and animated_echoform_068.gd already read).

Each figure is scaled to the height of the sprite it replaces (front view, frame 0),
feet on the same baseline. Frames other than the base pose are rigid transforms of
the new still around the feet, like the 08.7 procedural atlases; the source art
itself contains one pose per view.

Provenance is written to art/BUILD_088_ART_IMPORT_MANIFEST.json. Runway task IDs are
not invented: they stay null until a verified file-to-task list is supplied.

Usage: python3 -I tools/import_art_088.py <dir with source sheets> <repo root>
"""
import hashlib, json, math, sys
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage

# key -> (kind, source file name). Prefer the "STRICT 8-WAY" set where it exists.
STRICT = "STRICT 8-WAY TURNAROUND CHARACTER SPRITE SHEET based on _sou.png"
CLOSE = "Based closely on _reference character_s identity_ create one.png"
MATCH = "Match the existing _reference subject faithfully_ Produce on.png"
def nth(base, n): return base if n == 0 else f"{base} ({n}).png"

MAPPING = {
    # enemies / echoforms: STRICT set
    "slag_sifter":      ("enemy", nth(STRICT, 0)),
    "rootkin":          ("enemy", nth(STRICT, 1)),
    "choir_reed":       ("enemy", nth(STRICT, 10)),
    "registry_bailiff": ("enemy", nth(STRICT, 2)),
    "chain_hauler":     ("enemy", nth(STRICT, 3)),
    "saltbound_porter": ("enemy", nth(STRICT, 4)),
    "vent_whistler":    ("enemy", nth(STRICT, 5)),
    "sluice_beadle":    ("enemy", nth(STRICT, 6)),
    "rivet_courier":    ("enemy", nth(STRICT, 7)),
    "bell_wretch":      ("enemy", nth(STRICT, 8)),
    "triage_warden":    ("enemy", nth(STRICT, 9)),
    # enemies with no STRICT sheet: "Based closely" / "Match existing" sets
    "sentry":           ("enemy", nth(CLOSE, 0)),
    "cantor":           ("enemy", nth(CLOSE, 1)),
    "enforcer":         ("enemy", nth(CLOSE, 6)),
    "millwright":       ("enemy", nth(CLOSE, 8)),
    "edda_machine":     ("enemy", nth(CLOSE, 9)),
    "pressure_mite":    ("enemy", nth(MATCH, 4)),
    # named NPCs: "Based closely" set
    "sela":             ("npc", nth(CLOSE, 2)),
    "ossa":             ("npc", nth(CLOSE, 3)),
    "clerk":            ("npc", nth(CLOSE, 4)),
    "oren":             ("npc", nth(CLOSE, 5)),
    "brin":             ("npc", nth(CLOSE, 7)),
}
IDENTITY_NOTES = {
    "brin": "Identified from concept 'Preserve the original identity inspired by _brin_reference'; redesign drops the 08.7 goggles and beard. Confirm.",
    "sentry": "Four-legged air-filter crawler concept; mapped to the 'sentry' slot by role. Confirm.",
}
NPC_CELL, ENEMY_CELL = (192, 280), (192, 256)
NPC_FOOT, ENEMY_FOOT = 275, 253

def sha(p: Path) -> str: return hashlib.sha256(p.read_bytes()).hexdigest()

def key_magenta(img: Image.Image) -> Image.Image:
    """Flat-magenta chroma key with despill. Magenta-ness = min(R,B) - G."""
    img = img.convert("RGB")
    px = img.load(); w, h = img.size
    out = Image.new("RGBA", (w, h)); op = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            m = min(r, b) - g
            balanced = abs(r - b) < 90
            if balanced and m > 150:
                a = 0
            elif balanced and m > 70:
                a = int(255 * (150 - m) / 80)
            else:
                a = 255
            if a and m > 0:  # despill pink fringe
                k = 1.0 if a < 255 else 0.5
                r = int(r - m * k); b = int(b - m * k)
            op[x, y] = (max(r, 0), g, max(b, 0), a)
    return out

def split_views(sheet: Image.Image):
    w, h = sheet.size; cw, ch = w // 4, h // 2
    views = []
    for i in range(8):
        cell = sheet.crop(((i % 4) * cw, (i // 4) * ch, (i % 4 + 1) * cw, (i // 4 + 1) * ch))
        # Keep the main figure only: drop small islands (bits of a neighbouring
        # view that cross the cell boundary, stray key noise).
        arr = np.array(cell)
        labels, n = ndimage.label(arr[..., 3] > 128)
        if n > 1:
            sizes = ndimage.sum(np.ones_like(labels), labels, range(1, n + 1))
            keep = [i + 1 for i, s in enumerate(sizes) if s >= 0.03 * sizes.max()]
            arr[..., 3] = np.where(np.isin(labels, keep), arr[..., 3], 0)
            cell = Image.fromarray(arr)
        box = cell.getchannel("A").point(lambda a: 255 if a > 128 else 0).getbbox()
        if box is None: raise ValueError(f"empty view {i+1}")
        views.append(cell.crop(box))
    return views

def target_height(old_path: Path, cell, default):
    if old_path and old_path.exists():
        im = Image.open(old_path).convert("RGBA").crop((0, 0) + cell)
        box = im.getchannel("A").point(lambda a: 255 if a > 128 else 0).getbbox()
        if box: return box[3] - box[1]
    return default

def place(fig: Image.Image, scale: float, cell, foot) -> Image.Image:
    fw, fh = max(1, round(fig.width * scale)), max(1, round(fig.height * scale))
    small = fig.resize((fw, fh), Image.LANCZOS)
    # Hard alpha edge: the game renders with alpha scissor at 0.26.
    a = small.getchannel("A").point(lambda v: 255 if v >= 110 else 0)
    small.putalpha(a)
    canvas = Image.new("RGBA", cell, (0, 0, 0, 0))
    canvas.alpha_composite(small, ((cell[0] - fw) // 2, foot - fh))
    return canvas

def pose(base: Image.Image, cell, foot, angle=0.0, dx=0, dy=0, sx=1.0, sy=1.0) -> Image.Image:
    """Rigid transform of a placed still around its foot point (bottom centre)."""
    if not (angle or dx or dy or sx != 1.0 or sy != 1.0): return base
    cx, cy = cell[0] / 2, foot
    a = math.radians(angle); ca, sa = math.cos(a), math.sin(a)
    # inverse affine: output (x,y) -> input
    m00, m01 = ca / sx, sa / sx
    m10, m11 = -sa / sy, ca / sy
    tx, ty = cx + dx, cy + dy
    coeffs = (m00, m01, cx - m00 * tx - m01 * ty, m10, m11, cy - m10 * tx - m11 * ty)
    return base.transform(cell, Image.AFFINE, coeffs, resample=Image.NEAREST)

ENEMY_FRAMES = [  # (angle deg, dx, dy, sx, sy)
    (0, 0, 0, 1, 1), (1.5, 0, -3, 1, 1), (0, 0, 0, 1, 1), (-1.5, 0, -3, 1, 1),   # walk
    (0, 0, 0, 1, 1.03), (-4, 0, 0, 1, 1.02),                                   # alert / windup
    (5, 0, 0, 1.04, 1.04), (3, 0, 2, 1.02, 1.02),                              # attack
    (-7, -4, 0, 1, 1),                                                         # hurt
    (8, 0, 0, 1, 0.97), (32, 10, 0, 1, 1), (62, 22, 0, 1, 1),                  # death / fall
]
NPC_IDLE = [1.0, 1.006, 1.012, 1.006]   # breathing: vertical stretch from the feet

def build(src_dir: Path, root: Path):
    sprites = root / "assets/sprites"
    src_out = root / "art/production_sources/art_088"
    src_out.mkdir(parents=True, exist_ok=True)
    (src_out / ".gdignore").write_text("")
    manifest = {"build": "08.8", "tool": "tools/import_art_088.py",
                "source_provider": "Owner-supplied Runway downloads (ART_ASSETS_1.zip / ART_ASSETS_2.zip, 2026-11-20)",
                "runway_task_ids": "pending: not embedded in the files; awaiting verified file-to-task list from the owner's GPT/Runway session",
                "license_review": "pending", "entries": {}}
    for key, (kind, fname) in MAPPING.items():
        src = src_dir / fname
        if not src.exists():
            raise SystemExit(f"missing source for {key}: {fname}")
        views = split_views(key_magenta(Image.open(src)))
        if kind == "npc":
            cell, foot, out_dir = NPC_CELL, NPC_FOOT, sprites / "npc_088"
            old = sprites / f"directional8/{key}_1.png"
        else:
            cell, foot, out_dir = ENEMY_CELL, ENEMY_FOOT, sprites / "enemies_088"
            old = next((sprites / f"{d}/{key}_1.png" for d in ["enemies_074", "enemies_075", "enemies_076", "enemies_077"] if (sprites / f"{d}/{key}_1.png").exists()), None)
        h_target = target_height(old, cell, foot - 6)
        tallest = max(v.height for v in views); widest = max(v.width for v in views)
        scale = min(h_target / tallest, (cell[0] - 6) / widest)
        out_dir.mkdir(parents=True, exist_ok=True)
        outputs = {}
        for view, fig in enumerate(views, start=1):
            base = place(fig, scale, cell, foot)
            if kind == "npc":
                p = out_dir / f"{key}_{view}.png"; base.save(p, optimize=True); outputs[str(p.relative_to(root))] = sha(p)
                strip = Image.new("RGBA", (cell[0] * 4, cell[1]))
                for i, s in enumerate(NPC_IDLE):
                    strip.alpha_composite(pose(base, cell, foot, sy=s), (i * cell[0], 0))
                idle_dir = sprites / "npc_idle_088"; idle_dir.mkdir(parents=True, exist_ok=True)
                q = idle_dir / f"{key}_{view}.png"; strip.save(q, optimize=True); outputs[str(q.relative_to(root))] = sha(q)
            else:
                atlas = Image.new("RGBA", (cell[0] * 4, cell[1] * 3))
                for i, f in enumerate(ENEMY_FRAMES):
                    atlas.alpha_composite(pose(base, cell, foot, *f), ((i % 4) * cell[0], (i // 4) * cell[1]))
                p = out_dir / f"{key}_{view}.png"; atlas.save(p, optimize=True); outputs[str(p.relative_to(root))] = sha(p)
        kept = src_out / f"{key}_source.png"
        kept.write_bytes(src.read_bytes())
        manifest["entries"][key] = {
            "kind": kind, "original_filename": fname, "source_file": str(kept.relative_to(root)),
            "source_sha256": sha(kept), "runway_task_id": None, "license_review": "pending",
            "replaces": str(old.relative_to(root)) if old else None, "target_height_px": h_target,
            "outputs": outputs, "identity_note": IDENTITY_NOTES.get(key, ""),
        }
        print(f"{key:18s} {kind:5s} h={h_target:3d} scale={scale:.3f} views=8")
    (root / "art/BUILD_088_ART_IMPORT_MANIFEST.json").write_text(json.dumps(manifest, indent=1) + "\n")

if __name__ == "__main__":
    build(Path(sys.argv[1]), Path(sys.argv[2]))
