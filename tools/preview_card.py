# -*- coding: utf-8 -*-
"""Composites a whole board, chrome and all, the way the dialog lays it out.

    python tools/preview_card.py    -> docs/images/hotwire.jpg

The board previews (preview_board.py, preview_lockpick.py, preview_hotwire.py)
draw what is inside the board well. This wraps one of those in the case around
it: the panel, the LCD, the stage name, the hint line and the tool plates, at the
size the documentation and the Workshop page use.

Positions are the ones in the dialog, as fractions of the screen, mapped onto the
panel rectangle, so the picture matches what the game draws.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import preview_hotwire as hw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PNG_D = os.path.join(ROOT, "tools", ".png")
OUT = os.path.join(ROOT, "docs", "images")

IMG_W, IMG_H = 1600, 878

# The dialog, in screen fractions (gui/dialog.hpp).
PANEL = (0.170, 0.178, 0.660, 0.644)
BOARD = (0.195, 0.285, 0.610, 0.355)
LCD = (0.195, 0.651, 0.420, 0.044)
TITLE_Y, SUB_Y, STATUS_Y, PLATE_Y = 0.192, 0.242, 0.700, 0.742
PLATE_W, PLATE_STEP, PLATE_X0, PLATE_H = 0.095, 0.103, 0.195, 0.052

GOLD = (204, 168, 76)
PALE = (158, 153, 135)
LCD_INK = (26, 31, 20)


def rect(x, y, w, h):
    """A dialog rectangle, mapped onto the panel crop."""
    px, py, pw, ph = PANEL
    return (
        int((x - px) / pw * IMG_W),
        int((y - py) / ph * IMG_H),
        int(w / pw * IMG_W),
        int(h / ph * IMG_H),
    )


def font(name, px):
    try:
        return ImageFont.truetype(name, px)
    except OSError:
        return ImageFont.load_default()


def text(d, s, box, f, fill, align="left"):
    x, y, w, h = box
    tw = d.textbbox((0, 0), s, font=f)[2]
    if align == "center":
        x += (w - tw) / 2
    elif align == "right":
        x += w - tw
    d.text((x, y + h * 0.5), s, font=f, fill=fill, anchor="lm")


def card(inner, title, subtitle, readout, stage, status, plates):
    """inner: the board picture, already at the board well's proportions."""
    img = Image.new("RGBA", (IMG_W, IMG_H), (0, 0, 0, 255))

    panel = Image.open(os.path.join(PNG_D, "panel_co.png")).convert("RGBA")
    img.alpha_composite(panel.resize((IMG_W, IMG_H), Image.LANCZOS))

    bx, by, bw, bh = rect(*BOARD)
    img.paste(inner.convert("RGBA").resize((bw, bh), Image.LANCZOS), (bx, by))
    ImageDraw.Draw(img).rectangle([bx - 3, by - 3, bx + bw + 2, by + bh + 2], outline=(14, 14, 12, 255), width=3)

    lcd = Image.open(os.path.join(PNG_D, "lcd_co.png")).convert("RGBA")
    lx, ly, lw, lh = rect(*LCD)
    img.alpha_composite(lcd.resize((lw, lh), Image.LANCZOS), (lx, ly))

    plate = Image.open(os.path.join(PNG_D, "plate_co.png")).convert("RGBA")
    for i, label in enumerate(plates):
        px, py, pw, ph = rect(PLATE_X0 + i * PLATE_STEP, PLATE_Y, PLATE_W, PLATE_H)
        tinted = plate.resize((pw, ph), Image.LANCZOS)
        r, g, b, a = tinted.split()
        k = (0.60, 0.62, 0.54) if i < len(plates) - 1 else (0.48, 0.50, 0.44)
        r, g, b = (ch.point(lambda v, m=m: int(v * m)) for ch, m in zip((r, g, b), k))
        img.alpha_composite(Image.merge("RGBA", (r, g, b, a)), (px, py))

    d = ImageDraw.Draw(img)

    text(d, title, rect(0.195, TITLE_Y, 0.610, 0.045), font("bahnschrift.ttf", 44), GOLD)
    text(d, subtitle, rect(0.195, SUB_Y, 0.610, 0.035), font("bahnschrift.ttf", 27), PALE)
    text(d, readout, (lx + int(lw * 0.03), ly, lw, lh), font("consolab.ttf", 30), LCD_INK)
    text(d, stage, rect(0.625, 0.652, 0.180, 0.042), font("bahnschrift.ttf", 30), GOLD, "right")
    text(d, status, rect(0.195, STATUS_Y, 0.610, 0.034), font("bahnschrift.ttf", 26), PALE)

    for i, label in enumerate(plates):
        box = rect(PLATE_X0 + i * PLATE_STEP, PLATE_Y, PLATE_W, PLATE_H)
        text(d, label, box, font("bahnschrift.ttf", 25), (228, 228, 220), "center")

    return img.convert("RGB")


# One job, told in order. The same five wires throughout, so the set reads as one
# vehicle being worked on rather than five unrelated pictures.
#   1 red     battery feed
#   2 black   lamps
#   3 green   coil, the ignition feed
#   4 green   solenoid, the starter feed
#   5 orange  lamps, and on a service loom this is the alarm
WIRES = [0, 8, 3, 3, 6]

TITLE = "UNDER THE COLUMN - HOTWIRE IT"
SUBTITLE = "Hilux (Covered)  ·  Service loom  ·  5 wires"

LOOM_PLATES = ["Strip", "", "Volts", "Ohms", "Cut", "Back off"]


def wires(states):
    """states: [(stripped, cut, note), ...] in wire order."""
    return [(WIRES[i], st, cut, note) for i, (st, cut, note) in enumerate(states)]


def shroud_card():
    """Nothing is reachable until the cover is off."""
    return card(
        hw.shroud(4), TITLE, SUBTITLE, "", "SHROUD",
        "Click each screw to take it out, then the shroud comes off. 4 left.",
        ["", "", "", "", "", "Back off"],
    )


def loom_card():
    """The cover is off: the barrel, the loom, and nothing known about any of it."""
    inner = hw.loom(wires([(False, False, "")] * 5), sel=0, clip=-1, joined=())
    return card(
        inner, TITLE, SUBTITLE, "", "LOOM",
        "Goal: twist the live feed onto the one that runs to the coil. Strip a wire, then Volts and Ohms.",
        LOOM_PLATES,
    )


def strip_card():
    """Two wires read, a third selected with its sheath still on."""
    inner = hw.loom(wires([
        (True, False, "12 V"),
        (True, False, "0 V  LAMPS"),
        (False, False, ""),
        (False, False, ""),
        (False, False, ""),
    ]), sel=2, clip=-1, joined=())
    return card(
        inner, TITLE, SUBTITLE, "W2   LAMPS", "LOOM",
        "Wire 3 is still sheathed. Strip it, then put the meter across it.",
        LOOM_PLATES,
    )


def tested_card():
    """Every wire read. The battery feed and the coil feed are the pair."""
    inner = hw.loom(wires([
        (True, False, "12 V"),
        (True, False, "0 V  LAMPS"),
        (True, False, "0 V  COIL"),
        (True, False, "0 V  SOLENOID"),
        (True, True, "0 V  LAMPS"),
    ]), sel=0, clip=-1, joined=())
    return card(
        inner, TITLE, SUBTITLE, "W3   COIL", "LOOM",
        "Wire 1 is live and wire 3 runs to the coil. Twist on one, then the other.",
        ["Twist", "", "Volts", "Ohms", "Cut", "Back off"],
    )


def steering_card():
    """The pair is twisted, the dash is live, the wheel is not free yet."""
    inner = hw.loom(wires([
        (True, False, "12 V"),
        (True, False, "0 V  LAMPS"),
        (True, False, "0 V  COIL"),
        (True, False, "0 V  SOLENOID"),
        (True, True, "0 V  LAMPS"),
    ]), sel=2, clip=-1, joined=(0, 2))
    return card(
        inner, TITLE, SUBTITLE, "STEERING LOCK   64%", "STEERING",
        "Hold Space to force the steering lock.",
        ["", "Force", "", "", "", "Back off"],
    )


def crank_card():
    """The engine catching, which is the moment to let go."""
    inner = hw.loom(wires([
        (True, False, "12 V"),
        (True, False, "0 V  LAMPS"),
        (True, False, "0 V  COIL"),
        (True, False, "0 V  SOLENOID"),
        (True, True, "0 V  LAMPS"),
    ]), sel=3, clip=-1, joined=(0, 2))
    return card(
        inner, TITLE, SUBTITLE, "IT CATCHES - LET GO", "IGNITION",
        "The dash is live. Hold Space to crank, and let go the moment the readout says it catches.",
        ["", "Crank", "", "", "", "Back off"],
    )


CARDS = [
    ("hotwire-shroud.jpg", shroud_card),
    ("hotwire-loom.jpg", loom_card),
    ("hotwire-strip.jpg", strip_card),
    ("hotwire.jpg", tested_card),
    ("hotwire-steering.jpg", steering_card),
    ("hotwire-crank.jpg", crank_card),
]


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, fnc in CARDS:
        path = os.path.join(OUT, name)
        fnc().save(path, quality=92)
        print("wrote", path)
