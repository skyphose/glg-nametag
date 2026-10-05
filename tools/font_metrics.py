#!/usr/bin/env python3
"""print a fonts.scad entry for a font file, so tag.scad can size text in it exactly.

usage:  python3 tools/font_metrics.py "/path/to/Font Bold.ttf" ["Family:style=Bold"]

the second argument is the name openscad knows the font by (help > font list).
leave it off and its read from the font file. paste the printed line into
FONT_METRICS in fonts.scad. needs fonttools:  pip install fonttools
"""
import sys

try:
    from fontTools.ttLib import TTFont
    from fontTools.pens.boundsPen import BoundsPen
except ImportError:
    sys.exit("needs fonttools:  pip install fonttools")


def metrics(path, font_index=0):
    f = TTFont(path, fontNumber=font_index)
    upm = f["head"].unitsPerEm
    cmap = f.getBestCmap()
    gs = f.getGlyphSet()
    # cap height from the actual H, the OS/2 field is missing or wrong in some fonts
    pen = BoundsPen(gs)
    gs[cmap[ord("H")]].draw(pen)
    cap = round(pen.bounds[3] / upm, 4)
    # how far lowercase tails (g j p q y) drop below the baseline
    low = 0
    for ch in "gjpqy":
        if ord(ch) in cmap:
            pen = BoundsPen(gs)
            gs[cmap[ord(ch)]].draw(pen)
            if pen.bounds:
                low = min(low, pen.bounds[1])
    desc = round(-low / upm, 4)
    hm = f["hmtx"]
    adv = [round(hm[cmap[c]][0] / upm, 3) if c in cmap else 0.6 for c in range(32, 127)]
    name = f["name"]
    fam = name.getDebugName(16) or name.getDebugName(1)
    sty = name.getDebugName(17) or name.getDebugName(2)
    return fam, sty, cap, desc, adv


def scad_line(font_string, cap, desc, adv):
    return '    ["%s", %s, [%s], %s],' % (font_string, cap, ",".join(str(a) for a in adv), desc)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    fam, sty, cap, desc, adv = metrics(sys.argv[1])
    font_string = sys.argv[2] if len(sys.argv) > 2 else "%s:style=%s" % (fam, sty)
    print(scad_line(font_string, cap, desc, adv))
