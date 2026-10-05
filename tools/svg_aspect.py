#!/usr/bin/env python3
"""print the width / height of an svg, for logo_aspect in tag.scad.

usage:  python3 tools/svg_aspect.py logo.svg
reads the viewBox, or width and height when theres no viewBox. stdlib only.
"""
import re
import sys
import xml.etree.ElementTree as ET


def aspect(path):
    root = ET.parse(path).getroot()
    vb = root.get("viewBox")
    if vb:
        _, _, w, h = [float(v) for v in re.split(r"[ ,]+", vb.strip())]
    else:
        num = lambda s: float(re.match(r"[\d.]+", s).group())
        w, h = num(root.get("width")), num(root.get("height"))
    return round(w / h, 3)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    print(aspect(sys.argv[1]))
