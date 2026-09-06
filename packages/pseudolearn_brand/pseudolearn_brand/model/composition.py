"""Derived brand measures: the outlined wordmark, the mark's placement and the lockup layouts."""
from dataclasses import dataclass

from . import typography
from .geometry import flag_path, route_path, symbol_path


@dataclass(frozen=True)
class Wordmark:
    path: str
    left: float
    top: float
    right: float
    bottom: float

    @property
    def width(self):
        return self.right - self.left

    @property
    def height(self):
        return self.bottom - self.top


@dataclass(frozen=True)
class LockupLayout:
    plate_side: float
    gap: float
    width: float
    height: float
    view_top: float
    plate_x: float
    plate_y: float
    wordmark_dx: float
    wordmark_dy: float


@dataclass(frozen=True)
class Composition:
    catalog: object
    wordmark: Wordmark
    symbol_box: tuple

    @property
    def cap_center(self):
        return (self.catalog.typography.cap_top + self.catalog.typography.baseline) / 2

    def path_for(self, layer):
        geometry = self.catalog.symbol
        if layer == "route":
            return route_path(geometry)
        if layer == "flag":
            return flag_path(geometry)
        return symbol_path(geometry)

    def scale_for(self, side):
        _left, _top, width, height = self.symbol_box
        placement = self.catalog.placement
        return min(side * placement.max_width / width, side * placement.max_height / height)

    def placement_transform(self, side, center_x, center_y):
        left, top, width, height = self.symbol_box
        scale = self.scale_for(side)
        return (center_x - (left + width / 2) * scale,
                center_y - (top + height / 2) * scale,
                scale)

    def lockup(self, orientation):
        ratios = self.catalog.lockups.by_orientation(orientation)
        cap_height = self.catalog.typography.cap_height
        side = cap_height * ratios.plate
        gap = side * ratios.gap
        if orientation == "horizontal":
            view_top = min(self.catalog.typography.cap_top, self.cap_center - side / 2)
            bottom = max(self.wordmark.bottom, self.cap_center + side / 2)
            return LockupLayout(
                plate_side=side, gap=gap,
                width=side + gap + self.wordmark.width, height=bottom - view_top,
                view_top=view_top, plate_x=0.0, plate_y=self.cap_center - side / 2,
                wordmark_dx=side + gap, wordmark_dy=self.wordmark.top - view_top)
        height = side + gap + (self.wordmark.bottom - self.catalog.typography.cap_top)
        return LockupLayout(
            plate_side=side, gap=gap, width=self.wordmark.width, height=height,
            view_top=0.0, plate_x=self.wordmark.width / 2 - side / 2, plate_y=0.0,
            wordmark_dx=0.0, wordmark_dy=side + gap - self.catalog.typography.cap_top
            + self.wordmark.top)


def build(catalog):
    return Composition(catalog=catalog,
                       wordmark=_wordmark(catalog.typography),
                       symbol_box=catalog.symbol.ink_box())


def _wordmark(settings):
    mono_path, mono_advance = typography.run(
        settings.mono_face, settings.mono_text, settings.type_size, 0, settings.baseline)
    mono_box = typography.ink_bounds(
        settings.mono_face, settings.mono_text, settings.type_size, 0, settings.baseline)
    sans_x = mono_advance + settings.seam
    sans_path, _advance = typography.run(
        settings.sans_face, settings.sans_text, settings.type_size, sans_x, settings.baseline,
        settings.sans_tracking)
    sans_box = typography.ink_bounds(
        settings.sans_face, settings.sans_text, settings.type_size, sans_x, settings.baseline,
        settings.sans_tracking)
    return Wordmark(path=f"{mono_path} {sans_path}",
                    left=min(mono_box[0], sans_box[0]), top=min(mono_box[1], sans_box[1]),
                    right=max(mono_box[2], sans_box[2]), bottom=max(mono_box[3], sans_box[3]))
