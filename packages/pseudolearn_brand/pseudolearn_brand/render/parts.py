"""Drawing pieces shared by every composition: the gradient ground, the placed mark and the word."""
from dataclasses import dataclass


@dataclass(frozen=True)
class Fragment:
    view_box: str
    body: str


def gradient(palette, gradient_id):
    return (f'<linearGradient id="{gradient_id}" x1="0" y1="0" x2="0" y2="1">'
            f'<stop offset="0" stop-color="{palette.ground_top}"/>'
            f'<stop offset="1" stop-color="{palette.ground_bottom}"/></linearGradient>')


def gradient_id_for(variant, id_prefix):
    return f"{id_prefix}{variant.gradient_id}" if id_prefix else variant.gradient_id


def mark_group(composition, side, center_x, center_y, color, layer=""):
    x, y, scale = composition.placement_transform(side, center_x, center_y)
    path = composition.path_for(layer)
    return (f'<g transform="translate({x:.3f} {y:.3f}) scale({scale:.6f})">'
            f'<path d="{path}" fill="{color}"/></g>')


def word_group(composition, dx, dy, color):
    return (f'<g transform="translate({dx:.3f} {dy:.3f})">'
            f'<path fill="{color}" d="{composition.wordmark.path}"/></g>')
