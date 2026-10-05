// scad-tag - a parametric name tag. drop in your own svg, type a name, get a 3mf.
// 100 x 25 mm plate by default, 2 mm base, 1 mm rim, logo + name + title raised 1 mm.
//
// use it (openscad 2021.01 or newer):
//   1. keep this file next to fonts.scad and the fonts/ folder.
//   2. window > customizer. type a name and title, F6, then file > export > 3mf or stl.
//   3. for a logo, put your svg next to this file and type its name into logo_file.
//      set logo_aspect to its width / height (python3 tools/svg_aspect.py your.svg).
//   4. for a whole sheet of tags, turn on batch mode, or use export_tags.sh with names.csv.

// free fonts that ship with the repo, loaded here so they work without being installed.
use <fonts/ComicNeue-Bold.ttf>
use <fonts/BarlowSemiCondensed-Medium.ttf>
use <fonts/BarlowSemiCondensed-SemiBold.ttf>
include <fonts.scad>

/* [Text] */
// Big name line
name = "Your Name";
// Smaller line under the name. Leave blank for a name-only tag.
title = "Your Title";
// Force everything to CAPITALS
all_caps = false;

/* [Batch Mode (many tags on one plate)] */
batch_mode = false;
// Comma separated. Name:Title, or just Name for no title.
batch_list = "Alex:Lounge Associate, Sam:Judge, Jordan:Tournament Organizer, Riley";
// Tags per row on the plate
batch_columns = 2;
// Gap between tags (mm)
batch_gap = 4;

/* [Font] */
// Comic Sans comes with macOS and Windows. On Linux, use Comic Neue (bundled, free) instead.
name_font = "Comic Sans MS:style=Bold"; // [Comic Sans MS:style=Bold, Comic Sans MS:style=Regular, Comic Neue:style=Bold, Barlow Semi Condensed Medium, Barlow Semi Condensed SemiBold, DIN Pro:style=Medium, Liberation Sans:style=Bold, Arial:style=Bold, Impact:style=Regular, Verdana:style=Bold, Trebuchet MS:style=Bold, Georgia:style=Bold, Times New Roman:style=Bold, Courier New:style=Bold, Custom]
title_font = "Comic Sans MS:style=Bold"; // [Comic Sans MS:style=Bold, Comic Sans MS:style=Regular, Comic Neue:style=Bold, Barlow Semi Condensed Medium, Barlow Semi Condensed SemiBold, DIN Pro:style=Medium, Liberation Sans:style=Bold, Arial:style=Bold, Impact:style=Regular, Verdana:style=Bold, Trebuchet MS:style=Bold, Georgia:style=Bold, Times New Roman:style=Bold, Courier New:style=Bold, Custom]
// Any installed font, used when a font above is set to Custom. Exact name from help > font list.
custom_font = "Futura:style=Bold";
// Custom font not in fonts.scad: how wide it runs compared to Arial Bold (1 = same)
custom_width_factor = 1.0;

/* [Text Size & Placement] */
// Height of the CAPITAL letters in the name (mm)
name_cap_height = 12;
// Name height for a tag with no title (mm)
name_cap_height_solo = 14;
// Height of the CAPITAL letters in the title (mm)
title_cap_height = 4.5;
// Gap between name and title (mm)
line_gap = 1.2;
// Letter spacing (1 = normal)
name_spacing = 1.0;
title_spacing = 1.05;
text_align = "center"; // [left, center, right]
// Nudge the whole text block (mm)
text_offset_x = 0;
text_offset_y = 0;
// Space between the text and the rim (mm)
text_margin = 2;
// Space between the text and the rim, top and bottom (mm)
text_margin_v = 1;
// Shrink text to fit the plate. Off = always use the heights above.
auto_shrink_to_fit = true;

/* [Logo] */
// Your svg, in the same folder as this file. Leave blank for a text-only tag.
logo_file = "";
// Width / height of your svg. python3 tools/svg_aspect.py your.svg prints it.
logo_aspect = 1.0;
// Logo height on the tag (mm)
logo_height = 18;
logo_side = "left"; // [left, right]
// Distance from the inside of the rim to the logo (mm)
logo_margin = 2;
// Space between the logo and the text (mm)
logo_text_gap = 3;
// Nudge logo up/down (mm)
logo_offset_y = 0;
// Fatten thin bits of the logo for printing (mm, 0 = off, try 0.1-0.2)
logo_thicken = 0;

/* [Plate] */
plate_length = 100;
plate_width = 25;
// Plate thickness under the raised details (mm)
base_thickness = 2;
// Height of the raised logo / text / rim (mm)
raised_height = 1;
corner_radius = 5;
show_rim = true;
rim_width = 1;

/* [Back Side] */
back_style = "None"; // [None, Magnets, Pin bar recess]
// Number of magnet pockets (1 or 2)
magnet_count = 2;
// Pocket diameter (add ~0.2 mm clearance to your magnet)
magnet_diameter = 10.2;
// Pocket depth (leave at least 0.6 mm of plate under it)
magnet_depth = 1.2;
// Pin bar recess (mm)
pin_length = 26;
pin_width = 6;
pin_depth = 0.8;

/* [Export / Multi-color] */
// Base and raised separately for two colors, or do a filament change at Z = base_thickness.
part = "All"; // [All, Base only, Raised only, Logo only, Text and rim only]
// Preview colors only, they dont change the model
plate_color = "#2b2b2b";
detail_color = "#f2f2f2";

/* [Hidden] */
$fn = 64;
// curve detail for text. 64 can make degenerate slivers in some fonts and break the export.
text_fn = 32;
eps = 0.01;

// --------------------------------------------------------------------
//  fonts
// --------------------------------------------------------------------
NAME_FONT  = name_font  == "Custom" ? custom_font : name_font;
TITLE_FONT = title_font == "Custom" ? custom_font : title_font;

function _find(f) = [for (e = FONT_METRICS) if (e[0] == f) e];
_ARIAL = _find("Arial:style=Bold")[0];
// [cap ratio, advance table, width factor, descender]. unknown fonts borrow arial bold's widths.
function metrics(f) = let(m = _find(f))
    len(m) > 0 ? [m[0][1], m[0][2], 1, m[0][3]] : [0.72, _ARIAL[2], custom_width_factor, 0.22];

NAME_M  = metrics(NAME_FONT);
TITLE_M = metrics(TITLE_FONT);

// --------------------------------------------------------------------
//  string helpers
// --------------------------------------------------------------------
function upper(s) = len(s) == 0 ? "" :
    chr([for (c = s) let(o = ord(c)) (o >= 97 && o <= 122) ? o - 32 : o]);

function split(s, sep, i = 0, cur = "", acc = []) =
    i >= len(s) ? concat(acc, [cur]) :
    s[i] == sep ? split(s, sep, i + 1, "", concat(acc, [cur])) :
                  split(s, sep, i + 1, str(cur, s[i]), acc);

function _lstrip(s, i = 0) = (i < len(s) && s[i] == " ") ? _lstrip(s, i + 1) : i;
function _rstrip(s, i)     = (i > 0 && s[i - 1] == " ") ? _rstrip(s, i - 1) : i;
function str_join(v, i = 0) = i >= len(v) ? "" : str(v[i], str_join(v, i + 1));
function substr(s, a, b)   = a >= b ? "" : str_join([for (k = [a:b - 1]) s[k]]);
function trim(s) = let(a = _lstrip(s), b = _rstrip(s, len(s))) substr(s, a, b);

function vsum(v, i = 0) = i >= len(v) ? 0 : v[i] + vsum(v, i + 1);
function adv(c, tbl) = let(o = ord(c)) (o >= 32 && o <= 126) ? tbl[o - 32] : 0.6;
// width in em
function text_em(s, m, spacing) = len(s) == 0 ? 0 :
    vsum([for (c = s) adv(c, m[1])]) * spacing * m[2];

// openscad: em = size / 0.72, so cap height = size * cap_ratio / 0.72
function size_for_cap(h, m) = h * 0.72 / m[0];
function size_for_width(s, w, m, spacing) =
    text_em(s, m, spacing) == 0 ? 1e9 : w * 0.72 / text_em(s, m, spacing);

// --------------------------------------------------------------------
//  layout
// --------------------------------------------------------------------
has_logo   = logo_file != "";
logo_w     = has_logo ? logo_height * logo_aspect : 0;
inner      = show_rim ? rim_width : 0;
logo_x0    = logo_side == "left" ? inner + logo_margin
                                 : plate_length - inner - logo_margin - logo_w;
text_x0    = (has_logo && logo_side == "left")  ? logo_x0 + logo_w + logo_text_gap : inner + text_margin;
text_x1    = (has_logo && logo_side == "right") ? logo_x0 - logo_text_gap : plate_length - inner - text_margin;
text_w     = text_x1 - text_x0;

// --------------------------------------------------------------------
//  geometry
// --------------------------------------------------------------------
module rounded_rect(l, w, r) {
    rr = min(r, w / 2 - eps, l / 2 - eps);
    translate([rr, rr]) offset(r = rr) square([l - 2 * rr, w - 2 * rr]);
}

module plate2d() rounded_rect(plate_length, plate_width, corner_radius);

module rim2d() difference() {
    plate2d();
    offset(delta = -rim_width) plate2d();
}

module logo2d() {
    translate([logo_x0 + logo_w / 2, plate_width / 2 + logo_offset_y])
        offset(delta = logo_thicken)
            resize([logo_w, logo_height])
                import(logo_file, center = true);
}

// does the text have tails below the baseline (g j p q y , ;)?
function has_desc(s) = len([for (c = s) if (search(c, "gjpqy,;") != []) 1]) > 0;

module text2d(nm, ttl) {
    N = all_caps ? upper(nm) : nm;
    T = all_caps ? upper(ttl) : ttl;
    has_title = len(T) > 0;

    // sizes asked for, then shrunk to fit the width
    n_req = size_for_cap(has_title ? name_cap_height : name_cap_height_solo, NAME_M);
    t_req = size_for_cap(title_cap_height, TITLE_M);
    n_w   = auto_shrink_to_fit ? min(n_req, size_for_width(N, text_w, NAME_M, name_spacing)) : n_req;
    t_w   = auto_shrink_to_fit ? min(t_req, size_for_width(T, text_w, TITLE_M, title_spacing)) : t_req;

    // heights per unit of font size: caps, plus tails if the line has any
    n_h = (NAME_M[0] + (has_desc(N) ? NAME_M[3] : 0)) / 0.72;
    t_h = has_title ? (TITLE_M[0] + (has_desc(T) ? TITLE_M[3] : 0)) / 0.72 : 0;
    gap = has_title ? line_gap : 0;

    // then shrink both lines together if the block is taller than the plate
    avail = plate_width - 2 * inner - 2 * text_margin_v;
    tall  = n_w * n_h + t_w * t_h;
    k     = (auto_shrink_to_fit && tall > avail - gap) ? (avail - gap) / tall : 1;
    n_size = n_w * k;
    t_size = t_w * k;

    n_cap  = n_size * NAME_M[0] / 0.72;
    t_cap  = t_size * TITLE_M[0] / 0.72;
    n_desc = has_desc(N) ? n_size * NAME_M[3] / 0.72 : 0;
    t_desc = (has_title && has_desc(T)) ? t_size * TITLE_M[3] / 0.72 : 0;

    block_h = n_cap + n_desc + gap + (has_title ? t_cap + t_desc : 0);
    bottom  = plate_width / 2 - block_h / 2 + text_offset_y;
    x = (text_align == "left"  ? text_x0 :
         text_align == "right" ? text_x1 :
                                 (text_x0 + text_x1) / 2) + text_offset_x;

    title_base = bottom + t_desc;
    name_base  = has_title ? title_base + t_cap + gap + n_desc : bottom + n_desc;

    translate([x, name_base])
        text(N, size = n_size, $fn = text_fn, font = NAME_FONT, halign = text_align, valign = "baseline",
             spacing = name_spacing);
    if (has_title)
        translate([x, title_base])
            text(T, size = t_size, $fn = text_fn, font = TITLE_FONT, halign = text_align, valign = "baseline",
                 spacing = title_spacing);
}

module base3d() difference() {
    linear_extrude(base_thickness) plate2d();

    if (back_style == "Magnets") {
        xs = magnet_count >= 2 ? [plate_length * 0.25, plate_length * 0.75] : [plate_length / 2];
        for (mx = xs)
            translate([mx, plate_width / 2, -eps])
                cylinder(d = magnet_diameter, h = magnet_depth + eps);
    }
    if (back_style == "Pin bar recess")
        translate([plate_length / 2 - pin_length / 2, plate_width * 0.62 - pin_width / 2, -eps])
            cube([pin_length, pin_width, pin_depth + eps]);
}

module raised3d(which, nm, ttl) {
    translate([0, 0, base_thickness - eps])
        linear_extrude(raised_height + eps) {
            if (which != "logo") {
                if (show_rim) rim2d();
                text2d(nm, ttl);
            }
            if (which != "text" && has_logo) logo2d();
        }
}

module tag(nm, ttl) {
    if (part == "All") {
        color(plate_color) base3d();
        color(detail_color) raised3d("all", nm, ttl);
    }
    else if (part == "Base only")         base3d();
    else if (part == "Raised only")       raised3d("all", nm, ttl);
    else if (part == "Logo only")         raised3d("logo", nm, ttl);
    else if (part == "Text and rim only") raised3d("text", nm, ttl);
}

// --------------------------------------------------------------------
//  build
// --------------------------------------------------------------------
if (batch_mode) {
    entries = [for (e = split(batch_list, ",")) let(t = trim(e)) if (len(t) > 0) split(t, ":")];
    for (i = [0 : len(entries) - 1]) {
        e   = entries[i];
        col = i % batch_columns;
        row = floor(i / batch_columns);
        translate([col * (plate_length + batch_gap), -row * (plate_width + batch_gap), 0])
            tag(trim(e[0]), len(e) > 1 ? trim(e[1]) : "");
    }
} else {
    tag(name, title);
}
