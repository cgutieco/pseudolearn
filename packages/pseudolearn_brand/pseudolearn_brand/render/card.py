"""Social card: the lockup on a translucent plate over the brand ground, with the symbol as a watermark."""
from .parts import Fragment, gradient, gradient_id_for, mark_group, word_group


def render(composition, variant, id_prefix):
    gradient_id = gradient_id_for(variant, id_prefix)
    ground = (f'<defs>{gradient(composition.catalog.palette, gradient_id)}</defs>'
              f'<rect width="{variant.canvas:g}" height="{variant.canvas_height:g}" '
              f'fill="url(#{gradient_id})"/>')
    return Fragment(view_box=f"0 0 {variant.canvas:g} {variant.canvas_height:g}",
                    body=ground + _watermark(composition, variant)
                    + _lockup(composition, variant))


def _watermark(composition, variant):
    settings = composition.catalog.card
    mark = mark_group(composition, variant.canvas_height * settings.watermark_side,
                      variant.canvas * settings.watermark_center_x,
                      variant.canvas_height * settings.watermark_center_y, variant.ink)
    return f'<g opacity="{settings.watermark_opacity:g}">{mark}</g>'


def _lockup(composition, variant):
    settings = composition.catalog.card
    layout = composition.lockup("horizontal")
    scale = variant.canvas * settings.span / layout.width
    left = variant.canvas * settings.margin
    top = (variant.canvas_height - layout.height * scale) / 2 - layout.view_top * scale
    word = composition.wordmark
    return (f'<g transform="translate({left:.3f} {top:.3f}) scale({scale:.6f})">'
            + _plate(composition, variant, layout, scale)
            + mark_group(composition, layout.plate_side,
                         layout.plate_x + layout.plate_side / 2,
                         layout.plate_y + layout.plate_side / 2, variant.ink)
            + word_group(composition, layout.wordmark_dx - word.left,
                         layout.wordmark_dy - word.top + layout.view_top, variant.ink)
            + '</g>')


def _plate(composition, variant, layout, scale):
    settings = composition.catalog.card
    radius = layout.plate_side * composition.catalog.placement.squircle
    return (f'<rect x="{layout.plate_x:.3f}" y="{layout.plate_y:.3f}" '
            f'width="{layout.plate_side:.3f}" height="{layout.plate_side:.3f}" '
            f'rx="{radius:.3f}" ry="{radius:.3f}" fill="{variant.ink}" '
            f'fill-opacity="{settings.plate_opacity:g}" stroke="{variant.ink}" '
            f'stroke-opacity="{settings.plate_outline_opacity:g}" '
            f'stroke-width="{settings.plate_outline / scale:.4f}"/>')
