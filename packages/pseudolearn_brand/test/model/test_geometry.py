import unittest

from pseudolearn_brand.model import catalog
from pseudolearn_brand.model.geometry import SymbolGeometry, flag_path, route_path, symbol_path


def geometry(**overrides):
    values = dict(grid=96.0, stroke=14.0, run=26.0, terminal_radius=10.0, pennant=26.0,
                  pennant_radius=3.0, start_x=10.0, start_y=86.0, turns=6)
    values.update(overrides)
    return SymbolGeometry(**values)


class CornersTest(unittest.TestCase):
    def test_the_route_alternates_right_and_up_from_the_start(self):
        self.assertEqual(geometry().corners()[:3], [(10.0, 86.0), (36.0, 86.0), (36.0, 60.0)])

    def test_every_run_measures_the_same(self):
        corners = geometry().corners()
        steps = {round(abs(b[0] - a[0]) + abs(b[1] - a[1]), 6)
                 for a, b in zip(corners, corners[1:])}
        self.assertEqual(steps, {26.0})

    def test_a_route_with_no_turns_is_a_single_point(self):
        self.assertEqual(geometry(turns=0).corners(), [(10.0, 86.0)])

    def test_the_ink_box_of_a_route_with_no_turns_spans_the_node_and_the_stroke(self):
        left, top, width, height = geometry(turns=0).ink_box()
        self.assertEqual((left, top, width, height), (0.0, 79.0, 17.0, 17.0))


class InkBoxTest(unittest.TestCase):
    def test_the_mark_is_square_at_the_declared_measures(self):
        _left, _top, width, height = catalog.load().symbol.ink_box()
        self.assertEqual((width, height), (95.0, 95.0))

    def test_the_terminal_node_widens_the_box_past_the_route(self):
        thin = geometry(terminal_radius=1.0)
        fat = geometry(terminal_radius=20.0)
        self.assertLess(thin.ink_box()[2], fat.ink_box()[2])


class PathTest(unittest.TestCase):
    def test_the_route_closes_one_subpath_per_run_plus_the_node(self):
        self.assertEqual(route_path(geometry()).count("Z"), 7)

    def test_the_flag_is_a_single_closed_triangle(self):
        self.assertEqual(flag_path(geometry()).count("Z"), 1)

    def test_the_symbol_is_the_route_followed_by_the_flag(self):
        drawn = symbol_path(geometry())
        self.assertTrue(drawn.startswith(route_path(geometry())))
        self.assertTrue(drawn.endswith(flag_path(geometry())))

    def test_a_zero_radius_pennant_still_closes(self):
        self.assertTrue(flag_path(geometry(pennant_radius=0.0)).endswith("Z"))


if __name__ == "__main__":
    unittest.main()
