"""The brand module the store media engine composes its pieces from."""
import json

from . import svg, typescript

LOCKUPS = (("BRAND_LOCKUP_HORIZONTAL_SVG", "lockup-horizontal"),
           ("BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG", "lockup-horizontal-inverse"))

PALETTE = ("\n"
           "export const BRAND_GROUND_TOP = '{ground_top}';\n"
           "\n"
           "export const BRAND_GROUND_BOTTOM = '{ground_bottom}';\n"
           "\n"
           "export const BRAND_INK = '{ink}';\n"
           "\n"
           "export const BRAND_DEEP = '{deep}';\n")


def module(composition, catalog):
    palette = catalog.palette
    parts = [typescript.module(composition, catalog),
             PALETTE.format(ground_top=palette.ground_top, ground_bottom=palette.ground_bottom,
                            ink=palette.ink, deep=palette.deep)]
    for constant, name in LOCKUPS:
        variant = next(entry for entry in catalog.variants if entry.name == name)
        document = json.dumps(svg.document(composition, variant).strip())
        parts.append(f"\nexport const {constant} =\n  {document};\n")
    return "".join(parts)
