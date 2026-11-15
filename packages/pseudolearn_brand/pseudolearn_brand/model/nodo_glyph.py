"""Geometry of the Nodo glyph, shared by the web preview and the agent painter of the app."""
from dataclasses import dataclass


@dataclass(frozen=True)
class NodoGlyph:
    grid: float
    stroke: float
    node_x: float
    node_y: float
    node_radius: float
    eye_left_x: float
    eye_right_x: float
    eye_y: float
    eye_radius: float
    wire_start_x: float
    wire_start_y: float
    wire_bend_y: float
    wire_end_x: float
    sparkle_x: float
    sparkle_y: float
    sparkle_reach: float
    sparkle_pinch: float

    @property
    def wire_path(self):
        return (f"M{self.wire_start_x:g} {self.wire_start_y:g}"
                f"V{self.wire_bend_y:g}H{self.wire_end_x:g}")

    @property
    def sparkle_path(self):
        reach, pinch = self.sparkle_reach, self.sparkle_pinch
        return (f"M0 {-reach:g}Q{pinch:g} {-pinch:g} {reach:g} 0"
                f"Q{pinch:g} {pinch:g} 0 {reach:g}"
                f"Q{-pinch:g} {pinch:g} {-reach:g} 0"
                f"Q{-pinch:g} {-pinch:g} 0 {-reach:g}Z")
