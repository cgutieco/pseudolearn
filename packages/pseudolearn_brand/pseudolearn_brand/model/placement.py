"""Measures that place the mark, the lockups and the social card on their grounds."""
import math
from dataclasses import dataclass


@dataclass(frozen=True)
class Placement:
    max_width: float
    max_height: float
    maskable_safe_circle: float
    squircle: float

    @property
    def maskable_ceiling(self):
        return self.maskable_safe_circle / math.sqrt(2)


@dataclass(frozen=True)
class LockupRatios:
    plate: float
    gap: float


@dataclass(frozen=True)
class Lockups:
    horizontal: LockupRatios
    vertical: LockupRatios
    clear_space: float

    def by_orientation(self, orientation):
        return self.horizontal if orientation == "horizontal" else self.vertical


@dataclass(frozen=True)
class Card:
    span: float
    margin: float
    plate_opacity: float
    plate_outline_opacity: float
    plate_outline: float
    watermark_opacity: float
    watermark_side: float
    watermark_center_x: float
    watermark_center_y: float
