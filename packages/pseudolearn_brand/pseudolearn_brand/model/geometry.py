"""Geometry of the PseudoLearn symbol, emitted as filled outlines."""
import math
from dataclasses import dataclass


@dataclass(frozen=True)
class SymbolGeometry:
    grid: float
    stroke: float
    run: float
    terminal_radius: float
    pennant: float
    pennant_radius: float
    start_x: float
    start_y: float
    turns: int

    def corners(self):
        x, y = self.start_x, self.start_y
        points = [(x, y)]
        for index in range(self.turns):
            horizontal = index % 2 == 0
            x, y = (x + self.run, y) if horizontal else (x, y - self.run)
            points.append((x, y))
        return points

    def ink_box(self):
        points = self.corners()
        half = self.stroke / 2
        left = min(self.start_x - self.terminal_radius, min(p[0] for p in points) - half)
        right = max(p[0] for p in points) + half
        top = min(p[1] for p in points) - half
        bottom = max(self.start_y + self.terminal_radius, max(p[1] for p in points) + half)
        return left, top, right - left, bottom - top


def _number(value):
    return f"{value:.4f}".rstrip("0").rstrip(".")


def _rounded_rect(x0, y0, x1, y1, radius):
    r = _number(radius)
    return (f"M {_number(x0+radius)},{_number(y0)} H {_number(x1-radius)} "
            f"A {r},{r} 0 0 1 {_number(x1)},{_number(y0+radius)} "
            f"V {_number(y1-radius)} A {r},{r} 0 0 1 {_number(x1-radius)},{_number(y1)} "
            f"H {_number(x0+radius)} A {r},{r} 0 0 1 {_number(x0)},{_number(y1-radius)} "
            f"V {_number(y0+radius)} A {r},{r} 0 0 1 {_number(x0+radius)},{_number(y0)} Z")


def _circle(cx, cy, radius):
    r = _number(radius)
    return (f"M {_number(cx-radius)},{_number(cy)} A {r},{r} 0 1 1 {_number(cx+radius)},{_number(cy)} "
            f"A {r},{r} 0 1 1 {_number(cx-radius)},{_number(cy)} Z")


def _rounded_polygon(points, radius):
    commands = []
    count = len(points)
    for index, (cx, cy) in enumerate(points):
        previous_x, previous_y = points[index - 1]
        next_x, next_y = points[(index + 1) % count]
        first = (previous_x - cx, previous_y - cy)
        second = (next_x - cx, next_y - cy)
        first_length = math.hypot(*first)
        second_length = math.hypot(*second)
        first_unit = (first[0] / first_length, first[1] / first_length)
        second_unit = (second[0] / second_length, second[1] / second_length)
        dot = first_unit[0] * second_unit[0] + first_unit[1] * second_unit[1]
        half_angle = math.acos(max(-1.0, min(1.0, dot))) / 2
        setback = radius / math.tan(half_angle)
        entry = (cx + first_unit[0] * setback, cy + first_unit[1] * setback)
        exit_point = (cx + second_unit[0] * setback, cy + second_unit[1] * setback)
        move = "M" if index == 0 else "L"
        commands.append(f"{move} {_number(entry[0])},{_number(entry[1])} "
                        f"A {_number(radius)},{_number(radius)} 0 0 1 "
                        f"{_number(exit_point[0])},{_number(exit_point[1])}")
    return " ".join(commands) + " Z"


def route_path(geometry):
    half = geometry.stroke / 2
    points = geometry.corners()
    segments = [
        _rounded_rect(min(x0, x1) - half, min(y0, y1) - half,
                      max(x0, x1) + half, max(y0, y1) + half, half)
        for (x0, y0), (x1, y1) in zip(points, points[1:])
    ]
    segments.append(_circle(geometry.start_x, geometry.start_y, geometry.terminal_radius))
    return " ".join(segments)


def flag_path(geometry):
    x, y = geometry.corners()[-1]
    top = y - geometry.stroke / 2
    return _rounded_polygon(
        [(x, top), (x, top + geometry.pennant), (x - geometry.pennant, top + geometry.pennant / 2)],
        geometry.pennant_radius)


def symbol_path(geometry):
    return f"{route_path(geometry)} {flag_path(geometry)}"
