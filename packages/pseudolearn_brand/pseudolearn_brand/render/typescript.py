"""The symbol path as a TypeScript module, for the web frontend that cannot read an SVG file."""
from .svg import render

MODULE = ("export const BRAND_SYMBOL_VIEW_BOX = '{view_box}';\n"
          "\n"
          "export const BRAND_SYMBOL_PATH =\n"
          "  '{path}';\n")


def module(composition, catalog):
    variant = next(entry for entry in catalog.variants if entry.composition == "symbol")
    return MODULE.format(view_box=render(composition, variant).view_box,
                         path=composition.path_for(""))
