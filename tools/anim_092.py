#!/usr/bin/env python3
"""Build 09.2 animation delivery helper (enemies, NPCs, weapons).

    python3 tools/anim_092.py slice SHEET.png --cell 192x256 --out DIR --stem brin \
            --rows idle:4,walk:6 --facing 1 [--key-magenta]
        Cut a grid sheet (one row per state, frames left to right) into the
        strips the game loads: DIR/<stem>_<state>_<facing>.png. Use --facing 0
        (or --weapon) for facing-less weapon strips: DIR/<stem>_<state>.png.

    python3 tools/anim_092.py check DIR [DIR ...]
        Validate one or more anim_092 folders against the spec: manifest,
        strip sizes, RGBA, transparent corners, a constant foot baseline and
        body height (characters), colour counts, frames vs manifest.
        Exit code 1 on any error.

    python3 tools/anim_092.py preview DIR --out PREVIEW_DIR [--scale 2]
        Write an animated GIF per state and facing, plus a contact sheet.

Spec: docs/handover/GPT_SPRITE_ANIMATION_HANDOVER_092.md and
docs/handover/GPT_WEAPON_ANIMATION_HANDOVER_092.md
"""
import argparse
import json
import re
import sys
from pathlib import Path

from PIL import Image

CHAR_FOOT_TOLERANCE = 2      # px the lowest opaque row may wander between frames
CHAR_HEIGHT_TOLERANCE = 0.06 # 6% body-height change allowed outside death/hurt
MAX_COLOURS_CHAR = 48
MAX_COLOURS_WEAPON = 96
MAX_STRIP_WIDTH = 16384      # Godot texture limit
STRIP_RE = re.compile(r"^(?P<stem>[a-z0-9_]+?)_(?P<state>[a-z0-9]+)(?:_(?P<facing>[0-8]))?\.png$")


def parse_cell(text):
    w, h = text.lower().split("x")
    return int(w), int(h)


def key_magenta(img):
    img = img.convert("RGBA")
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if r > 200 and b > 200 and g < 80:
                px[x, y] = (0, 0, 0, 0)
    return img


def cmd_slice(args):
    cw, ch = parse_cell(args.cell)
    sheet = Image.open(args.sheet).convert("RGBA")
    if args.key_magenta:
        sheet = key_magenta(sheet)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    for row, spec in enumerate(args.rows.split(",")):
        state, frames = spec.split(":")
        frames = int(frames)
        strip = Image.new("RGBA", (cw * frames, ch), (0, 0, 0, 0))
        for i in range(frames):
            strip.paste(sheet.crop((i * cw, row * ch, (i + 1) * cw, (row + 1) * ch)), (i * cw, 0))
        name = f"{args.stem}_{state}.png" if args.weapon else f"{args.stem}_{state}_{args.facing}.png"
        strip.save(out / name)
        print("wrote", out / name)


def frames_of(strip, cw, ch):
    return [strip.crop((i * cw, 0, (i + 1) * cw, ch)) for i in range(strip.width // cw)]


def check_dir(folder):
    errors, warnings = [], []
    folder = Path(folder)
    stem = folder.name
    manifest_path = folder / f"{stem}.anim.json"
    if not manifest_path.exists():
        return [f"{folder}: missing {manifest_path.name}"], warnings
    try:
        manifest = json.loads(manifest_path.read_text())
    except json.JSONDecodeError as exc:
        return [f"{manifest_path}: invalid JSON ({exc})"], warnings
    cw, ch = manifest.get("cell", [0, 0])
    is_weapon = (cw, ch) == (640, 400)
    states = manifest.get("states", {})
    if not states:
        errors.append(f"{manifest_path}: no states")
    seen_states = set()
    feet, heights = {}, {}
    for png in sorted(folder.glob("*.png")):
        m = STRIP_RE.match(png.name)
        if not m or m.group("stem") != stem:
            warnings.append(f"{png.name}: not named <stem>_<state>[_<facing>].png; ignored by the game")
            continue
        state = m.group("state")
        seen_states.add(state)
        if state not in states:
            errors.append(f"{png.name}: state '{state}' is not declared in the manifest")
            continue
        img = Image.open(png)
        if img.mode != "RGBA":
            errors.append(f"{png.name}: mode {img.mode}, expected RGBA")
            img = img.convert("RGBA")
        if img.height != ch or img.width % cw != 0:
            errors.append(f"{png.name}: {img.width}x{img.height} is not a strip of {cw}x{ch} cells")
            continue
        if img.width > MAX_STRIP_WIDTH:
            errors.append(f"{png.name}: {img.width}px wide exceeds Godot's {MAX_STRIP_WIDTH}px texture limit")
        declared = int(states[state].get("frames", 0))
        count = img.width // cw
        if count != declared:
            errors.append(f"{png.name}: {count} frames, manifest declares {declared}")
        colours = img.getcolors(1 << 16)
        limit = MAX_COLOURS_WEAPON if is_weapon else MAX_COLOURS_CHAR
        if colours is None or len(colours) > limit:
            warnings.append(f"{png.name}: more than {limit} colours; palettise for the 640x400 look")
        for i, frame in enumerate(frames_of(img, cw, ch)):
            alpha = frame.getchannel("A")
            box = alpha.getbbox()
            if box is None:
                errors.append(f"{png.name} frame {i}: empty")
                continue
            corners = [alpha.getpixel(p) for p in ((0, 0), (cw - 1, 0))]
            if not is_weapon and any(corners):
                errors.append(f"{png.name} frame {i}: opaque top corners; the background must be transparent")
            if is_weapon:
                continue
            feet.setdefault(state, []).append(box[3])
            heights.setdefault(state, []).append(box[3] - box[1])
    for state in states:
        if state not in seen_states:
            errors.append(f"{stem}: state '{state}' declared but no strip found")
    if not is_weapon:
        all_feet = [f for s, fs in feet.items() if s not in ("death",) for f in fs]
        if all_feet and max(all_feet) - min(all_feet) > CHAR_FOOT_TOLERANCE * 2:
            errors.append(f"{stem}: foot baseline wanders {min(all_feet)}..{max(all_feet)} px; keep the lowest opaque row constant (±{CHAR_FOOT_TOLERANCE})")
        ref = heights.get("idle") or next(iter(heights.values()), [])
        if ref:
            base = sorted(ref)[len(ref) // 2]
            for state, hs in heights.items():
                if state in ("death", "hurt", "threatened", "windup", "attack"):
                    continue
                for h in hs:
                    if abs(h - base) > base * CHAR_HEIGHT_TOLERANCE:
                        errors.append(f"{stem}/{state}: body height {h}px vs idle {base}px; do not rescale the body between frames")
                        break
    return errors, warnings


def cmd_check(args):
    total = 0
    for folder in args.dirs:
        folders = [Path(folder)] if (Path(folder) / f"{Path(folder).name}.anim.json").exists() else [p for p in Path(folder).iterdir() if p.is_dir()]
        for sub in folders:
            errors, warnings = check_dir(sub)
            for w in warnings:
                print("WARN ", w)
            for e in errors:
                print("ERROR", e)
            print(f"{'OK   ' if not errors else 'FAIL '} {sub}")
            total += len(errors)
    sys.exit(1 if total else 0)


def cmd_preview(args):
    folder = Path(args.dir)
    stem = folder.name
    manifest = json.loads((folder / f"{stem}.anim.json").read_text())
    cw, ch = manifest["cell"]
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    rows = []
    for png in sorted(folder.glob("*.png")):
        m = STRIP_RE.match(png.name)
        if not m:
            continue
        state = m.group("state")
        spec = manifest["states"].get(state, {})
        fps = float(spec.get("fps", 8))
        strip = Image.open(png).convert("RGBA")
        frames = frames_of(strip, cw, ch)
        scaled = [f.resize((cw * args.scale, ch * args.scale), Image.NEAREST) for f in frames]
        bg = [Image.new("RGBA", s.size, (40, 44, 42, 255)) for s in scaled]
        composed = [Image.alpha_composite(b, s).convert("P", palette=Image.ADAPTIVE) for b, s in zip(bg, scaled)]
        gif = out / png.with_suffix(".gif").name
        composed[0].save(gif, save_all=True, append_images=composed[1:], duration=int(1000 / fps), loop=0 if spec.get("loop", True) else 1)
        rows.append((png.stem, frames))
        print("wrote", gif)
    if rows:
        thumb = 0.5 if cw >= 640 else 1.0
        tw, th = int(cw * thumb), int(ch * thumb)
        width = max(len(f) for _, f in rows) * tw
        sheet = Image.new("RGBA", (width, th * len(rows)), (40, 44, 42, 255))
        for r, (_, frames) in enumerate(rows):
            for i, f in enumerate(frames):
                sheet.alpha_composite(f.resize((tw, th), Image.NEAREST), (i * tw, r * th))
        sheet.save(out / f"{stem}_contact.png")
        print("wrote", out / f"{stem}_contact.png")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("slice")
    s.add_argument("sheet")
    s.add_argument("--cell", required=True)
    s.add_argument("--out", required=True)
    s.add_argument("--stem", required=True)
    s.add_argument("--rows", required=True, help="state:frames,state:frames in row order")
    s.add_argument("--facing", type=int, default=1)
    s.add_argument("--weapon", action="store_true")
    s.add_argument("--key-magenta", action="store_true")
    s.set_defaults(func=cmd_slice)
    c = sub.add_parser("check")
    c.add_argument("dirs", nargs="+")
    c.set_defaults(func=cmd_check)
    p = sub.add_parser("preview")
    p.add_argument("dir")
    p.add_argument("--out", required=True)
    p.add_argument("--scale", type=int, default=2)
    p.set_defaults(func=cmd_preview)
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
