"""The symbol path as a TypeScript module, for the web frontend that cannot read an SVG file."""
from .svg import render

MODULE = ("export const BRAND_SYMBOL_VIEW_BOX = '{view_box}';\n"
          "\n"
          "export const BRAND_SYMBOL_PATH =\n"
          "  '{path}';\n"
          "\n"
          "export const BRAND_SYMBOL_ROUTE_PATH =\n"
          "  '{route}';\n"
          "\n"
          "export const BRAND_SYMBOL_FLAG_PATH =\n"
          "  '{flag}';\n"
          "\n"
          "export const BRAND_SYMBOL_CENTERLINE = '{centerline}';\n"
          "\n"
          "export const BRAND_SYMBOL_STROKE = {stroke};\n")


def module(composition, catalog):
    variant = next(entry for entry in catalog.variants if entry.composition == "symbol")
    return MODULE.format(view_box=render(composition, variant).view_box,
                         path=composition.path_for(""),
                         route=composition.path_for("route"),
                         flag=composition.path_for("flag"),
                         centerline=composition.path_for("centerline"),
                         stroke=f"{catalog.symbol.stroke:g}")
