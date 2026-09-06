"""Real IBM Plex outlines as SVG path data, read from the faces this package vendors."""
from pathlib import Path

from fontTools.misc.transform import Transform
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

FONT_DIRECTORY = Path(__file__).resolve().parents[2] / "assets" / "fonts"

_fonts = {}


def _font(file_name):
    if file_name not in _fonts:
        _fonts[file_name] = TTFont(FONT_DIRECTORY / file_name)
    return _fonts[file_name]


def _kerning(font):
    pairs = {}
    if "GPOS" not in font:
        return pairs
    for lookup in font["GPOS"].table.LookupList.Lookup:
        for subtable in lookup.SubTable:
            if getattr(subtable, "LookupType", None) == 9 and hasattr(subtable, "ExtSubTable"):
                subtable = subtable.ExtSubTable
            if getattr(subtable, "Format", None) == 1 and hasattr(subtable, "PairSet"):
                _collect_pairs(subtable, pairs)
            elif getattr(subtable, "Format", None) == 2 and hasattr(subtable, "ClassDef1"):
                _collect_classes(subtable, pairs)
    return pairs


def _collect_pairs(subtable, pairs):
    for first, pair_set in zip(subtable.Coverage.glyphs, subtable.PairSet):
        for record in pair_set.PairValueRecord:
            advance = getattr(record.Value1, "XAdvance", 0) or 0
            if advance:
                pairs[(first, record.SecondGlyph)] = advance


def _collect_classes(subtable, pairs):
    first_classes = subtable.ClassDef1.classDefs
    second_classes = subtable.ClassDef2.classDefs
    for first in subtable.Coverage.glyphs:
        for second, second_class in second_classes.items():
            first_class = first_classes.get(first, 0)
            try:
                record = subtable.Class1Record[first_class].Class2Record[second_class]
            except IndexError:
                continue
            advance = getattr(record.Value1, "XAdvance", 0) or 0
            if advance:
                pairs[(first, second)] = advance


def _setting(font_file, text, size, tracking):
    font = _font(font_file)
    scale = size / font["head"].unitsPerEm
    glyph_set = font.getGlyphSet()
    metrics = font["hmtx"]
    kerning = _kerning(font)
    names = [font.getBestCmap()[ord(character)] for character in text]
    placements = []
    pen_x = 0.0
    for index, name in enumerate(names):
        placements.append((name, pen_x))
        pen_x += metrics[name][0]
        if index + 1 < len(names):
            pen_x += kerning.get((name, names[index + 1]), 0)
        pen_x += tracking / scale
    return glyph_set, scale, placements, pen_x


def run(font_file, text, size, x, baseline, tracking=0.0):
    """Return (svg_path_data, advance_width) for `text` set at `size` units."""
    glyph_set, scale, placements, pen_x = _setting(font_file, text, size, tracking)
    commands = []
    for name, offset in placements:
        transform = Transform().translate(x + offset * scale, baseline).scale(scale, -scale)
        pen = SVGPathPen(glyph_set, ntos=lambda value: f"{value:.3f}".rstrip("0").rstrip("."))
        glyph_set[name].draw(TransformPen(pen, transform))
        drawn = pen.getCommands()
        if drawn:
            commands.append(drawn)
    return " ".join(commands), pen_x * scale


def ink_bounds(font_file, text, size, x, baseline, tracking=0.0):
    """Tight ink bounding box of a run, in the same space as `run`."""
    glyph_set, scale, placements, _pen_x = _setting(font_file, text, size, tracking)
    box = None
    for name, offset in placements:
        pen = BoundsPen(glyph_set)
        glyph_set[name].draw(pen)
        if not pen.bounds:
            continue
        x0, y0, x1, y1 = pen.bounds
        candidate = (x + (offset + x0) * scale, baseline - y1 * scale,
                     x + (offset + x1) * scale, baseline - y0 * scale)
        box = candidate if box is None else (min(box[0], candidate[0]), min(box[1], candidate[1]),
                                             max(box[2], candidate[2]), max(box[3], candidate[3]))
    return box
