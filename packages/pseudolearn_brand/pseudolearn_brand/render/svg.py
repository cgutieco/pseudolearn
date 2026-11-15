"""Rendering of a catalog variant as an SVG document or as an inlinable fragment."""
from . import card
from .parts import Fragment, gradient, gradient_id_for, mark_group, word_group

DOCUMENT = ('<?xml version="1.0" encoding="UTF-8"?>\n'
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view_box}"{attributes}>\n'
            '<title>{title}</title>\n{body}\n</svg>\n')


def document(composition, variant):
    fragment = render(composition, variant)
    attributes = f' color="{variant.color_attribute}"' if variant.color_attribute else ""
    return DOCUMENT.format(view_box=fragment.view_box, attributes=attributes,
                           title=variant.title, body=fragment.body)


def render(composition, variant, id_prefix=""):
    renderer = _RENDERERS[variant.composition]
    return renderer(composition, variant, id_prefix)


def _symbol(composition, variant, _id_prefix):
    left, top, width, height = composition.symbol_box
    return Fragment(view_box=f"{left:g} {top:g} {width:g} {height:g}",
                    body=f'<path d="{composition.path_for("")}" fill="{variant.ink}"/>')


def _wordmark(composition, variant, _id_prefix):
    word = composition.wordmark
    return Fragment(view_box=f"0 0 {word.width:.3f} {word.height:.3f}",
                    body=word_group(composition, -word.left, -word.top, variant.ink))


def _lockup(composition, variant, id_prefix):
    layout = composition.lockup(variant.orientation)
    word = composition.wordmark
    gradient_id = gradient_id_for(variant, id_prefix)
    squircle = composition.catalog.placement.squircle
    plate = (f'<defs>{gradient(composition.catalog.palette, gradient_id)}</defs>'
             f'<rect x="{layout.plate_x:.3f}" y="{layout.plate_y:.3f}" '
             f'width="{layout.plate_side:.3f}" height="{layout.plate_side:.3f}" '
             f'rx="{layout.plate_side * squircle:.3f}" ry="{layout.plate_side * squircle:.3f}" '
             f'fill="url(#{gradient_id})"/>')
    mark = mark_group(composition, layout.plate_side,
                       layout.plate_x + layout.plate_side / 2,
                       layout.plate_y + layout.plate_side / 2,
                       composition.catalog.palette.ink)
    word_shape = word_group(composition, layout.wordmark_dx - word.left,
                             layout.wordmark_dy - word.top + layout.view_top, variant.ink)
    return Fragment(
        view_box=f"0 {layout.view_top:g} {layout.width:.3f} {layout.height:.3f}",
        body=plate + mark + word_shape)


def _icon(composition, variant, id_prefix):
    center = variant.canvas / 2
    gradient_id = gradient_id_for(variant, id_prefix)
    radius = variant.visible * composition.catalog.placement.squircle if variant.rounded else 0
    corners = f' rx="{radius:.3f}" ry="{radius:.3f}"' if radius else ""
    ground = (f'<defs>{gradient(composition.catalog.palette, gradient_id)}</defs>'
              f'<rect x="{center - variant.visible / 2:.3f}" y="{center - variant.visible / 2:.3f}" '
              f'width="{variant.visible:.3f}" height="{variant.visible:.3f}"{corners} '
              f'fill="url(#{gradient_id})"/>')
    mark = mark_group(composition, variant.visible, center, center, variant.ink)
    return Fragment(view_box=f"0 0 {variant.canvas:g} {variant.canvas:g}", body=ground + mark)


def _layer(composition, variant, _id_prefix):
    center = variant.canvas / 2
    return Fragment(view_box=f"0 0 {variant.canvas:g} {variant.canvas:g}",
                    body=mark_group(composition, variant.visible, center, center,
                                     variant.ink, variant.layer))


def _ground(composition, variant, id_prefix):
    gradient_id = gradient_id_for(variant, id_prefix)
    return Fragment(
        view_box=f"0 0 {variant.canvas:g} {variant.canvas:g}",
        body=f'<defs>{gradient(composition.catalog.palette, gradient_id)}</defs>'
             f'<rect width="{variant.canvas:g}" height="{variant.canvas:g}" '
             f'fill="url(#{gradient_id})"/>')


def _mark(composition, variant, _id_prefix):
    center = variant.canvas / 2
    return Fragment(view_box=f"0 0 {variant.canvas:g} {variant.canvas:g}",
                    body=mark_group(composition, variant.visible, center, center, variant.ink))


_RENDERERS = {
    "symbol": _symbol,
    "wordmark": _wordmark,
    "lockup": _lockup,
    "icon": _icon,
    "layer": _layer,
    "ground": _ground,
    "mark": _mark,
    "card": card.render,
}
