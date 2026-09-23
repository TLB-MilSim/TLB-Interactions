# -*- coding: utf-8 -*-
"""Composites the hotwire board the way fn_hotwireDraw lays it out, from the
PNGs written by gen_vehicle_assets.py and gen_assets.py.

    python tools/preview_hotwire.py    -> tools/.preview/hotwire.png

Two frames: the shroud with its screws still in, and the loom part way through a
job, with three wires stripped, one cut, a twist between two of them and the
fourth selected.

The fractions here are the same ones in fn_hotwireDraw.sqf. If one moves, move it
in both.
"""
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PNG_V = os.path.join(ROOT, "tools", ".png_vehicle")
PNG_D = os.path.join(ROOT, "tools", ".png")
OUT = os.path.join(ROOT, "tools", ".preview")
os.makedirs(OUT, exist_ok=True)

BW, BH = 1171, 383

PALETTE = [
    (168, 51, 43), (43, 79, 143), (201, 166, 43), (64, 122, 66), (201, 196, 181),
    (112, 74, 135), (189, 107, 36), (107, 74, 48), (33, 33, 31), (97, 99, 92),
]

cache = {}


def sprite(name):
    if name not in cache:
        for folder in (PNG_V, PNG_D):
            path = os.path.join(folder, name + ".png")
            if os.path.exists(path):
                cache[name] = Image.open(path).convert("RGBA")
                break
        else:
            raise SystemExit("missing sprite: " + name)
    return cache[name]


def place(canvas, name, x, y, w, h, tint=None):
    s = sprite(name).resize((max(1, int(w * BW)), max(1, int(h * BH))), Image.BILINEAR)
    if tint:
        r, g, b, a = s.split()
        r, g, b = (ch.point(lambda v, k=k: v * k // 255) for ch, k in zip((r, g, b), tint))
        s = Image.merge("RGBA", (r, g, b, a))
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    layer.paste(s, (int(x * BW), int(y * BH)))
    return Image.alpha_composite(canvas, layer)


def fill(canvas, x, y, w, h, rgba):
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).rectangle([x * BW, y * BH, (x + w) * BW, (y + h) * BH], fill=rgba)
    return Image.alpha_composite(canvas, layer)


def label(canvas, text, x, y, w, h, rgba=(30, 30, 26, 255)):
    d = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("arialbd.ttf", int(h * BH * 0.8))
    except OSError:
        font = ImageFont.load_default()
    box = d.textbbox((0, 0), text, font=font)
    d.text(
        (x * BW + (w * BW - (box[2] - box[0])) / 2, y * BH + (h * BH - (box[3] - box[1])) / 2),
        text, font=font, fill=rgba,
    )
    return canvas


def shroud(screws=4):
    c = Image.new("RGBA", (BW, BH), (0, 0, 0, 255))
    c = place(c, "column_co", 0, 0, 1, 1)
    c = place(c, "shroud_ca", 0.06, 0.145, 0.88, 0.672)

    spots = [(0.13, 0.22), (0.85, 0.22), (0.13, 0.74), (0.85, 0.74), (0.49, 0.78), (0.49, 0.19)]
    for sx, sy in spots[:screws]:
        c = place(c, "screw_ca", sx - 0.028, sy - 0.045, 0.056, 0.090)
    return c


def loom(wires, sel, clip, joined):
    """wires: [(colour index, stripped, cut), ...]"""
    c = Image.new("RGBA", (BW, BH), (0, 0, 0, 255))
    c = place(c, "column_co", 0, 0, 1, 1)
    c = place(c, "barrel_ca", 0.02, 0.26, 0.20, 0.48)

    n = len(wires)
    row_h = 0.62 / n
    top = 0.16
    strip_x = 0.58

    def row_y(i):
        return top + (i + 0.5) * row_h

    for i, (colour, stripped, cut) in enumerate(wires):
        y = row_y(i)
        tint = PALETTE[colour]
        h = min(row_h * 1.5, 0.24)

        if i == sel:
            c = fill(c, 0.20, y - row_h * 0.46, 0.78, row_h * 0.92, (204, 168, 76, 31))

        if cut:
            c = place(c, "cable_dp0_a", 0.19, y - h / 2, 0.30, h, tint)
            c = place(c, "cable_dp0_b", 0.60, y - h / 2, 0.26, h, tint)
        else:
            c = place(c, "cable_dp0_a", 0.19, y - h / 2, 0.67, h, tint)

        if stripped and not cut:
            c = place(c, "strip_ca", strip_x - 0.024, y - h * 0.13, 0.048, h * 0.26)

        tag_tint = (219, 204, 107) if i == clip else (158, 153, 135)
        c = place(c, "tag_ca", 0.875, y - row_h * 0.36, 0.105, row_h * 0.72, tag_tint)
        c = label(c, str(i + 1), 0.875, y - row_h * 0.34, 0.105, row_h * 0.68)

    if len(joined) == 2:
        a, b = joined
        ya, yb = row_y(a), row_y(b)
        c = fill(c, strip_x - 0.006, min(ya, yb), 0.012, abs(ya - yb), (184, 133, 56, 255))

    return c


if __name__ == "__main__":
    frames = [
        shroud(4),
        loom(
            [(0, True, False), (8, False, False), (3, True, False), (3, True, False), (6, False, True)],
            sel=2, clip=0, joined=(0, 2),
        ),
    ]

    gap = 24
    sheet = Image.new("RGB", (BW, BH * len(frames) + gap * (len(frames) - 1)), (18, 18, 16))
    for i, f in enumerate(frames):
        sheet.paste(f.convert("RGB"), (0, i * (BH + gap)))

    path = os.path.join(OUT, "hotwire.png")
    sheet.save(path)
    print("wrote", path)
