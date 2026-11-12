"""The Nodo glyph geometry as a TypeScript module, and the literals the app painter must keep."""

MODULE = ("export const NODO_GLYPH_GRID = {grid:g};\n"
          "\n"
          "export const NODO_GLYPH_STROKE = {stroke:g};\n"
          "\n"
          "export const NODO_GLYPH_NODE = {{ cx: {node_x:g}, cy: {node_y:g}, r: {node_radius:g} }};\n"
          "\n"
          "export const NODO_GLYPH_EYES = {{\n"
          "  y: {eye_y:g},\n"
          "  r: {eye_radius:g},\n"
          "  xs: [{eye_left_x:g}, {eye_right_x:g}],\n"
          "}};\n"
          "\n"
          "export const NODO_GLYPH_WIRE_PATH = '{wire}';\n"
          "\n"
          "export const NODO_GLYPH_SPARKLE_ORIGIN = {{ x: {sparkle_x:g}, y: {sparkle_y:g} }};\n"
          "\n"
          "export const NODO_GLYPH_SPARKLE_PATH = '{sparkle}';\n")


def module(catalog):
    glyph = catalog.nodo_glyph
    return MODULE.format(**vars(glyph), wire=glyph.wire_path, sparkle=glyph.sparkle_path)


def painter_literals(catalog):
    glyph = catalog.nodo_glyph
    return (
        f"static const double grid = {glyph.grid:g};",
        f"Offset({glyph.node_x:g}, {glyph.node_y:g}), {glyph.node_radius:g}",
        f"Offset({glyph.eye_left_x:g}, {glyph.eye_y:g}), {glyph.eye_radius:g}",
        f"Offset({glyph.eye_right_x:g}, {glyph.eye_y:g}), {glyph.eye_radius:g}",
        f"..moveTo({glyph.wire_start_x:g}, {glyph.wire_start_y:g})",
        f"..lineTo({glyph.wire_start_x:g}, {glyph.wire_bend_y:g})",
        f"..lineTo({glyph.wire_end_x:g}, {glyph.wire_bend_y:g})",
        f"canvas.translate({glyph.sparkle_x:g}, {glyph.sparkle_y:g})",
    )


def mismatches(catalog, source):
    return [f"the painter no longer contains `{literal}`"
            for literal in painter_literals(catalog) if literal not in source]
