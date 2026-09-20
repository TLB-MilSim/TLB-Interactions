# -*- coding: utf-8 -*-
"""Generates the hotwire board's textures and converts them to PAA.

    python tools/gen_vehicle_assets.py

The board is the view a thief has with their shoulder on the driver's seat and
their head under the dash: carpet and a steering column, a plastic shroud held on
by screws, and behind it the ignition barrel with its loom running off to the
right. The wires themselves are the defusal board's cable sprites, tinted to the
same insulation palette, so the two boards look like they came out of the same
kit.

Needs Pillow. Conversion uses Arma 3 Tools' ImageToPAA.exe when it can be found;
without it the PNGs are left in tools/.png_vehicle for converting by hand.
ImageToPAA only accepts power-of-two sizes, so every canvas here is one.

Naming follows Arma convention: _co is opaque colour, _ca is colour with alpha.
"""
import math
import os
import random
import shutil
import subprocess

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PNG = os.path.join(ROOT, "tools", ".png_vehicle")
PAA = os.path.join(ROOT, "addons", "vehicle", "data")
SS = 4

random.seed(20260920)
os.makedirs(PNG, exist_ok=True)
os.makedirs(PAA, exist_ok=True)
written = []


def save(img, name):
    img.save(os.path.join(PNG, name + ".png"))
    written.append((name, img.size))


def noise(size, scale, sigma=48):
    w, h = size
    return Image.effect_noise((max(2, w // scale), max(2, h // scale)), sigma).resize(size, Image.BICUBIC)


def shade(size, stops, horizontal=False):
    """A luminance ramp from (position, level) stops, stretched over size."""
    length = size[0] if horizontal else size[1]
    vals = []
    for i in range(length):
        t = i / max(1, length - 1)
        for (t0, l0), (t1, l1) in zip(stops, stops[1:]):
            if t0 <= t <= t1:
                vals.append(int(l0 + (l1 - l0) * (t - t0) / max(1e-6, t1 - t0)))
                break
        else:
            vals.append(stops[-1][1])
    strip = Image.new("L", (length, 1) if horizontal else (1, length))
    strip.putdata(vals)
    return strip.resize(size)


def tint(gray, rgb):
    def lut(c):
        return [max(0, min(255, int(v * c / 128))) for v in range(256)]
    return Image.merge("RGB", tuple(gray.point(lut(c)) for c in rgb))


def grime(size, count, rgb, radius, alpha):
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for _ in range(count):
        r = random.uniform(*radius)
        x, y = random.uniform(0, size[0]), random.uniform(0, size[1])
        d.ellipse([x - r, y - r, x + r, y + r], fill=rgb + (int(alpha * random.uniform(0.3, 1)),))
    return layer.filter(ImageFilter.GaussianBlur(radius[1] * 0.4))


def make_column():
    """Under the dash: carpet, the column tube coming down from the right, a
    bulkhead behind it. Opaque, it is the board's backdrop."""
    w = h = 512 * SS // 4
    size = (w, h)

    base = shade(size, [(0, 44), (0.45, 30), (1, 16)])
    base = Image.blend(base, noise(size, 14, 30), 0.22)
    img = tint(base, (78, 76, 70)).convert("RGBA")

    d = ImageDraw.Draw(img, "RGBA")

    # Carpet along the bottom, darker and coarser than the bulkhead.
    carpet = tint(Image.blend(shade((w, h // 3), [(0, 34), (1, 12)]), noise((w, h // 3), 6, 42), 0.35), (70, 66, 58))
    img.paste(carpet.convert("RGBA"), (0, h - h // 3))

    # The column: a tube running from the top right down to the middle left.
    for off, lum in ((0, 58), (8, 72), (20, 44), (32, 30)):
        d.line(
            [(int(w * 0.98), int(h * 0.04) + off), (int(w * 0.16), int(h * 0.42) + off)],
            fill=(lum, lum - 3, lum - 8, 255), width=int(h * 0.040),
        )

    # A dark footwell shadow under it, so the shroud reads as sitting proud.
    shadow = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).polygon(
        [(0, int(h * 0.55)), (w, int(h * 0.18)), (w, h), (0, h)], fill=(0, 0, 0, 120)
    )
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(h * 0.05)))

    img.alpha_composite(grime(size, 90, (28, 24, 18), (h * 0.01, h * 0.05), 110))
    save(img.convert("RGB"), "column_co")


def make_shroud():
    """The plastic cover over the column: an upper and a lower moulding meeting
    at a parting seam, with raised bosses where the screws go.

    Authored at 4:1, which is the shape it is drawn at on the board. The earlier
    2:1 canvas was stretched to nearly twice its width in game, which turned the
    seam into a hairline and flattened everything else.
    """
    w, h = 1024, 256
    size = (w * SS // 2, h * SS // 2)
    W, H = size

    # Plastic: lighter along the top moulding, darker below the seam, with a
    # soft sheen where the cover turns away from the windscreen.
    panel = shade(size, [(0, 124), (0.16, 104), (0.44, 78), (0.50, 60), (0.56, 88), (0.82, 66), (1, 42)])
    panel = Image.blend(panel, noise(size, 26, 14), 0.10)
    img = tint(panel, (72, 72, 77)).convert("RGBA")

    d = ImageDraw.Draw(img, "RGBA")

    # The parting line: a groove with the faintest lip above it. It stops short
    # of the ends, because a moulding seam does, and a line running edge to edge
    # reads as a wire lying on the cover.
    seam = H * 0.50
    d.line([(W * 0.07, seam), (W * 0.93, seam)], fill=(22, 22, 24, 210), width=max(3, int(H * 0.030)))
    d.line([(W * 0.07, seam - H * 0.020), (W * 0.93, seam - H * 0.020)], fill=(150, 150, 156, 34), width=max(2, int(H * 0.007)))

    # Rounded corners, then an inner shadow so the cover reads as sitting proud
    # of the dashboard rather than painted on it.
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, W - 1, H - 1], radius=int(H * 0.22), fill=255)
    img.putalpha(mask)

    inner = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(inner).rounded_rectangle(
        [0, 0, W - 1, H - 1], radius=int(H * 0.22), outline=(0, 0, 0, 190), width=int(H * 0.06)
    )
    img.alpha_composite(inner.filter(ImageFilter.GaussianBlur(H * 0.03)))
    img.putalpha(mask)

    img.alpha_composite(grime(size, 70, (28, 26, 24), (H * 0.02, H * 0.08), 70))
    img.putalpha(mask)

    save(img.resize((w, h), Image.LANCZOS), "shroud_ca")


def make_screw():
    """A cross-head screw in a boss, seen straight on."""
    n = 64 * SS
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img, "RGBA")

    pad = n * 0.06
    d.ellipse([pad, pad, n - pad, n - pad], fill=(58, 58, 60, 255))
    d.ellipse([pad * 2, pad * 2, n - pad * 2.4, n - pad * 2.4], fill=(148, 148, 152, 255))
    d.ellipse([pad * 2.6, pad * 2.6, n - pad * 3.6, n - pad * 3.6], fill=(176, 176, 180, 255))

    # The cross, and a highlight on the upper left of the head.
    c, arm, thick = n / 2, n * 0.26, max(2, int(n * 0.055))
    d.line([(c - arm, c - arm * 0.08), (c + arm, c + arm * 0.08)], fill=(42, 42, 44, 255), width=thick)
    d.line([(c - arm * 0.08, c - arm), (c + arm * 0.08, c + arm)], fill=(42, 42, 44, 255), width=thick)
    d.arc([pad * 2.2, pad * 2.2, n - pad * 2.8, n - pad * 2.8], 150, 260, fill=(225, 225, 228, 160), width=max(1, int(n * 0.02)))

    save(img.resize((64, 64), Image.LANCZOS), "screw_ca")


def make_barrel():
    """The ignition barrel and the connector block the loom leaves from."""
    w = h = 256 * SS // 2
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img, "RGBA")

    # Barrel: a metal cylinder pointing left, with a keyway in the face.
    body = [int(w * 0.06), int(h * 0.22), int(w * 0.62), int(h * 0.78)]
    d.rounded_rectangle(body, radius=int(h * 0.1), fill=(126, 126, 130, 255))
    d.rounded_rectangle(
        [body[0] + w * 0.02, body[1] + h * 0.04, body[2] - w * 0.02, body[1] + h * 0.22],
        radius=int(h * 0.05), fill=(168, 168, 172, 160),
    )
    d.ellipse([int(w * 0.02), int(h * 0.26), int(w * 0.24), int(h * 0.74)], fill=(96, 96, 100, 255))
    d.rounded_rectangle(
        [int(w * 0.09), int(h * 0.46), int(w * 0.17), int(h * 0.54)], radius=int(h * 0.02), fill=(26, 26, 28, 255)
    )

    # Connector block: black plastic with a row of pins facing the loom.
    block = [int(w * 0.58), int(h * 0.18), int(w * 0.94), int(h * 0.82)]
    d.rounded_rectangle(block, radius=int(h * 0.06), fill=(38, 36, 38, 255))
    rows = 6
    for i in range(rows):
        y = block[1] + (block[3] - block[1]) * (i + 0.5) / rows
        d.rectangle([block[2] - w * 0.06, y - h * 0.018, block[2] + w * 0.02, y + h * 0.018], fill=(158, 142, 96, 255))

    img.alpha_composite(grime((w, h), 40, (24, 22, 20), (h * 0.01, h * 0.04), 90))
    save(img.resize((256, 256), Image.LANCZOS), "barrel_ca")


def make_strip():
    """Bare copper where the sheath has been taken off a wire."""
    w, h = 64, 64
    size = (w * SS, h * SS)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img, "RGBA")

    band = [0, int(size[1] * 0.3), size[0], int(size[1] * 0.7)]
    d.rectangle(band, fill=(182, 122, 58, 255))

    # Strands: a few lighter lines along the band, and a cut edge each side.
    for i in range(5):
        y = band[1] + (band[3] - band[1]) * (i + 0.5) / 5
        d.line([(0, y), (size[0], y)], fill=(224, 168, 96, 120), width=max(1, size[1] // 90))
    for x in (band[0] + size[0] * 0.02, band[2] - size[0] * 0.02):
        d.line([(x, band[1]), (x, band[3])], fill=(96, 62, 30, 220), width=max(2, size[0] // 40))

    save(img.resize((w, h), Image.LANCZOS), "strip_ca")


def make_icon():
    """The interaction menu icon: two stripped ends crossing, with a spark."""
    n = 64 * SS
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img, "RGBA")

    thick = max(3, int(n * 0.085))
    d.line([(n * 0.08, n * 0.3), (n * 0.52, n * 0.46)], fill=(235, 235, 235, 255), width=thick)
    d.line([(n * 0.08, n * 0.74), (n * 0.52, n * 0.56)], fill=(235, 235, 235, 255), width=thick)

    # The spark: a short star where the two ends nearly meet.
    cx, cy, r = n * 0.66, n * 0.5, n * 0.2
    for a in range(0, 360, 45):
        rad = math.radians(a)
        d.line(
            [(cx, cy), (cx + math.cos(rad) * r, cy + math.sin(rad) * r)],
            fill=(235, 235, 235, 255), width=max(2, int(n * 0.05)),
        )

    save(img.resize((64, 64), Image.LANCZOS), "hotwire_ca")


def make_pick_icon():
    """The lock pick icon, drawn to match TLB Keys' own: a hook pick and a
    tension wrench, crossed. Both mods show the same action, so they show the
    same picture, and ours is drawn here rather than borrowed so it is there
    without TLB Keys."""
    s = SS
    n = 128 * s
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    white = (255, 255, 255, 255)
    d.rounded_rectangle([14 * s, 92 * s, 60 * s, 110 * s], radius=int(6 * s), fill=white)
    d.line([(56 * s, 101 * s), (112 * s, 44 * s)], fill=white, width=int(7 * s))
    d.line([(112 * s, 44 * s), (106 * s, 26 * s), (116 * s, 16 * s)], fill=white, width=int(7 * s), joint="curve")
    d.line([(24 * s, 30 * s), (24 * s, 54 * s), (100 * s, 118 * s)], fill=white, width=int(8 * s), joint="curve")

    save(img.resize((128, 128), Image.LANCZOS), "icon_pick_ca")


def convert():
    candidates = [
        r"E:\SteamLibrary\steamapps\common\Arma 3 Tools\ImageToPAA\ImageToPAA.exe",
        r"C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\ImageToPAA\ImageToPAA.exe",
    ]
    tool = next((c for c in candidates if os.path.exists(c)), shutil.which("ImageToPAA"))
    if not tool:
        print("ImageToPAA not found - PNGs left in", PNG)
        return
    failed = []
    for name, _ in written:
        dst = os.path.join(PAA, name + ".paa")
        if os.path.exists(dst):
            os.remove(dst)
        subprocess.run([tool, os.path.join(PNG, name + ".png"), dst], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if not os.path.exists(dst):
            failed.append(name)
    print("converted %d/%d%s" % (len(written) - len(failed), len(written), "" if not failed else " FAILED: " + ", ".join(failed)))


if __name__ == "__main__":
    make_column()
    make_shroud()
    make_screw()
    make_barrel()
    make_strip()
    make_icon()
    make_pick_icon()
    bad = [n for n, (w, h) in written if (w & (w - 1)) or (h & (h - 1))]
    print("%d textures, non power-of-two: %s" % (len(written), bad or "none"))
    convert()
